import SwiftUI
import CaskLauncherCore

// MARK: - Screen: Downloads & Background Tasks
// Tactile Vinyl & Spatial Cartoon Mission Control for Loot Transfers
struct DownloadsView: View {
    @EnvironmentObject var appState: AppState

    private var storeRows: [GameStore] {
        GameStore.allCases.filter { store in
            switch appState.status(for: store) {
            case .downloading, .installing, .error:
                return true
            default:
                return false
            }
        }
    }

    private var gameRows: [GameDownload] {
        appState.gameDownloads.values.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private var hasActiveDownloads: Bool {
        !storeRows.isEmpty || !gameRows.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Header Deck
                headerSection

                // Active Queue or Cartoon Empty State
                if hasActiveDownloads {
                    activeQueueSection
                } else {
                    emptyQueueSection
                }
            }
            .padding(.horizontal, 36)
            .padding(.top, 24)
            .padding(.bottom, 140) // High clearance for bottom floating dock
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(ArcWickyTheme.Palette.canvas)
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(ArcWickyTheme.Palette.accentMint)
                        .frame(width: 8, height: 8)
                        .shadow(color: ArcWickyTheme.Palette.accentMint, radius: 4)

                    Text("MISSION CONTROL • TRANSFERS & QUEUE")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                        .tracking(1.4)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(Capsule().fill(ArcWickyTheme.Palette.surfaceContainerLow))
                .overlay(Capsule().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5))

                Text("DOWNLOADS & LOOT IN TRANSIT")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                    .rotationEffect(.degrees(-0.8))
                    .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 4)

                Text("Live game installations, Epic package extraction, Wine engine runtime setup, and cloud assets.")
                    .font(ArcWickyTheme.Typography.body)
                    .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                    .frame(maxWidth: 640)
            }

            Spacer(minLength: 24)

            if hasActiveDownloads {
                HStack(spacing: 6) {
                    Circle()
                        .fill(ArcWickyTheme.Palette.accentMint)
                        .frame(width: 8, height: 8)
                    Text("\(storeRows.count + gameRows.count) In Transit")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(ArcWickyTheme.Palette.surfaceContainerLow))
                .overlay(Capsule().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5))
            }
        }
    }

    // MARK: - Active Downloads Queue
    private var activeQueueSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ACTIVE TRANSIT CHANNELS")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                .tracking(1.2)

            VStack(spacing: 16) {
                ForEach(storeRows) { store in
                    storeDownloadCard(store)
                }

                ForEach(gameRows) { download in
                    gameDownloadCard(download)
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyQueueSection: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ArcWickyTheme.Palette.surfaceElevated,
                                ArcWickyTheme.Palette.surfaceContainerLow
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 360, height: 260)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 2)
                    )
                    .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(ArcWickyTheme.Palette.surface)
                            .frame(width: 88, height: 88)
                            .overlay(Circle().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5))
                            .shadow(color: ArcWickyTheme.Palette.accentMint.opacity(0.2), radius: 12)

                        Image(systemName: "tray.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ArcWickyTheme.Palette.accentMint, ArcWickyTheme.Palette.accent],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }

                    VStack(spacing: 4) {
                        Text("ALL QUEUES ARE CLEAR!")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                            .tracking(1.0)

                        Text("No active downloads or background transits running.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                    }
                }
            }

            // Quick Actions
            HStack(spacing: 14) {
                Button {
                    appState.section = .stores
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "storefront.fill")
                        Text("Explore Stores & Free Loot")
                    }
                }
                .buttonStyle(ArcWickyToyPlayButtonStyle())

                Button {
                    appState.section = .library
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "gamecontroller.fill")
                        Text("Open Playground")
                    }
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 44, horizontalPadding: 16))
            }
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }

    // MARK: - Store Download Card
    private func storeDownloadCard(_ store: GameStore) -> some View {
        let status = appState.status(for: store)
        let presentation = StoreStatusPresentation.from(status)

        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                StoreLogoTile(store: store, size: 40)

                VStack(alignment: .leading, spacing: 3) {
                    Text(store.rawValue)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)

                    Text(store.installerFilename)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                }

                Spacer()

                ArcWickyBadge(
                    text: presentation.text,
                    tone: presentation.kind == .error ? .destructive : .accent,
                    showDot: presentation.showsDot
                )
            }

            if case .downloading = status {
                StoreInstallControls(store: store, status: status)
            } else if case .installing = status {
                StoreInstallControls(store: store, status: status)
            } else if case .error(let msg) = status {
                Text(msg)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(ArcWickyTheme.Palette.destructive)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ArcWickyTheme.Palette.destructive.opacity(0.12))
                    )
            }

            HStack {
                Spacer()

                if case .error = status {
                    Button("Retry Installation") { appState.retryStore(store) }
                        .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 32, horizontalPadding: 14))
                    Button("View Logs") { appState.openLogs(for: store) }
                        .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 32, horizontalPadding: 14))
                } else {
                    Button("Cancel") { appState.cancelInstall(store) }
                        .buttonStyle(ArcWickyButtonStyle(variant: .destructive, height: 32, horizontalPadding: 14))
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(ArcWickyTheme.Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
        )
        .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 6)
    }

    // MARK: - Game Download Card (Epic / Legendary / Steam)
    private func gameDownloadCard(_ download: GameDownload) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                StoreLogoTile(store: download.store, size: 40)

                VStack(alignment: .leading, spacing: 3) {
                    Text(download.name)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)

                    Text(download.store.rawValue)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                }

                Spacer()

                if download.isFailed {
                    ArcWickyBadge(text: "Failed", tone: .destructive)
                } else {
                    ArcWickyBadge(
                        text: "Downloading \(Int(min(max(download.progress, 0), 0.99) * 100))%",
                        tone: .accent
                    )
                }
            }

            if download.isFailed {
                Text(download.error ?? "Download failed. Check internet connection or storage space.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(ArcWickyTheme.Palette.destructive)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ArcWickyTheme.Palette.destructive.opacity(0.12))
                    )
            } else {
                // Chunky Animated Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(ArcWickyTheme.Palette.surfaceContainerLow)
                            .frame(height: 10)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [ArcWickyTheme.Palette.accentMint, ArcWickyTheme.Palette.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(CGFloat(download.progress) * geo.size.width, 10), height: 10)
                            .shadow(color: ArcWickyTheme.Palette.accentMint.opacity(0.4), radius: 6)
                    }
                }
                .frame(height: 10)

                if !download.detail.isEmpty {
                    Text(download.detail)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                }
            }

            HStack {
                Spacer()

                Button("Cancel Download") {
                    appState.cancelEpicGameDownload(download)
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .destructive, height: 32, horizontalPadding: 14))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(ArcWickyTheme.Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
        )
        .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 6)
    }
}
