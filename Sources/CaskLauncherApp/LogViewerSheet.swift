import SwiftUI
import CaskLauncherCore

struct LogViewerSheet: View {
    @ObservedObject var appState: AppState
    let store: GameStore?
    let customBottleID: UUID?
    
    @State private var logContent: String = ""
    @State private var filterQuery: String = ""
    @State private var autoScroll: Bool = true
    @State private var isRefreshing: Bool = false
    @State private var selectedDebugPreset: String = "Default"
    @Environment(\.dismiss) private var dismiss

    private let debugPresets = [
        "Default (-all)",
        "Verbose (+loaddll,+module)",
        "Graphics (+d3d11,+dxgi,+winevulkan)",
        "Full Debug (+all)"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: VermutSpace.s1) {
                    Text("Interactive Wine Console")
                        .font(VermutType.headline)
                        .foregroundStyle(Color.Vermut.foreground)
                    Text(bottleTitle)
                        .font(VermutType.captionRegular)
                        .foregroundStyle(Color.Vermut.mutedForeground)
                }

                Spacer()

                Picker("Wine Debug:", selection: $selectedDebugPreset) {
                    ForEach(debugPresets, id: \.self) { preset in
                        Text(preset).tag(preset)
                    }
                }
                .frame(width: 200)

                Button("Copy Log") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(logContent, forType: .string)
                }
                .buttonStyle(VermutButtonStyle(kind: .outline, height: VermutHeight.buttonSmall))

                Button("Close") {
                    dismiss()
                }
                .buttonStyle(VermutButtonStyle(kind: .ghost, height: VermutHeight.buttonSmall))
            }
            .padding(.horizontal, VermutSpace.s6)
            .padding(.vertical, VermutSpace.s4)
            .background(Color.Vermut.surface)

            Divider()

            // Filter Bar
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundStyle(Color.Vermut.mutedForeground)
                TextField("Filter log output (e.g. d3d11, err:, warn:)...", text: $filterQuery)
                    .textFieldStyle(.plain)
                    .font(VermutType.mono)
                if !filterQuery.isEmpty {
                    Button {
                        filterQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.Vermut.mutedForeground)
                    }
                    .buttonStyle(.plain)
                }
                Toggle("Auto-scroll", isOn: $autoScroll)
                    .font(VermutType.captionRegular)
            }
            .padding(.horizontal, VermutSpace.s6)
            .padding(.vertical, VermutSpace.s2)
            .background(ArcWickyTheme.Palette.surfaceDeck)

            Divider()

            // Console output
            ScrollViewReader { proxy in
                ScrollView {
                    Text(filteredLog)
                        .font(VermutType.mono)
                        .foregroundStyle(Color.Vermut.foreground)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(VermutSpace.s4)
                        .id("bottomID")
                }
                .background(Color.black.opacity(0.4))
                .onChange(of: logContent) { _, _ in
                    if autoScroll {
                        withAnimation {
                            proxy.scrollTo("bottomID", anchor: .bottom)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 700, minHeight: 480)
        .background(ArcWickyTheme.Palette.obsidianBase)
        .onAppear {
            loadLogs()
        }
    }

    private var bottleTitle: String {
        if let store = store {
            return "\(store.rawValue) Bottle"
        } else if let id = customBottleID, let bottle = appState.customBottle(id: id) {
            return "\(bottle.name) Bottle"
        }
        return "Bottle Logs"
    }

    private var logURL: URL? {
        if let store = store {
            return PathManager.shared.logURL(for: store)
        } else if let id = customBottleID {
            return PathManager.shared.customLogURL(id: id)
        }
        return nil
    }

    private var filteredLog: String {
        if filterQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            return logContent.isEmpty ? "No logs captured yet." : logContent
        }
        let lines = logContent.components(separatedBy: "\n")
        let matched = lines.filter { $0.localizedCaseInsensitiveContains(filterQuery) }
        return matched.isEmpty ? "No log entries match '\(filterQuery)'" : matched.joined(separator: "\n")
    }

    private func loadLogs() {
        guard let url = logURL else { return }
        if let data = try? Data(contentsOf: url),
           let content = String(data: data, encoding: .utf8) {
            // Keep last 3000 lines for performance
            let lines = content.components(separatedBy: "\n")
            if lines.count > 3000 {
                self.logContent = lines.suffix(3000).joined(separator: "\n")
            } else {
                self.logContent = content
            }
        } else {
            self.logContent = "Log file not created yet or empty at \(url.path)"
        }
    }
}
