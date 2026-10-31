import Foundation

public struct SaveBackupItem: Identifiable, Sendable {
    public var id: String { filename }
    public var filename: String
    public var bottleName: String
    public var date: Date
    public var size: Int64
    public var fileURL: URL
}

public final class SaveManager: @unchecked Sendable {
    public static let shared = SaveManager()
    private let fileManager = FileManager.default

    public var localBackupDirectory: URL {
        PathManager.shared.appSupportURL.appendingPathComponent("SavesBackup", isDirectory: true)
    }

    public var iCloudBackupDirectory: URL? {
        let icloud = fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs/VermutSaves", isDirectory: true)
        return icloud
    }

    private init() {
        try? fileManager.createDirectory(at: localBackupDirectory, withIntermediateDirectories: true)
    }

    /// Scans a bottle prefix for saved games directories.
    public func discoverSaveFolders(prefixURL: URL) -> [URL] {
        var results: [URL] = []
        let usersDir = prefixURL.appendingPathComponent("drive_c/users", isDirectory: true)
        guard let users = try? fileManager.contentsOfDirectory(at: usersDir, includingPropertiesForKeys: nil) else {
            return []
        }

        for userDir in users {
            let savedGames = userDir.appendingPathComponent("Saved Games", isDirectory: true)
            if fileManager.fileExists(atPath: savedGames.path) {
                results.append(savedGames)
            }
            let docs = userDir.appendingPathComponent("Documents", isDirectory: true)
            if fileManager.fileExists(atPath: docs.path) {
                results.append(docs)
            }
            let appDataLocal = userDir.appendingPathComponent("AppData/Local", isDirectory: true)
            if fileManager.fileExists(atPath: appDataLocal.path) {
                results.append(appDataLocal)
            }
            let appDataRoaming = userDir.appendingPathComponent("AppData/Roaming", isDirectory: true)
            if fileManager.fileExists(atPath: appDataRoaming.path) {
                results.append(appDataRoaming)
            }
        }
        return results
    }

    /// Creates a zip backup of save folders for a bottle.
    public func createBackup(forBottleNamed bottleName: String, prefixURL: URL, syncToCloud: Bool = false) async throws -> URL {
        try fileManager.createDirectory(at: localBackupDirectory, withIntermediateDirectories: true)
        let saveFolders = discoverSaveFolders(prefixURL: prefixURL)
        guard !saveFolders.isEmpty else {
            throw NSError(domain: "VermutSaveError", code: 404, userInfo: [NSLocalizedDescriptionKey: "No save folders found in bottle prefix."])
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let archiveName = "\(bottleName)_saves_\(timestamp).zip"
        let destURL = localBackupDirectory.appendingPathComponent(archiveName)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        var args = ["-q", "-r", destURL.path]
        for folder in saveFolders {
            args.append(folder.path)
        }
        process.arguments = args
        try process.run()
        process.waitUntilExit()

        if syncToCloud, let icloudDir = iCloudBackupDirectory {
            try? fileManager.createDirectory(at: icloudDir, withIntermediateDirectories: true)
            let cloudDest = icloudDir.appendingPathComponent(archiveName)
            try? fileManager.copyItem(at: destURL, to: cloudDest)
        }

        return destURL
    }

    /// Lists existing local and cloud backups.
    public func listBackups() -> [SaveBackupItem] {
        guard let files = try? fileManager.contentsOfDirectory(at: localBackupDirectory, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]) else {
            return []
        }

        var items: [SaveBackupItem] = []
        for file in files where file.pathExtension.lowercased() == "zip" {
            let attrs = try? fileManager.attributesOfItem(atPath: file.path)
            let date = (attrs?[.modificationDate] as? Date) ?? Date()
            let size = (attrs?[.size] as? NSNumber)?.int64Value ?? 0
            let name = file.lastPathComponent
            let bottleName = name.components(separatedBy: "_saves_").first ?? "Bottle"
            items.append(SaveBackupItem(
                filename: name,
                bottleName: bottleName,
                date: date,
                size: size,
                fileURL: file
            ))
        }
        return items.sorted(by: { $0.date > $1.date })
    }
}

