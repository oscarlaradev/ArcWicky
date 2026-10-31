import SwiftUI
import AppKit
import CaskLauncherCore

/// Section displaying official Free Games of the Week from Epic Games Store, itch.io, and GOG.
struct FreeGamesPromoSection: View {
    @EnvironmentObject var appState: AppState
    @State private var freeGames: [EpicFreeGame] = []
    @State private var isLoading = false
    @State private var hasFetched = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            if isLoading && freeGames.isEmpty {
                HStack(spacing: 8) {
                    ProgressView().controlSize(.small)
                    Text("Fetching weekly promotions…")
                        .font(ArcWickyTheme.Typography.caption)
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                }
                .padding(.vertical, 12)
            } else if freeGames.isEmpty && hasFetched {
                Text("No free promotions found right now.")
                    .font(ArcWickyTheme.Typography.caption)
                    .foregroundStyle(ArcWickyTheme.Palette.textMuted)
            } else if !freeGames.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(freeGames) { game in
                            FreeGameCard(game: game)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .task {
            await loadPromotions()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            Task {
                await loadPromotions()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle().fill(ArcWickyTheme.Palette.success.opacity(0.12))
                Image(systemName: "gift.fill")
                    .foregroundStyle(ArcWickyTheme.Palette.success)
                    .font(.system(size: 13, weight: .bold))
            }
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text("Free Games & Weekly Promos")
                        .font(ArcWickyTheme.Typography.sectionHeader)
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                    ArcWickyBadge(text: "EPIC GAMES", tone: .accent)
                }
                Text("Official DRM-free and Epic promotional drops. Claim for free and play natively.")
                    .font(ArcWickyTheme.Typography.caption)
                    .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
            }

            Spacer()

            Button {
                appState.showingItchBrowser = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(ArcWickyTheme.Palette.warning)
                    Text("itch.io Indie Hub")
                }
            }
            .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 26, horizontalPadding: 10))

            Button {
                appState.showingAmazonGames = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "cart.fill")
                        .foregroundStyle(ArcWickyTheme.Palette.accent)
                    Text("Prime Gaming")
                }
            }
            .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 26, horizontalPadding: 10))

            Button {
                if let url = URL(string: "https://www.gog.com/partner/free_games") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "gift")
                        .foregroundStyle(ArcWickyTheme.Palette.violet)
                    Text("GOG Free")
                }
            }
            .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 26, horizontalPadding: 10))

            Button {
                Task {
                    await loadPromotions(force: true)
                    appState.refreshLibrary(forceEpicSync: true)
                }
            } label: {
                if isLoading || appState.isRefreshingLibrary {
                    ProgressView().controlSize(.mini)
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                }
            }
            .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 26, horizontalPadding: 8))
            .help("Refresh promotions and sync library")
            .disabled(isLoading || appState.isRefreshingLibrary)
        }
    }

    private func loadPromotions(force: Bool = false) async {
        isLoading = true
        defer {
            isLoading = false
            hasFetched = true
        }
        freeGames = await EpicPromotionsClient.shared.currentFreeGames(forceRefresh: force)
    }
}

struct FreeGameCard: View {
    let game: EpicFreeGame
    @EnvironmentObject var appState: AppState

    private var matchingLibraryGame: InstalledGame? {
        let normalizedPromo = normalize(game.title)
        guard !normalizedPromo.isEmpty else { return nil }
        return appState.installedGames.first { libGame in
            guard libGame.store == .epic else { return false }
            let normalizedLib = normalize(libGame.name)
            if normalizedLib == normalizedPromo { return true }
            return normalizedLib.contains(normalizedPromo) || normalizedPromo.contains(normalizedLib)
        }
    }

