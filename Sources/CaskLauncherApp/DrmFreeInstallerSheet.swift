import SwiftUI
import AppKit
import CaskLauncherCore

struct DrmFreeInstallerSheet: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var installerURL: URL?
    @State private var gameTitle: String = ""
    @State private var selectedBottle: String = "GOG"
    @State private var isInstalling: Bool = false
    @State private var installStatus: String = ""
    @State private var installError: String?
    @State private var detectedDownload: URL?

    var body: some View {
        VStack(spacing: VermutSpace.s5) {
            headerView
            Divider()
            formView
            statusView
            Spacer(minLength: 0)
            Divider()
            actionsView
        }
        .padding(VermutSpace.s6)
        .frame(width: 540, height: 460)
        .background(ArcWickyTheme.Palette.obsidianBase)
        .onAppear {
            if let preloaded = appState.drmInstallerPreloadedTitle, !preloaded.isEmpty {
                self.gameTitle = preloaded
            }
            scanDownloads()
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: VermutSpace.s1) {
                Text("Install Game (.exe, .zip, .msi)")
                    .font(VermutType.headline)
                    .foregroundStyle(Color.Vermut.foreground)
                Text("Install DRM-free and indie games from GOG, itch.io, Humble Bundle, or local files.")
                    .font(VermutType.captionRegular)
                    .foregroundStyle(Color.Vermut.mutedForeground)
            }
            Spacer()
            Button("Cancel") {
                clearPreloaded()
                dismiss()
            }
            .buttonStyle(VermutButtonStyle(kind: .ghost, height: VermutHeight.buttonSmall))
        }
    }

    private var formView: some View {
        VStack(alignment: .leading, spacing: VermutSpace.s4) {
            filePickerStep
            titleStep
            bottlePickerStep
            if let webURL = appState.drmInstallerPreloadedWebURL, installerURL == nil {
                webDownloadHint(webURL)
            }
        }
    }

    private var filePickerStep: some View {
        VStack(alignment: .leading, spacing: VermutSpace.s2) {
            Text("1. Select Game File (.exe, .zip, .msi)")
                .font(VermutType.bodyEmphasis)
                .foregroundStyle(Color.Vermut.foreground)
            
            HStack {
                Text(installerURL?.lastPathComponent ?? "No file selected")
                    .font(VermutType.mono)
                    .foregroundStyle(installerURL != nil ? Color.Vermut.foreground : Color.Vermut.mutedForeground)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding(.horizontal, VermutSpace.s3)
                    .padding(.vertical, VermutSpace.s2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.Vermut.surface)
                    .clipShape(RoundedRectangle(cornerRadius: VermutRadius.sm))

                Button("Browse…") {
                    pickInstallerFile()
                }
                .buttonStyle(VermutButtonStyle(kind: .outline, height: VermutHeight.buttonSmall))
            }

            if let detected = detectedDownload, installerURL != detected {
                HStack(spacing: VermutSpace.s2) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.Vermut.amber)
                    Text("Found in Downloads: \(detected.lastPathComponent)")
                        .font(VermutType.captionRegular)
                        .foregroundStyle(Color.Vermut.foreground)
                        .lineLimit(1)
                    Spacer()
                    Button("Use This File") {
                        self.installerURL = detected
                        if self.gameTitle.isEmpty {
                            deriveTitle(from: detected)
                        }
                    }
                    .buttonStyle(VermutButtonStyle(kind: .primary, height: 22))
                }
                .padding(.horizontal, VermutSpace.s3)
                .padding(.vertical, 4)
                .background(Color.Vermut.surface)
                .clipShape(RoundedRectangle(cornerRadius: VermutRadius.xs))
            }
        }
    }

    private var titleStep: some View {
        VStack(alignment: .leading, spacing: VermutSpace.s2) {
            Text("2. Game Title")
                .font(VermutType.bodyEmphasis)
                .foregroundStyle(Color.Vermut.foreground)
            
            TextField("e.g. The Baby In Yellow, Hollow Knight", text: $gameTitle)
                .textFieldStyle(.plain)
                .padding(.horizontal, VermutSpace.s3)
                .padding(.vertical, VermutSpace.s2)
                .background(Color.Vermut.surface)
                .clipShape(RoundedRectangle(cornerRadius: VermutRadius.sm))
        }
    }

    private var bottlePickerStep: some View {
        VStack(alignment: .leading, spacing: VermutSpace.s2) {
            Text("3. Target Bottle")
                .font(VermutType.bodyEmphasis)
                .foregroundStyle(Color.Vermut.foreground)
            
            Picker("Bottle:", selection: $selectedBottle) {
                Text("GOG Galaxy / DRM-Free Bottle (Recommended)").tag("GOG")
                Text("Epic Games Bottle").tag("Epic")
                Text("Steam Bottle").tag("Steam")
            }
            .pickerStyle(.menu)
        }
    }

    private func webDownloadHint(_ url: URL) -> some View {
        HStack {
            Image(systemName: "arrow.down.circle")
                .foregroundStyle(Color.Vermut.info)
            Text("Need to download the game file first?")
                .font(VermutType.captionRegular)
                .foregroundStyle(Color.Vermut.mutedForeground)
            Spacer()
            Button("Download from itch.io") {
                NSWorkspace.shared.open(url)
            }
            .buttonStyle(VermutButtonStyle(kind: .outline, height: VermutHeight.buttonSmall))
        }
        .padding(VermutSpace.s2)
        .background(Color.Vermut.surface)
        .clipShape(RoundedRectangle(cornerRadius: VermutRadius.sm))
    }

    @ViewBuilder
    private var statusView: some View {
        if isInstalling {
            VStack(spacing: VermutSpace.s2) {
                ProgressView()
                    .controlSize(.small)
                Text(installStatus)
                    .font(VermutType.captionRegular)
                    .foregroundStyle(Color.Vermut.amber)
            }
            .padding(.vertical, VermutSpace.s2)
        }

        if let error = installError {
            Text(error)
                .font(VermutType.captionRegular)
                .foregroundStyle(Color.Vermut.destructive)
        }
    }

    private var actionsView: some View {
        HStack {
            Spacer()
            Button(installerURL?.pathExtension.lowercased() == "zip" ? "Unpack & Install Game" : "Run Installer") {
                runInstaller()
            }
            .buttonStyle(VermutButtonStyle(kind: .primary, height: VermutHeight.button))
            .disabled(installerURL == nil || isInstalling)
        }
    }

    private func scanDownloads() {
        let downloads = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads")
        guard let files = try? FileManager.default.contentsOfDirectory(at: downloads, includingPropertiesForKeys: [.contentModificationDateKey]) else { return }
        
        let validExts = Set(["exe", "zip", "msi"])
        let valid = files.filter { validExts.contains($0.pathExtension.lowercased()) }
        
        if !gameTitle.isEmpty {
            let clean = gameTitle.lowercased().replacingOccurrences(of: " ", with: "")
            if let matched = valid.first(where: {
                $0.lastPathComponent.lowercased().replacingOccurrences(of: " ", with: "").contains(clean)
            }) {
                self.detectedDownload = matched
                if self.installerURL == nil { self.installerURL = matched }
                return
            }
        }
        
        // Find most recently modified file in last 2 hours
        let twoHoursAgo = Date().addingTimeInterval(-7200)
        let sorted = valid.compactMap { url -> (URL, Date)? in
            guard let date = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate,
                  date > twoHoursAgo else { return nil }
            return (url, date)
        }.sorted { $0.1 > $1.1 }
        
        if let mostRecent = sorted.first?.0 {
            self.detectedDownload = mostRecent
            if self.installerURL == nil {
                self.installerURL = mostRecent
                if self.gameTitle.isEmpty { deriveTitle(from: mostRecent) }
            }
        }
    }

    private func deriveTitle(from url: URL) {
        let name = url.deletingPathExtension().lastPathComponent
        self.gameTitle = name
            .replacingOccurrences(of: "setup_", with: "")
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }

    private func pickInstallerFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.item]
        panel.message = "Choose Game File (.exe, .zip, or .msi)"
        if panel.runModal() == .OK, let url = panel.url {
            self.installerURL = url
            if self.gameTitle.isEmpty {
                deriveTitle(from: url)
            }
        }
    }

    private func runInstaller() {
        guard let url = installerURL else { return }
        isInstalling = true
        installError = nil
        let targetTitle = gameTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? url.deletingPathExtension().lastPathComponent
            : gameTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        let isZip = url.pathExtension.lowercased() == "zip"
        installStatus = isZip ? "Extracting game files..." : "Launching installer under Wine..."

        Task {
            do {
                let bottleConfig = BottleConfiguration(
                    engine: appState.configuration.defaultEngine,
                    graphicsBackend: appState.configuration.defaultGraphicsBackend,
                    enableHiDPI: appState.configuration.enableHiDPI,
                    windowsVersion: appState.configuration.windowsVersion
                )

                let targetStore: GameStore
                switch selectedBottle {
                case "Epic": targetStore = .epic
                case "Steam": targetStore = .steam
                default: targetStore = .gog
                }

                let prefixURL = PathManager.shared.prefixURL(for: targetStore)
                try await WineManager.shared.createPrefix(for: targetStore, config: bottleConfig)

                if isZip {
                    let cleanId = targetTitle.lowercased().replacingOccurrences(of: " ", with: "_")
                    let gamesDir = prefixURL.appendingPathComponent("drive_c/GOG Games/\(targetTitle)")
                    try FileManager.default.createDirectory(at: gamesDir, withIntermediateDirectories: true)

                    let unzip = Process()
                    unzip.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
                    unzip.arguments = ["-q", "-o", url.path, "-d", gamesDir.path]
                    try unzip.run()
                    unzip.waitUntilExit()

                    let foundExe = findPrimaryExecutable(in: gamesDir, preferredName: targetTitle)
                    let exeRelPath = foundExe != nil
                        ? foundExe!.path.replacingOccurrences(of: gamesDir.path + "/", with: "")
                        : "\(targetTitle).exe"

                    let infoDict: [String: Any] = [
                        "gameId": cleanId,
                        "rootGameId": cleanId,
                        "name": targetTitle,
                        "playTasks": [
                            [
                                "arguments": "",
                                "category": "game",
                                "isPrimary": true,
                                "name": targetTitle,
                                "path": exeRelPath,
                                "type": "FileTask"
                            ]
                        ]
                    ]
                    let infoData = try JSONSerialization.data(withJSONObject: infoDict, options: [.prettyPrinted])
                    let infoURL = gamesDir.appendingPathComponent("goggame-\(cleanId).info")
                    try infoData.write(to: infoURL)

                    if let coverURL = appState.drmInstallerPreloadedCoverURL {
                        let coverFile = gamesDir.appendingPathComponent("cover.jpg")
                        if let (data, _) = try? await URLSession.shared.data(from: coverURL) {
                            try? data.write(to: coverFile)
                        }
                    }
                } else {
                    let engine = StoreRecipe.effectiveEngine(bottleConfig, global: appState.configuration).value
                    let layout = PathManager.shared.engineLayout(for: engine)
                    let wine = layout?.wine64Executable ?? layout?.wineExecutable ?? PathManager.shared.wineExecutable(engine: engine)!
                    var env = ProcessInfo.processInfo.environment
                    env["WINEPREFIX"] = prefixURL.path
                    env["WINELOADER"] = wine.path
                    try WineManager.shared.launchDetached(
                        executable: wine,
                        arguments: [url.path],
                        environment: env,
                        workingDirectory: url.deletingLastPathComponent().path,
                        logURL: PathManager.shared.logURL(for: targetStore)
                    )
                }

                await MainActor.run {
                    isInstalling = false
                    clearPreloaded()
                    dismiss()
                    appState.refreshLibrary(forceEpicSync: false)
                    appState.section = .library
                }
            } catch {
                await MainActor.run {
                    isInstalling = false
                    installError = error.localizedDescription
                }
            }
        }
    }

    private func findPrimaryExecutable(in dir: URL, preferredName: String) -> URL? {
        guard let enumerator = FileManager.default.enumerator(at: dir, includingPropertiesForKeys: nil) else { return nil }
        var candidates: [URL] = []
        for case let fileURL as URL in enumerator {
            let lower = fileURL.lastPathComponent.lowercased()
            if fileURL.pathExtension.lowercased() == "exe",
               !lower.hasPrefix("unins"),
               !lower.contains("crash"),
               !lower.contains("setup"),
               !lower.contains("unitycrash") {
                candidates.append(fileURL)
            }
        }
        let cleanPreferred = preferredName.lowercased().replacingOccurrences(of: " ", with: "")
        if let match = candidates.first(where: {
            $0.lastPathComponent.lowercased().replacingOccurrences(of: " ", with: "").contains(cleanPreferred)
        }) {
            return match
        }
        return candidates.first
    }

    private func clearPreloaded() {
        appState.drmInstallerPreloadedTitle = nil
        appState.drmInstallerPreloadedCoverURL = nil
        appState.drmInstallerPreloadedWebURL = nil
    }
}
