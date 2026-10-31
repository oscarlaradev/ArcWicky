import SwiftUI
import AppKit
import CaskLauncherCore

struct AmazonGamesSheet: View {
    @ObservedObject var appState: AppState
    @State private var games: [NileGame] = []
    @State private var isSyncing: Bool = false
    @State private var errorMessage: String?
    @State private var isLoggedIn: Bool = false
    @State private var isNileAvailable: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: VermutSpace.s6) {
                    primeWeeklyPromoBanner
                    nileStatusCard
                    gamesSection
                }
                .padding(VermutSpace.s6)
            }
        }
        .frame(minWidth: 540, minHeight: 480)
        .background(ArcWickyTheme.Palette.obsidianBase)
        .onAppear {
            refreshStatus()
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: VermutSpace.s1) {
                HStack(spacing: VermutSpace.s2) {
                    Image(systemName: "cart.fill")
                        .foregroundStyle(Color.Vermut.info)
                    Text("Amazon Games & Prime Gaming")
                        .font(VermutType.headline)
                        .foregroundStyle(Color.Vermut.foreground)
                }
                Text("Claim weekly free games from Prime Gaming and sync your Amazon catalog with Nile.")
                    .font(VermutType.captionRegular)
                    .foregroundStyle(Color.Vermut.mutedForeground)
            }
            Spacer()
            Button("Done") {
                appState.showingAmazonGames = false
            }
            .buttonStyle(VermutButtonStyle(kind: .outline, height: VermutHeight.buttonSmall))
        }
        .padding(VermutSpace.s6)
    }

    private var primeWeeklyPromoBanner: some View {
        VStack(alignment: .leading, spacing: VermutSpace.s3) {
            HStack(spacing: VermutSpace.s2) {
                Image(systemName: "gift.fill")
                    .foregroundStyle(Color.Vermut.amber)
                Text("Prime Gaming Weekly Drops")
                    .font(VermutType.bodyEmphasis)
                    .foregroundStyle(Color.Vermut.foreground)
                Spacer()
                VermutBadge(kind: .warning, text: "Weekly Free", showsDot: false)
            }

            Text("Prime Gaming gives away free full PC games every week for subscribers. Claim them in your browser to add them permanently to your account.")
                .font(VermutType.captionRegular)
                .foregroundStyle(Color.Vermut.mutedForeground)

            Button {
                if let url = URL(string: "https://gaming.amazon.com/home") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                HStack(spacing: VermutSpace.s1) {
                    Text("Claim Free Games on Prime Gaming")
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11))
                }
            }
            .buttonStyle(VermutButtonStyle(kind: .primary, height: VermutHeight.buttonSmall))
        }
        .padding(VermutSpace.s4)
        .background(Color.Vermut.card)
        .clipShape(RoundedRectangle(cornerRadius: VermutRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: VermutRadius.md)
                .strokeBorder(Color.Vermut.border, lineWidth: 1)
        )
    }

    private var nileStatusCard: some View {
        VStack(alignment: .leading, spacing: VermutSpace.s3) {
            HStack {
                Text("Nile Open-Source Integration")
                    .font(VermutType.bodyEmphasis)
                    .foregroundStyle(Color.Vermut.foreground)
                Spacer()
                if isLoggedIn {
                    VermutBadge(kind: .success, text: "Signed In", showsDot: true)
                } else if isNileAvailable {
                    VermutBadge(kind: .neutral, text: "CLI Ready", showsDot: false)
                } else {
                    VermutBadge(kind: .neutral, text: "Optional", showsDot: false)
                }
            }

            Text("Nile is an open-source Amazon Games client (like Legendary for Epic Games) that enables native downloading and launching.")
                .font(VermutType.captionRegular)
                .foregroundStyle(Color.Vermut.mutedForeground)

            HStack(spacing: VermutSpace.s3) {
                if isNileAvailable {
                    Button(isSyncing ? "Syncing…" : "Sync Amazon Library") {
                        syncNile()
                    }
                    .buttonStyle(VermutButtonStyle(kind: .outline, height: VermutHeight.buttonSmall))
                    .disabled(isSyncing)
                } else {
                    Button("Download Nile (GitHub)") {
                        if let url = URL(string: "https://github.com/imLinguin/nile/releases") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(VermutButtonStyle(kind: .outline, height: VermutHeight.buttonSmall))
                }

                Button("Nile Documentation") {
                    if let url = URL(string: "https://github.com/imLinguin/nile") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(VermutButtonStyle(kind: .ghost, height: VermutHeight.buttonSmall))
            }
        }
        .padding(VermutSpace.s4)
        .background(Color.Vermut.card)
        .clipShape(RoundedRectangle(cornerRadius: VermutRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: VermutRadius.md)
                .strokeBorder(Color.Vermut.border, lineWidth: 1)
        )
    }

    private var gamesSection: some View {
        VStack(alignment: .leading, spacing: VermutSpace.s3) {
            HStack {
                Text("Your Amazon Games (\(games.count))")
                    .font(VermutType.bodyEmphasis)
                    .foregroundStyle(Color.Vermut.foreground)
                Spacer()
            }

            if games.isEmpty {
                VStack(spacing: VermutSpace.s2) {
                    Text("No local Amazon Games detected yet.")
                        .font(VermutType.captionRegular)
                        .foregroundStyle(Color.Vermut.mutedForeground)
                    Text("Claim weekly titles on Prime Gaming or install DRM-free Amazon installers via Run .exe.")
                        .font(VermutType.captionRegular)
                        .foregroundStyle(Color.Vermut.mutedForeground)
                }
                .frame(maxWidth: .infinity)
                .padding(VermutSpace.s6)
                .background(Color.Vermut.surface)
                .clipShape(RoundedRectangle(cornerRadius: VermutRadius.md))
            } else {
                LazyVStack(spacing: VermutSpace.s2) {
                    ForEach(games) { game in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(game.title)
                                    .font(VermutType.bodyEmphasis)
                                    .foregroundStyle(Color.Vermut.foreground)
                                if let path = game.installPath {
                                    Text(path)
                                        .font(VermutType.captionRegular)
                                        .foregroundStyle(Color.Vermut.mutedForeground)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            if game.isInstalled {
                                VermutBadge(kind: .success, text: "Installed", showsDot: true)
                            } else {
                                VermutBadge(kind: .neutral, text: "Owned", showsDot: false)
                            }
                        }
                        .padding(VermutSpace.s3)
                        .background(Color.Vermut.surface)
                        .clipShape(RoundedRectangle(cornerRadius: VermutRadius.sm))
                    }
                }
            }
        }
    }

    private func refreshStatus() {
        isNileAvailable = NileManager.shared.isNileAvailable()
        isLoggedIn = NileManager.shared.isUserLoggedIn()
        games = NileManager.shared.cachedLibraryGames()
    }

    private func syncNile() {
        isSyncing = true
        Task {
            do {
                let fetched = try await NileManager.shared.syncLibrary()
                await MainActor.run {
                    self.games = fetched
                    self.isSyncing = false
                    refreshStatus()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isSyncing = false
                }
            }
        }
    }
}

