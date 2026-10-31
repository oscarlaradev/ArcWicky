import Foundation

public struct BottleDependency: Identifiable, Sendable, Hashable {
    public var id: String { verb }
    public var verb: String
    public var name: String
    public var category: DependencyCategory
    public var description: String

    public enum DependencyCategory: String, Sendable, CaseIterable {
        case vcredist = "Visual C++"
        case directx = "DirectX Runtimes"
        case dotnet = ".NET / Mono"
        case gaming = "Game Engines & Physics"
    }

    public init(verb: String, name: String, category: DependencyCategory, description: String) {
        self.verb = verb
        self.name = name
        self.category = category
        self.description = description
    }
}

public final class WinetricksManager: @unchecked Sendable {
    public static let shared = WinetricksManager()
    private let fileManager = FileManager.default

    public static let standardDependencies: [BottleDependency] = [
        BottleDependency(verb: "vcrun2022", name: "Visual C++ 2015-2022", category: .vcredist, description: "Required by almost all modern UE4/UE5 and Unity titles."),
        BottleDependency(verb: "vcrun2012", name: "Visual C++ 2012", category: .vcredist, description: "Legacy runtimes for 2012-2015 Windows titles."),
        BottleDependency(verb: "vcrun2010", name: "Visual C++ 2010", category: .vcredist, description: "Required for older indie and DirectX 9/11 titles."),
        BottleDependency(verb: "d3dcompiler_47", name: "D3DCompiler 47", category: .directx, description: "Direct3D shader compiler HLSL DLL used by modern games."),
        BottleDependency(verb: "d3dcompiler_43", name: "D3DCompiler 43", category: .directx, description: "Classic DirectX 11 shader compiler runtime."),
        BottleDependency(verb: "d3dx9", name: "DirectX 9 Runtimes", category: .directx, description: "Legacy DirectX 9 extensions (d3dx9_43.dll)."),
        BottleDependency(verb: "xact", name: "XACT Audio Engine", category: .directx, description: "Microsoft Cross-Platform Audio Creation Tool."),
        BottleDependency(verb: "dotnet48", name: ".NET Framework 4.8", category: .dotnet, description: "Full Windows .NET Framework 4.8 runtime."),
        BottleDependency(verb: "physx", name: "NVIDIA PhysX", category: .gaming, description: "Physics simulation engine for Windows games.")
    ]

    private init() {}

    public func winetricksURL() -> URL {
        PathManager.shared.enginesURL
            .appendingPathComponent("winetricks", isDirectory: true)
            .appendingPathComponent("winetricks")
    }

    public func isWinetricksAvailable() -> Bool {
        fileManager.isExecutableFile(atPath: winetricksURL().path) || fileManager.fileExists(atPath: "/usr/local/bin/winetricks") || fileManager.fileExists(atPath: "/opt/homebrew/bin/winetricks")
    }

    public func resolvedWinetricksPath() -> String {
        if fileManager.isExecutableFile(atPath: winetricksURL().path) {
            return winetricksURL().path
        }
        if fileManager.fileExists(atPath: "/opt/homebrew/bin/winetricks") {
            return "/opt/homebrew/bin/winetricks"
        }
        if fileManager.fileExists(atPath: "/usr/local/bin/winetricks") {
            return "/usr/local/bin/winetricks"
        }
        return winetricksURL().path
    }

    /// Installs a specific winetricks dependency verb into the given prefix.
    public func install(
        verb: String,
        prefixURL: URL,
        wineExecutable: URL,
        wineserverExecutable: URL? = nil
    ) async throws {
        let scriptPath = resolvedWinetricksPath()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = [scriptPath, "-q", verb]

        var env = ProcessInfo.processInfo.environment
        env["WINEPREFIX"] = prefixURL.path
        env["WINE"] = wineExecutable.path
        if let ws = wineserverExecutable {
            env["WINESERVER"] = ws.path
        }
        env["WINEDLLOVERRIDES"] = "mscoree,mshtml="
        process.environment = env

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "WinetricksError", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "Winetricks install failed: \(output)"])
        }
    }
}

