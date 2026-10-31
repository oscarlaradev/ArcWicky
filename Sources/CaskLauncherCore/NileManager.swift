import Foundation

/// Represents an Amazon Games title managed via Nile.
public struct NileGame: Identifiable, Codable, Sendable, Equatable {
    public var id: String { appName }
    public var appName: String
    public var title: String
    public var productID: String?
    public var iconURL: URL?
    public var isInstalled: Bool
    public var installPath: String?
    public var installSize: Int64?
    public var executable: String?

    public init(
        appName: String,
        title: String,
        productID: String? = nil,
        iconURL: URL? = nil,
        isInstalled: Bool = false,
        installPath: String? = nil,
        installSize: Int64? = nil,
        executable: String? = nil
    ) {
        self.appName = appName
        self.title = title
        self.productID = productID
        self.iconURL = iconURL
        self.isInstalled = isInstalled
        self.installPath = installPath
        self.installSize = installSize
        self.executable = executable
    }
}

/// Amazon Games integration via Nile CLI (open source CLI client for Amazon Games).
public final class NileManager: @unchecked Sendable {
    public static let shared = NileManager()

    private let fileManager = FileManager.default
    private let lock = NSLock()
    private var isSyncing = false

    private init() {}

    public func binaryURL() -> URL {
        PathManager.shared.enginesURL
            .appendingPathComponent("nile", isDirectory: true)
            .appendingPathComponent("nile")
    }

    public func isNileAvailable() -> Bool {
        fileManager.isExecutableFile(atPath: binaryURL().path)
    }

    public func configDirectory() -> URL {
        PathManager.shared.bottlesURL
            .appendingPathComponent("amazon", isDirectory: true)
            .appendingPathComponent("nile", isDirectory: true)
    }

    public func isUserLoggedIn() -> Bool {
        let authFile = configDirectory().appendingPathComponent("user.json")
        let credentialsFile = configDirectory().appendingPathComponent("credentials.json")
        return fileManager.fileExists(atPath: authFile.path) || fileManager.fileExists(atPath: credentialsFile.path)
    }

    public func localInstalledGames() -> [NileGame] {
        let installedFile = configDirectory().appendingPathComponent("installed.json")
        guard let data = try? Data(contentsOf: installedFile),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
            return []
        }

        var results: [NileGame] = []
        for (appName, dict) in json {
            let title = dict["title"] as? String ?? appName
            let installPath = dict["install_path"] as? String
            let executable = dict["executable"] as? String
            let installSize = (dict["install_size"] as? NSNumber)?.int64Value
            results.append(NileGame(
                appName: appName,
                title: title,
                productID: dict["product_id"] as? String,
                isInstalled: true,
                installPath: installPath,
                installSize: installSize,
                executable: executable
            ))
        }
        return results
    }

    public func cachedLibraryGames() -> [NileGame] {
        let cacheFile = configDirectory().appendingPathComponent("library_cache.json")
        guard let data = try? Data(contentsOf: cacheFile),
              let list = try? JSONDecoder().decode([NileGame].self, from: data) else {
            return localInstalledGames()
        }
        let installed = localInstalledGames()
        let installedMap = Dictionary(installed.map { ($0.appName, $0) }, uniquingKeysWith: { a, _ in a })
        return list.map { game in
            if let inst = installedMap[game.appName] {
                var g = game
                g.isInstalled = true
                g.installPath = inst.installPath
                g.executable = inst.executable
                return g
            }
            return game
        }
    }

    public func saveCachedLibrary(_ games: [NileGame]) {
        try? fileManager.createDirectory(at: configDirectory(), withIntermediateDirectories: true)
        let cacheFile = configDirectory().appendingPathComponent("library_cache.json")
        if let data = try? JSONEncoder().encode(games) {
            try? data.write(to: cacheFile)
        }
    }

    public func syncLibrary() async throws -> [NileGame] {
        guard isNileAvailable() else {
            return cachedLibraryGames()
        }

        let process = Process()
        process.executableURL = binaryURL()
        process.arguments = ["library", "--json"]
        var env = ProcessInfo.processInfo.environment
        env["XDG_CONFIG_HOME"] = configDirectory().deletingLastPathComponent().path
        env["LC_ALL"] = "en_US.UTF-8"
        env["LANG"] = "en_US.UTF-8"
        process.environment = env

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return cachedLibraryGames()
        }

        var games: [NileGame] = []
        for dict in jsonArray {
            guard let appName = dict["id"] as? String ?? dict["product_id"] as? String else { continue }
            let title = dict["title"] as? String ?? appName
            let iconStr = dict["icon_url"] as? String
            let iconURL = iconStr.flatMap { URL(string: $0) }
            games.append(NileGame(
                appName: appName,
                title: title,
                productID: dict["product_id"] as? String,
                iconURL: iconURL,
                isInstalled: false
            ))
        }

        saveCachedLibrary(games)
        return games
    }
}

