import SwiftUI
import CaskLauncherCore

// MARK: - Screen: Game Platforms & Stores
// Spatial Cartoon Storefront Hub for Apple Silicon Wine gaming.
struct StoresView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // SECTION 1: Spatial Header
                headerSection

                // SECTION 2: Storefront Platforms Grid (Steam, Epic, GOG, itch.io, Amazon, .EXE)
                storeGridSection

                // SECTION 3: Live Epic Games Free Weekly Loot
                FreeGamesPromoSection()

                // SECTION 4: Quick Storefront Operations Tray
                storeOperationsDeck
            }
            .padding(.horizontal, 36)
            .padding(.top, 24)
            .padding(.bottom, 140) // High clearance for bottom floating dock
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(ArcWickyTheme.Palette.canvas)
        .onAppear {
            appState.refreshBottleMetrics()
        }
    }

    // MARK: - 1. Spatial Header
    private var headerSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(ArcWickyTheme.Palette.accentMint)
                        .frame(width: 8, height: 8)
                        .shadow(color: ArcWickyTheme.Palette.accentMint, radius: 4)

                    Text("STORE PLATFORMS & CLOUD RUNTIMES")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                        .tracking(1.4)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(Capsule().fill(ArcWickyTheme.Palette.surfaceContainerLow))
                .overlay(Capsule().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5))

                Text("GAME STORES & REPOSITORIES")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                    .rotationEffect(.degrees(-0.8))
                    .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 4)

                Text("Connect PC game store accounts and run Windows installers in isolated 64-bit Wine prefixes with Metal 3 acceleration.")
                    .font(ArcWickyTheme.Typography.body)
                    .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                    .frame(maxWidth: 640)
            }

            Spacer(minLength: 24)

            HStack(spacing: 10) {
                Button {
                    appState.showingFilePicker = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .black))
                        Text("+ Add Game .EXE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                }
                .buttonStyle(ArcWickyToyPlayButtonStyle())

                Button {
                    appState.showingNewBottleSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 12))
                        Text("New Bottle")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 38, horizontalPadding: 14))
            }
        }
    }

    // MARK: - 2. Storefront Grid (Structured by Platform Tiers)
    private var storeGridSection: some View {
        VStack(alignment: .leading, spacing: 26) {
            // Tier 1: Primary PC Game Launchers (Steam & Epic Games)
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Circle().fill(ArcWickyTheme.Palette.accentMint).frame(width: 6, height: 6)
                    Text("PRIMARY PC GAME LAUNCHERS")
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                        .tracking(1.2)
                }

                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 380, maximum: 600), spacing: 20)
                    ],
                    spacing: 20
                ) {
                    ArcWickyStoreCard(store: .steam)
                    ArcWickyStoreCard(store: .epic)
                }
            }

            // Tier 2: DRM-Free & Indie Repositories (GOG, itch.io, Amazon Games)
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Circle().fill(ArcWickyTheme.Palette.accent).frame(width: 6, height: 6)
                    Text("DRM-FREE & INDIE PLATFORMS")
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                        .tracking(1.2)
                }

                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 280, maximum: 400), spacing: 20)
                    ],
                    spacing: 20
                ) {
                    ArcWickyStoreCard(store: .gog)
                    itchIoStoreCard
                    amazonGamesStoreCard
                }
            }

            // Tier 3: Standalone .EXE & Custom Wine Bottles
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Circle().fill(ArcWickyTheme.Palette.success).frame(width: 6, height: 6)
                    Text("CUSTOM PREFIXES & STANDALONE .EXE")
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                        .tracking(1.2)
                }

                directExeStoreCard
            }
        }
    }

    // MARK: - Custom Store Cards
    private var itchIoStoreCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(hex: "#FA5C5C"))
                        .frame(width: 44, height: 44)
                        .shadow(color: Color(hex: "#FA5C5C").opacity(0.35), radius: 6)

                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("itch.io")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)

                    ArcWickyBadge(text: "Indie Hub Ready", tone: .accent)
                }

                Spacer()
            }

            Text("Browse thousands of indie games, game jams, and DRM-free Windows titles directly on Apple Silicon.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider().overlay(ArcWickyTheme.Palette.border)

            HStack {
                Text("Native itch.io API · DRM-Free")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                Spacer()
            }

            Button {
                appState.showingItchBrowser = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12, weight: .bold))
                    Text("Browse itch.io")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 38))
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

    private var amazonGamesStoreCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#00A8E1"), Color(hex: "#005580")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: Color(hex: "#00A8E1").opacity(0.35), radius: 6)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Amazon Games")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)

                    ArcWickyBadge(text: "Prime Gaming", tone: .accent)
                }

                Spacer()
            }

            Text("Sync claimed Prime Gaming library via open-source Nile CLI and download directly into Wine bottles.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider().overlay(ArcWickyTheme.Palette.border)

            HStack {
                Text("Nile Engine · Prime Loot")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                Spacer()
            }

            Button {
                appState.showingAmazonGames = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 12, weight: .bold))
                    Text("Manage Amazon Games")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 38))
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

    private var directExeStoreCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [ArcWickyTheme.Palette.accentMint, ArcWickyTheme.Palette.accentDeep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: ArcWickyTheme.Palette.accentMint.opacity(0.35), radius: 6)

                    Image(systemName: "plus.square.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(ArcWickyTheme.Palette.onPrimaryFixed)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Standalone .EXE")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)

                    ArcWickyBadge(text: "Universal Windows", tone: .success)
                }

                Spacer()
            }

            Text("Run any Windows game installer, portable executable (.exe / .msi), or custom setup in an isolated bottle.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider().overlay(ArcWickyTheme.Palette.border)

            HStack {
                Text("Direct Launch · D3DMetal & DXMT")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                Spacer()
            }

            Button {
                appState.showingFilePicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 12, weight: .bold))
                    Text("Choose Executable…")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 38))
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

    // MARK: - 4. Operations Deck
    private var storeOperationsDeck: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("STOREFRONT QUICK TOOLS & RUNTIMES")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                .tracking(1.2)

            HStack(spacing: 12) {
                quickToolButton(title: "Winetricks & Dependencies", icon: "cube.box.fill") {
                    appState.openDependencies(for: .steam)
                }

                quickToolButton(title: "Wine Configuration (winecfg)", icon: "gearshape.fill") {
                    appState.openWinecfg(for: .steam)
                }

                quickToolButton(title: "Rescan Store Libraries", icon: "arrow.triangle.2.circlepath") {
                    appState.refreshLibrary(forceEpicSync: true)
                }

                quickToolButton(title: "DRM-Free Installer Wizard", icon: "opticaldisc.fill") {
                    appState.showingDrmInstaller = true
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(ArcWickyTheme.Palette.surfaceContainerLow)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
        )
        .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 4)
    }

    private func quickToolButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(ArcWickyTheme.Palette.accentMint)

                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(ArcWickyTheme.Palette.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Spatial Store Card Component (Steam, Epic, GOG)
struct ArcWickyStoreCard: View {
    let store: GameStore
    @EnvironmentObject var appState: AppState

    var status: StoreStatus { appState.status(for: store) }
    var presentation: StoreStatusPresentation {
        .from(status, store: store, epicAccount: appState.epicAccount)
    }

    private var bottleConfig: BottleConfiguration {
        StoreRecipe.normalized(appState.loadBottle(store), for: store)
    }

    private var sizeLine: String {
        let size = appState.bottleSizes[store] ?? 0
        return size > 0 ? ByteFormat.string(size) : "No prefix data"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack(alignment: .top) {
                StoreLogoTile(store: store, size: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text(store.rawValue)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)

                    ArcWickyBadge(
                        text: presentation.text,
                        tone: presentation.kind == .success ? .success : (presentation.kind == .warning ? .warning : .accent),
                        showDot: presentation.showsDot
                    )
                }

                Spacer()

                Menu {
                    Button("Open Bottle Details") { appState.section = .bottle(store) }
                    Button("Show C: Drive in Finder") { appState.openCDrive(for: store) }
                    Button("View Wine Logs") { appState.openLogs(for: store) }
                    Button("Install Dependencies (Winetricks)…") { appState.openDependencies(for: store) }
                    Divider()
                    Button("Clear Shader Cache") {
                        let prefix = PathManager.shared.prefixURL(for: store)
                        ShaderCacheManager.shared.clearShaderCaches(prefixURL: prefix)
                    }
                    Divider()
                    Button("Reset Bottle…", role: .destructive) {
                        appState.bottleToDelete = store
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(ArcWickyTheme.Palette.surfaceElevated))
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
            }

            // Description
            Text(descriptionCopy)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            if status.isInstallInProgress {
                StoreInstallControls(store: store, status: status)
            }

            Divider().overlay(ArcWickyTheme.Palette.border)

            // Technical Specs
            VStack(alignment: .leading, spacing: 2) {
                Text(BottleLabels.engineLine(bottleConfig))
                Text(BottleLabels.graphicsLine(bottleConfig, store: store))
                Text("Bottle Size: \(sizeLine)")
            }
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(ArcWickyTheme.Palette.textMuted)

            // Action Buttons
            cardActions
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

    private var descriptionCopy: String {
        switch status {
        case .downloading, .installing:
            return store.installingCopy
        case .error(let message):
            return message
        default:
            if store == .epic, appState.epicAccount != nil {
                return EpicStoreCopy.signedInDescription
            }
            return store.blurb
        }
    }

    @ViewBuilder
    private var cardActions: some View {
        if store == .epic {
            epicCardActions
        } else {
            standardStoreCardActions
        }
    }

    @ViewBuilder
    private var epicCardActions: some View {
        switch status {
        case .notInstalled:
            Button("Sign in with Epic") { appState.signInEpic() }
                .buttonStyle(ArcWickyToyPlayButtonStyle())

        case .downloading, .installing:
            EmptyView()

        case .installed, .running:
            if let account = appState.epicAccount {
                VStack(spacing: 8) {
                    Button {
                        appState.openEpicLibraryOrSignIn()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.system(size: 12))
                            Text("Open Epic Library")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ArcWickyButtonStyle(variant: .primary, height: 38))

                    HStack {
                        Text(account.displayName)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                            .lineLimit(1)
                        Spacer()
                        Button("Log out") { appState.logoutEpic() }
                            .buttonStyle(.plain)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                    }
                }
            } else {
                Button("Sign in with Epic") { appState.signInEpic() }
                    .buttonStyle(ArcWickyToyPlayButtonStyle())
            }

        case .error:
            HStack(spacing: 8) {
                Button("Retry") { appState.signInEpic() }
                    .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 36))
                Button("Logs") { appState.openLogs(for: store) }
                    .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 36))
            }
        }
    }

    @ViewBuilder
    private var standardStoreCardActions: some View {
        switch status {
        case .notInstalled:
            Button("Install \(store.rawValue)") { appState.installStore(store) }
                .buttonStyle(ArcWickyToyPlayButtonStyle())

        case .downloading, .installing:
            EmptyView()

        case .installed:
            HStack(spacing: 10) {
                Button(store.openTitle) { appState.launchStore(store) }
                    .buttonStyle(ArcWickyButtonStyle(variant: .primary, height: 38))

                Button {
                    appState.section = .bottle(store)
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(ArcWickyTheme.Palette.surfaceElevated))
                        .overlay(Circle().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5))
                }
                .buttonStyle(.plain)
                .help("Bottle Options")
            }

        case .running:
            HStack(spacing: 10) {
                Button(store.openTitle) { appState.launchStore(store) }
                    .buttonStyle(ArcWickyButtonStyle(variant: .primary, height: 38))

                Button {
                    appState.stopStore(store)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 10))
                        Text("Stop")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .destructive, height: 38, horizontalPadding: 14))
            }

        case .error:
            HStack(spacing: 8) {
                Button("Retry") { appState.retryStore(store) }
                    .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 36))
                Button("Logs") { appState.openLogs(for: store) }
                    .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 36))
            }
        }
    }
}