    private func normalize(_ text: String) -> String {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            coverImage
                .frame(width: 210, height: 118)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if game.isUpcoming {
                        ArcWickyBadge(text: "Upcoming", tone: .warning)
                    } else if let matching = matchingLibraryGame {
                        if matching.isInstalled {
                            ArcWickyBadge(text: "Installed", tone: .success)
                        } else {
                            ArcWickyBadge(text: "In Library", tone: .accent)
                        }
                    } else {
                        ArcWickyBadge(text: "Free Now", tone: .success)
                    }

                    if let original = game.originalPrice, !original.isEmpty {
                        Text(original)
                            .font(ArcWickyTheme.Typography.caption)
                            .strikethrough()
                            .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                    }
                    Spacer(minLength: 0)
                }

                Text(game.title)
                    .font(ArcWickyTheme.Typography.bodyBold)
                    .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                    .lineLimit(1)

                if let expiry = game.expiryText {
                    Text(expiry)
                        .font(ArcWickyTheme.Typography.caption)
                        .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                        .lineLimit(1)
                }
            }

            actionsArea
        }
        .padding(12)
        .frame(width: 240)
        .arcWickyCard(cornerRadius: 20, background: ArcWickyTheme.Palette.surfaceElevated)
        .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 6)
    }

    @ViewBuilder
    private var actionsArea: some View {
        if game.isUpcoming {
            HStack {
                Button("Preview on Epic") {
                    NSWorkspace.shared.open(game.storeURL)
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 26, horizontalPadding: 10))
                Spacer()
            }
        } else if let matching = matchingLibraryGame {
            if matching.isInstalled {
                HStack(spacing: 8) {
                    Button {
                        appState.launchGame(matching)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 9))
                            Text("Play")
                        }
                    }
                    .buttonStyle(ArcWickyButtonStyle(variant: .primary, height: 26, horizontalPadding: 12))

                    Spacer()

                    Button("In Library") {
                        appState.selectedLibraryGameId = matching.id
                        appState.section = .library
                    }
                    .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 26, horizontalPadding: 8))
                }
            } else if let dl = appState.gameDownloads[matching.id] {
                HStack(spacing: 8) {
                    ProgressView().controlSize(.small)
                    Text("\(Int(dl.progress * 100))%")
                        .font(ArcWickyTheme.Typography.caption)
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                    Spacer()
                    Button("Downloads") {
                        appState.section = .downloads
                    }
                    .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 26, horizontalPadding: 8))
                }
            } else {
                HStack(spacing: 8) {
                    Button {
                        appState.installEpicGame(matching)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 10))
                            Text("Install")
                        }
                    }
                    .buttonStyle(ArcWickyButtonStyle(variant: .primary, height: 26, horizontalPadding: 12))

                    Spacer()

                    Button("In Library") {
                        appState.selectedLibraryGameId = matching.id
                        appState.section = .library
                    }
                    .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 26, horizontalPadding: 8))
                }
            }
        } else {
            HStack {
                Button("Claim Free") {
                    NSWorkspace.shared.open(game.storeURL)
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .primary, height: 26, horizontalPadding: 12))

                Spacer()

                Button {
                    appState.refreshLibrary(forceEpicSync: true)
                } label: {
                    if appState.isRefreshingLibrary {
                        ProgressView().controlSize(.mini)
                    } else {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.clockwise")
                            Text("Sync")
                        }
                    }
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 26, horizontalPadding: 8))
                .disabled(appState.isRefreshingLibrary)
                .help("Sync library after claiming on Epic Games Store")
            }
        }
    }

    private var coverImage: some View {
        ZStack {
            Color(red: 0.12, green: 0.14, blue: 0.18)

            if let url = game.coverURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .interpolation(.high)
                            .scaledToFill()
                    case .failure:
                        fallbackArt
                    case .empty:
                        ProgressView().controlSize(.small)
                    @unknown default:
                        fallbackArt
                    }
                }
            } else {
                fallbackArt
            }
        }
    }

    private var fallbackArt: some View {
        VStack(spacing: 4) {
            Image(systemName: "gift")
                .font(.system(size: 20))
                .foregroundStyle(ArcWickyTheme.Palette.textMuted)
            Text(game.title)
                .font(ArcWickyTheme.Typography.caption)
                .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                .lineLimit(1)
        }
    }
}
