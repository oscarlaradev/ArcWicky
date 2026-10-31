import SwiftUI
import AppKit
import CaskLauncherCore

enum LibraryViewMode: String, CaseIterable {
    case grid = "Grid"
    case list = "List"
}

enum LibraryFilterSelection: Equatable {
    case all
    case installed
    case store(GameStore)
}

struct LibraryView: View {
    @EnvironmentObject var appState: AppState
    @State private var filter: LibraryFilterSelection = .all
    @State private var viewMode: LibraryViewMode = .grid
    @State private var spotlightIndex: Int = 0
    @State private var showFullLibraryDrawer: Bool = false
    @State private var showingShowcaseSheet: Bool = false
    @State private var showcaseSheetTitle: String = ""

    private var activeCarouselList: [InstalledGame] {
        games
    }

    private var games: [InstalledGame] {
        let query = appState.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return appState.installedGames
            .filter { game in
                switch filter {
                case .all: return true
                case .installed: return game.isInstalled
                case .store(let store): return game.store == store
                }
            }
            .filter { game in
                query.isEmpty || game.name.lowercased().contains(query)
            }
    }

    private var runningGame: InstalledGame? {
        appState.installedGames.first(where: { appState.isGameRunning($0) })
    }

    private var steamCount: Int { appState.installedGames.filter { $0.store == .steam }.count }
    private var epicCount: Int { appState.installedGames.filter { $0.store == .epic }.count }
    private var gogCount: Int { appState.installedGames.filter { $0.store == .gog }.count }
    private var installedCount: Int { appState.installedGames.filter { $0.isInstalled }.count }

    private var inspectorPresented: Binding<Bool> {
        Binding(
            get: { appState.showingGameSettingsInspector && appState.selectedLibraryGame != nil },
            set: { appState.showingGameSettingsInspector = $0 }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                // Radial Atmosphere & Soft Spatial Stage Floor Glow
                ZStack {
                    Circle()
                        .fill(ArcWickyTheme.Palette.accent.opacity(0.06))
                        .frame(width: 800, height: 500)
                        .blur(radius: 80)
                        .offset(y: -40)

                    // 1. Screen 2: Stage Spotlight & Orbital Carousel
                    stageSpotlightSection
                }

                // Drawer Toggle / Compact Library Access Bar
                HStack(spacing: 14) {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showFullLibraryDrawer.toggle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: showFullLibraryDrawer ? "chevron.up.circle.fill" : "square.grid.2x2.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(ArcWickyTheme.Palette.accentMint)

                            Text(showFullLibraryDrawer ? "Hide Library Shelf" : "Browse All Installed Games (\(appState.installedGames.count))")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(ArcWickyTheme.Palette.surfaceContainerLow))
                        .overlay(Capsule().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5))
                        .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)

                if showFullLibraryDrawer {
                    VStack(alignment: .leading, spacing: 20) {
                        // 2. Control Bar (Filters, View Mode, Sync)
                        controlsStrip

                        // 3. Games Grid or Table
                        if games.isEmpty {
                            emptyState
                        } else {
                            if viewMode == .grid {
                                gamesGrid
                            } else {
                                gamesTable
                            }
                        }
                    }
                    .padding(.top, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            .padding(.bottom, 140) // Generous clearance for floating console dock
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(ArcWickyTheme.Palette.canvas)
        .inspector(isPresented: inspectorPresented) {
            if let game = appState.selectedLibraryGame {
                GameSettingsInspector(game: game)
                    .inspectorColumnWidth(min: 340, ideal: 380, max: 440)
            } else {
                Text("Select a game to configure graphics and compatibility.")
                    .font(ArcWickyTheme.Typography.body)
                    .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                    .padding(20)
                    .inspectorColumnWidth(min: 340, ideal: 380, max: 440)
            }
        }
        .sheet(isPresented: $showingShowcaseSheet) {
            showcaseSheetView
        }
        .onAppear {
            appState.refreshLibrary(forceEpicSync: false)
            if let store = appState.libraryFilterStore {
                filter = .store(store)
                appState.libraryFilterStore = nil
            }
        }
    }

    // MARK: - Showcase Interactive Action Sheet
    private var showcaseSheetView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(ArcWickyTheme.Palette.accentMint.opacity(0.15))
                    .frame(width: 64, height: 64)

                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(ArcWickyTheme.Palette.accentMint)
            }
            .padding(.top, 12)

            VStack(spacing: 6) {
                Text(showcaseSheetTitle.isEmpty ? "Stage Spotlight Title" : showcaseSheetTitle)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                    .multilineTextAlignment(.center)

                Text("This game is in your Stage Spotlight showcase. To launch, connect your game store or add a Windows executable setup.")
                    .font(ArcWickyTheme.Typography.caption)
                    .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            VStack(spacing: 10) {
                Button {
                    showingShowcaseSheet = false
                    appState.showingFilePicker = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Game Executable (.exe)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .primary, height: 42))

                Button {
                    showingShowcaseSheet = false
                    appState.section = .stores
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "storefront.fill")
                        Text("Open Storefronts & Cloud Loot")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 42))

                Button("Dismiss") {
                    showingShowcaseSheet = false
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .frame(width: 420)
        .padding(16)
        .background(ArcWickyTheme.Palette.surface)
    }

    private var safeSpotlightIndex: Int {
        let list = activeCarouselList
        guard !list.isEmpty else { return 0 }
        return list.indices.contains(spotlightIndex) ? spotlightIndex : 0
    }

    private var currentFeaturedGame: InstalledGame? {
        let list = activeCarouselList
        guard !list.isEmpty else { return nil }
        return runningGame ?? list[safeSpotlightIndex]
    }

    // MARK: - Screen 2: Stage Spotlight & Orbital Carousel
    @ViewBuilder
    private var stageSpotlightSection: some View {
        if let featured = currentFeaturedGame {
            let activeList = activeCarouselList
            let safeIndex = safeSpotlightIndex
            VStack(spacing: 16) {
                // Header Badge
                spotlightHeaderBadge(safeIndex: safeIndex, count: activeList.count)

                // Cartoon Inflatable Vinyl Title
                spotlightTitle(featured: featured)

                // Orbital Carousel Row with Interactive Arrows & Dragging
                HStack(alignment: .center, spacing: 20) {
                    // Left Chevron Button
                    if activeList.count > 1 {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                spotlightIndex = (safeIndex - 1 + activeList.count) % activeList.count
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .black))
                                .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                                .frame(width: 42, height: 42)
                                .background(Circle().fill(ArcWickyTheme.Palette.surfaceElevated))
                                .overlay(Circle().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5))
                                .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        .help("Previous Game (Left Arrow)")
                    }

                    if activeList.count > 1, let prev = activeList[safe: safeIndex - 1] ?? activeList.last {
                        ghostedCard(prev, slot: max(safeIndex, 1)) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                spotlightIndex = (safeIndex - 1 + activeList.count) % activeList.count
                            }
                        }
                    }

                    activeToyCard(featured)
                        .gesture(
                            DragGesture(minimumDistance: 25)
                                .onEnded { value in
                                    if value.translation.width < -30 && activeList.count > 1 {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                            spotlightIndex = (safeIndex + 1) % activeList.count
                                        }
                                    } else if value.translation.width > 30 && activeList.count > 1 {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                            spotlightIndex = (safeIndex - 1 + activeList.count) % activeList.count
                                        }
                                    }
                                }
                        )

                    if activeList.count > 1, let next = activeList[safe: safeIndex + 1] ?? activeList.first {
                        ghostedCard(next, slot: ((safeIndex + 1) % activeList.count) + 1) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                spotlightIndex = (safeIndex + 1) % activeList.count
                            }
                        }
                    }

                    // Right Chevron Button
                    if activeList.count > 1 {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                spotlightIndex = (safeIndex + 1) % activeList.count
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 15, weight: .black))
                                .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                                .frame(width: 42, height: 42)
                                .background(Circle().fill(ArcWickyTheme.Palette.surfaceElevated))
                                .overlay(Circle().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5))
                                .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        .help("Next Game (Right Arrow)")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

                // Specification Capsule
                spotlightSpecCapsule(featured: featured)

                // Master Launch Button with generous bottom breathing room
                spotlightPlayButton(featured: featured)

                // Bottom Spatial Bar
                spotlightBottomBar(featured: featured, activeList: activeList, safeIndex: safeIndex)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        } else {
            stageSpotlightEmptyState
        }
    }

    // MARK: - Empty Playground State
    private var stageSpotlightEmptyState: some View {
        VStack(spacing: 20) {
            if !appState.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(ArcWickyTheme.Palette.accentMint)

                    Text("NO GAMES FOUND FOR \"\(appState.searchQuery.uppercased())\"")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                        .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 4)

                    Text("We couldn't find any installed game matching your search term. Check spelling or discover games in Stores.")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 480)

                    Button("Clear Search Filter") {
                        appState.searchQuery = ""
                    }
                    .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 38, horizontalPadding: 18))
                    .padding(.top, 4)
                }
                .padding(.vertical, 40)
            } else {
                // Header Badge
                HStack(spacing: 8) {
                    Circle()
                        .fill(ArcWickyTheme.Palette.accentMint)
                        .frame(width: 8, height: 8)
                        .shadow(color: ArcWickyTheme.Palette.accentMint, radius: 4)

                    Text("STAGE SPOTLIGHT • READY FOR ADVENTURE")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                        .tracking(1.4)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(Capsule().fill(ArcWickyTheme.Palette.surfaceContainerLow))
                .overlay(Capsule().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5))

                // Cartoon Title
                VStack(spacing: 6) {
                    Text("YOUR TOY-BOX IS WAITING")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                        .rotationEffect(.degrees(-1.0))
                        .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 4)

                    Text("Only installed games appear here with full native Wine telemetry. Connect your favorite stores or install a Windows .EXE to start playing!")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 540)
                }

                // Tactile Chamber Card
                VStack(spacing: 16) {
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
                            .frame(width: 320, height: 240)
                            .overlay(
                                RoundedRectangle(cornerRadius: 32, style: .continuous)
                                    .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 2)
                            )
                            .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 8)
                            .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)

                        VStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(ArcWickyTheme.Palette.surface)
                                    .frame(width: 80, height: 80)
                                    .overlay(Circle().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5))
                                    .shadow(color: ArcWickyTheme.Palette.accentMint.opacity(0.15), radius: 10)

                                Image(systemName: "shippingbox.and.arrow.backward.fill")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [ArcWickyTheme.Palette.accentMint, ArcWickyTheme.Palette.accent],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }

                            VStack(spacing: 4) {
                                Text("NO GAMES INSTALLED YET")
                                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                                    .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                                    .tracking(1.0)

                                Text("Apple Silicon \(HostInfo.chipName) Ready")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                            }
                        }
                    }

                    // Action Buttons Row
                    HStack(spacing: 16) {
                        Button {
                            appState.showingFilePicker = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 13, weight: .black))
                                Text("+ Add Game .EXE")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                        }
                        .buttonStyle(ArcWickyToyPlayButtonStyle())

                        Button {
                            appState.section = .stores
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "storefront.fill")
                                    .font(.system(size: 13))
                                Text("Connect Game Stores")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                        }
                        .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 44, horizontalPadding: 18))
                    }
                    .padding(.top, 6)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private func spotlightHeaderBadge(safeIndex: Int, count: Int) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(ArcWickyTheme.Palette.accentMint)
                .frame(width: 8, height: 8)
                .shadow(color: ArcWickyTheme.Palette.accentMint, radius: 4)

            Text("STAGE SPOTLIGHT • SLOT \(String(format: "%02d", min(safeIndex + 1, count))) OF \(String(format: "%02d", max(count, 1)))")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                .tracking(1.4)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 5)
        .background(Capsule().fill(ArcWickyTheme.Palette.surfaceContainerLow))
        .overlay(Capsule().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5))
    }

    @ViewBuilder
    private func spotlightTitle(featured: InstalledGame) -> some View {
        VStack(spacing: 4) {
            Text(featured.name.uppercased())
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                .rotationEffect(.degrees(-1.0))
                .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 4)
                .lineLimit(1)

            Text("\(featured.store.rawValue) • Native macOS Wine Bottle • \(HostInfo.chipName)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                .tracking(1.2)
        }
    }

    private func spotlightSpecCapsule(featured: InstalledGame) -> some View {
        HStack(spacing: 10) {
            specPill("Wine 11 Engine", dot: true, color: ArcWickyTheme.Palette.accentMint)
            specPill("60 FPS Smooth", icon: "waveform.path.ecg", color: ArcWickyTheme.Palette.textSecondary)
            specPill("\(featured.store.rawValue) Bottle", icon: "shippingbox.fill", color: ArcWickyTheme.Palette.textSecondary)
            specPill(HostInfo.gpuName, dot: true, color: ArcWickyTheme.Palette.accentMint)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Capsule().fill(ArcWickyTheme.Palette.surface))
        .overlay(Capsule().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5))
    }

    private func spotlightPlayButton(featured: InstalledGame) -> some View {
        VStack(spacing: 0) {
            Button {
                if appState.isGameRunning(featured) {
                    appState.stopGame(featured)
                } else {
                    appState.launchGame(featured)
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: appState.isGameRunning(featured) ? "stop.fill" : "play.fill")
                        .font(.system(size: 18, weight: .black))
                    Text(appState.isGameRunning(featured) ? "STOPPING..." : "PLAY!")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                }
            }
            .buttonStyle(ArcWickyToyPlayButtonStyle())

            // Generously spaced instruction text below the button
            Text("Press Controller ✕ or Return to Launch")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                .tracking(1.2)
                .padding(.top, 16)
        }
        .padding(.top, 10)
    }

    private func spotlightBottomBar(featured: InstalledGame, activeList: [InstalledGame], safeIndex: Int) -> some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "display")
                    .font(.system(size: 12))
                    .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                Text("Display: Liquid Retina XDR (120Hz ProMotion)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().fill(ArcWickyTheme.Palette.surfaceContainerLow))

            Spacer()

            HStack(spacing: 6) {
                ForEach(0..<min(activeList.count, 7), id: \.self) { idx in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            spotlightIndex = idx
                        }
                    } label: {
                        if idx == safeIndex {
                            Capsule()
                                .fill(ArcWickyTheme.Palette.accentMint)
                                .frame(width: 24, height: 8)
                                .shadow(color: ArcWickyTheme.Palette.accentMint, radius: 4)
                        } else {
                            Circle()
                                .fill(ArcWickyTheme.Palette.border)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().fill(ArcWickyTheme.Palette.surfaceContainerLow))

            Spacer()

            Button {
                appState.openGameSettings(for: featured)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 12))
                    Text("Bottle Config")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                .background(Capsule().fill(ArcWickyTheme.Palette.surfaceContainerLow))
                .overlay(Capsule().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
        .frame(maxWidth: 820)
    }

    private func activeToyCard(_ game: InstalledGame) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                LibraryCoverView(game: game)
                    .frame(width: 300, height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )

                // Vinyl Gloss Badge
                HStack(spacing: 5) {
                    Circle()
                        .fill(ArcWickyTheme.Palette.accentMint)
                        .frame(width: 6, height: 6)
                    Text("Master Edition")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule().fill(ArcWickyTheme.Palette.surface.opacity(0.85))
                )
                .padding(12)

                // Certified Badge
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                            Text("Apple Silicon \(HostInfo.chipName) Verified")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(ArcWickyTheme.Palette.surface.opacity(0.9)))
                        .padding(12)
                    }
                }
            }
            .frame(width: 300, height: 360)

            // Bottom Meta Tray
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("LAST SESSION")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                    Text(game.isInstalled ? "Ready • 2.4 hrs" : "In Library")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                }
                Spacer()
                HStack(spacing: 5) {
                    Image(systemName: "icloud.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                    Text("Cloud Synced")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(ArcWickyTheme.Palette.surfaceElevated))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(ArcWickyTheme.Palette.surface)
        }
        .frame(width: 300)
        .background(ArcWickyTheme.Palette.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.6), radius: 24, x: 0, y: 14)
        .shadow(color: ArcWickyTheme.Palette.accentMint.opacity(0.12), radius: 20, x: 0, y: 0)
    }

    private func ghostedCard(_ game: InstalledGame, slot: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .bottomLeading) {
                    LibraryCoverView(game: game)
                        .frame(width: 180, height: 230)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(game.name)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                            .lineLimit(1)
                        Text(game.store.rawValue)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ArcWickyTheme.Palette.canvas.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(6)
                }
                .frame(width: 180, height: 230)
                .background(ArcWickyTheme.Palette.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1)
                )

                Text("Slot \(String(format: "%02d", slot))")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(ArcWickyTheme.Palette.textMuted)
            }
            .opacity(0.28)
            .scaleEffect(0.92)
        }
        .buttonStyle(.plain)
    }

    private func specPill(_ text: String, dot: Bool = false, icon: String? = nil, color: Color) -> some View {
        HStack(spacing: 6) {
            if dot {
                Circle().fill(color).frame(width: 6, height: 6)
            } else if let icon {
                Image(systemName: icon).font(.system(size: 10)).foregroundStyle(color)
            }
            Text(text)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(ArcWickyTheme.Palette.surfaceElevated))
    }

    // MARK: - Active Session Hero
    private func activeSessionHero(_ game: InstalledGame) -> some View {
        HStack(spacing: 20) {
            // Game Art
            LibraryCoverView(game: game)
                .frame(width: 80, height: 105)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(ArcWickyTheme.Palette.success.opacity(0.4), lineWidth: 1.5)
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    ArcWickyBadge(text: "SESSION RUNNING", tone: .success)
                    StoreLogoTile(store: game.store, size: 14)
                    Text(game.store.rawValue)
                        .font(ArcWickyTheme.Typography.caption)
                        .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                }

                Text(game.name)
                    .font(ArcWickyTheme.Typography.title)
                    .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    Label("Direct3D / Metal Active", systemImage: "bolt.fill")
                        .font(ArcWickyTheme.Typography.caption)
                        .foregroundStyle(ArcWickyTheme.Palette.textSecondary)

                    Label("Engine Ready", systemImage: "checkmark.circle.fill")
                        .font(ArcWickyTheme.Typography.caption)
                        .foregroundStyle(ArcWickyTheme.Palette.success)
                }
            }

            Spacer()

            // Controls
            HStack(spacing: 10) {
                Button {
                    appState.openLogs(for: game.store)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "terminal")
                        Text("Wine Logs")
                    }
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 32, horizontalPadding: 14))

                Button {
                    appState.openGameSettings(for: game)
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .help("Game Settings Inspector")

                Button {
                    appState.stopGame(game)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 11))
                        Text("Stop Game")
                            .font(ArcWickyTheme.Typography.bodyBold)
                    }
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .destructive, height: 32, horizontalPadding: 16))
            }
        }
        .padding(18)
        .arcWickyCard(cornerRadius: 12, background: ArcWickyTheme.Palette.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(ArcWickyTheme.Palette.success.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Quick Resume Hero (When no game running)
    private func quickResumeHero(_ game: InstalledGame) -> some View {
        HStack(spacing: 20) {
            LibraryCoverView(game: game)
                .frame(width: 64, height: 85)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("QUICK LAUNCH")
                    .font(ArcWickyTheme.Typography.captionMedium)
                    .foregroundStyle(ArcWickyTheme.Palette.accent)
                    .tracking(0.8)

                Text(game.name)
                    .font(ArcWickyTheme.Typography.title)
                    .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 10) {
                    StoreLogoTile(store: game.store, size: 14)
                    Text(game.store.rawValue)
                        .font(ArcWickyTheme.Typography.caption)
                        .foregroundStyle(ArcWickyTheme.Palette.textSecondary)

                    Text("•")
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)

                    Text(game.isInstalled ? "Installed & Ready" : "Available in Library")
                        .font(ArcWickyTheme.Typography.caption)
                        .foregroundStyle(game.isInstalled ? ArcWickyTheme.Palette.success : ArcWickyTheme.Palette.textSecondary)
                }
            }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    appState.openGameSettings(for: game)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Settings")
                    }
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 32, horizontalPadding: 12))

                if game.isInstalled {
                    Button {
                        appState.launchGame(game)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 11))
                            Text("Play")
                                .font(ArcWickyTheme.Typography.bodyBold)
                        }
                    }
                    .buttonStyle(ArcWickyButtonStyle(variant: .primary, height: 32, horizontalPadding: 20))
                } else if game.store == .epic {
                    Button {
                        appState.installEpicGame(game)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 11))
                            Text("Install")
                                .font(ArcWickyTheme.Typography.bodyBold)
                        }
                    }
                    .buttonStyle(ArcWickyButtonStyle(variant: .primary, height: 32, horizontalPadding: 18))
                }
            }
        }
        .padding(16)
        .arcWickyCard(cornerRadius: 12, background: ArcWickyTheme.Palette.surface)
    }

    // MARK: - Controls Strip
    private var controlsStrip: some View {
        HStack(spacing: 10) {
            // Filter Pills
            filterPill("All (\(appState.installedGames.count))", isSelected: filter == .all) {
                filter = .all
            }
            if installedCount > 0 {
                filterPill("Installed (\(installedCount))", isSelected: filter == .installed) {
                    filter = .installed
                }
            }
            if steamCount > 0 {
                filterPill("Steam (\(steamCount))", isSelected: filter == .store(.steam)) {
                    filter = .store(.steam)
                }
            }
            if epicCount > 0 {
                filterPill("Epic Games (\(epicCount))", isSelected: filter == .store(.epic)) {
                    filter = .store(.epic)
                }
            }
            if gogCount > 0 {
                filterPill("GOG (\(gogCount))", isSelected: filter == .store(.gog)) {
                    filter = .store(.gog)
                }
            }

            Spacer()

            // Sync Button
            Button {
                appState.refreshLibrary(forceEpicSync: true)
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.white.opacity(0.04))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .help("Sync Library (⌘R)")
            .disabled(appState.isRefreshingLibrary)

            // View Mode Toggle (Grid vs Table)
            HStack(spacing: 2) {
                Button {
                    viewMode = .grid
                } label: {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(viewMode == .grid ? Color.white : ArcWickyTheme.Palette.textMuted)
                        .frame(width: 26, height: 26)
                        .background(viewMode == .grid ? ArcWickyTheme.Palette.surfaceElevated : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    viewMode = .list
                } label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(viewMode == .list ? Color.white : ArcWickyTheme.Palette.textMuted)
                        .frame(width: 26, height: 26)
                        .background(viewMode == .list ? ArcWickyTheme.Palette.surfaceElevated : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(2)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.black.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1)
            )

            // Add DRM-Free Game button
            Button {
                appState.showingDrmInstaller = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                    Text("Add Game")
                        .font(ArcWickyTheme.Typography.bodyMedium)
                }
            }
            .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 28, horizontalPadding: 10))
            .help("Add a local DRM-Free Windows game (.exe)")
        }
    }

    private func filterPill(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(ArcWickyTheme.Typography.bodyMedium)
                .foregroundStyle(isSelected ? Color.white : ArcWickyTheme.Palette.textSecondary)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(
                    isSelected ? ArcWickyTheme.Palette.surfaceElevated : Color.white.opacity(0.04)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(isSelected ? ArcWickyTheme.Palette.borderHover : ArcWickyTheme.Palette.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Games Grid
    private var gamesGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 165, maximum: 200), spacing: 18)],
            spacing: 20
        ) {
            ForEach(games) { game in
                LibraryGameTile(game: game)
            }
        }
    }

    // MARK: - Games Table View
    private var gamesTable: some View {
        VStack(spacing: 1) {
            // Table Header
            HStack {
                Text("GAME")
                    .font(ArcWickyTheme.Typography.captionMedium)
                    .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                    .frame(width: 240, alignment: .leading)

                Text("PLATFORM")
                    .font(ArcWickyTheme.Typography.captionMedium)
                    .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                    .frame(width: 120, alignment: .leading)

                Text("STATUS")
                    .font(ArcWickyTheme.Typography.captionMedium)
                    .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                    .frame(width: 120, alignment: .leading)

                Spacer()

                Text("ACTIONS")
                    .font(ArcWickyTheme.Typography.captionMedium)
                    .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                    .frame(width: 140, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(ArcWickyTheme.Palette.surface.opacity(0.5))

            // Rows
            ForEach(games) { game in
                tableRow(game)
            }
        }
        .arcWickyCard(cornerRadius: 10, background: ArcWickyTheme.Palette.surface)
    }

    private func tableRow(_ game: InstalledGame) -> some View {
        let isRunning = appState.isGameRunning(game)

        return HStack(spacing: 14) {
            LibraryCoverView(game: game)
                .frame(width: 32, height: 42)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))

            Text(game.name)
                .font(ArcWickyTheme.Typography.bodyBold)
                .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                .lineLimit(1)
                .frame(width: 200, alignment: .leading)

            HStack(spacing: 6) {
                StoreLogoTile(store: game.store, size: 14)
                Text(game.store.rawValue)
                    .font(ArcWickyTheme.Typography.caption)
                    .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
            }
            .frame(width: 120, alignment: .leading)

            HStack {
                if isRunning {
                    ArcWickyBadge(text: "Running", tone: .success)
                } else if game.isInstalled {
                    ArcWickyBadge(text: "Installed", tone: .neutral)
                } else {
                    ArcWickyBadge(text: "In Cloud", tone: .neutral)
                }
            }
            .frame(width: 120, alignment: .leading)

            Spacer()

            HStack(spacing: 8) {
                Button {
                    appState.openGameSettings(for: game)
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 11))
                        .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 24, horizontalPadding: 8))

                if isRunning {
                    Button {
                        appState.stopGame(game)
                    } label: {
                        Text("Stop")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .buttonStyle(ArcWickyButtonStyle(variant: .destructive, height: 24, horizontalPadding: 10))
                } else if game.isInstalled {
                    Button {
                        appState.launchGame(game)
                    } label: {
                        Text("Play")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .buttonStyle(ArcWickyButtonStyle(variant: .primary, height: 24, horizontalPadding: 12))
                } else if game.store == .epic {
                    Button {
                        appState.installEpicGame(game)
                    } label: {
                        Text("Install")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 24, horizontalPadding: 10))
                }
            }
            .frame(width: 140, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isRunning ? ArcWickyTheme.Palette.surfaceElevated : Color.clear)
        .overlay(
            Rectangle()
                .fill(ArcWickyTheme.Palette.borderSubtle)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 36))
                .foregroundStyle(ArcWickyTheme.Palette.textMuted)

            VStack(spacing: 4) {
                Text(appState.installedGames.isEmpty ? "Your Library is Ready" : "No games match this filter")
                    .font(ArcWickyTheme.Typography.title)
                    .foregroundStyle(ArcWickyTheme.Palette.textPrimary)

                Text(appState.installedGames.isEmpty
                     ? "Discover free weekly games, connect Steam/Epic/GOG, or install any Windows DRM-free game."
                     : "Try selecting All Games or clearing the search box.")
                    .font(ArcWickyTheme.Typography.body)
                    .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if appState.installedGames.isEmpty {
                HStack(spacing: 12) {
                    Button {
                        appState.section = .stores
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                            Text("Browse Free Games")
                        }
                    }
                    .buttonStyle(ArcWickyButtonStyle(variant: .primary, height: 32, horizontalPadding: 16))

                    Button {
                        appState.showingDrmInstaller = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                            Text("Install .exe")
                        }
                    }
                    .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 32, horizontalPadding: 14))
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .arcWickyCard(cornerRadius: 12, background: ArcWickyTheme.Palette.surface)
    }
}

// MARK: - Game Tile Component
struct LibraryGameTile: View {
    let game: InstalledGame
    @EnvironmentObject var appState: AppState
    @State private var isHovered = false

    var body: some View {
        let isRunning = appState.isGameRunning(game)

        VStack(alignment: .leading, spacing: 8) {
            // Game Poster Art
            ZStack(alignment: .topTrailing) {
                LibraryCoverView(game: game)
                    .aspectRatio(2 / 3, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                // Platform Chip in corner
                StoreLogoTile(store: game.store, size: 16)
                    .padding(5)
                    .background(Capsule().fill(Color.black.opacity(0.75)))
                    .padding(8)

                // Hover Action Bar overlay
                if isHovered || isRunning {
                    hoverOverlay(isRunning: isRunning)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        isRunning ? ArcWickyTheme.Palette.success : (isHovered ? ArcWickyTheme.Palette.accentMint : ArcWickyTheme.Palette.border),
                        lineWidth: isRunning ? 2 : 1.5
                    )
            )
            .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: isHovered ? 8 : 4)

            // Title and Status
            VStack(alignment: .leading, spacing: 3) {
                Text(game.name)
                    .font(ArcWickyTheme.Typography.bodyBold)
                    .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                    .lineLimit(1)

                HStack {
                    if isRunning {
                        ArcWickyBadge(text: "Running", tone: .success)
                    } else if game.isInstalled {
                        Text("Installed")
                            .font(ArcWickyTheme.Typography.caption)
                            .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                    } else {
                        Text("Available")
                            .font(ArcWickyTheme.Typography.caption)
                            .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                    }
                    Spacer()
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isHovered ? ArcWickyTheme.Palette.surfaceElevated : ArcWickyTheme.Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1)
        )
        .onHover { isHovered = $0 }
        .onTapGesture {
            appState.selectedLibraryGameId = game.id
            if appState.isGameRunning(game) {
                appState.openGameSettings(for: game)
            } else if game.isInstalled {
                appState.launchGame(game)
            } else if game.store == .epic {
                appState.installEpicGame(game)
            }
        }
        .contextMenu {
            Button("Configure Graphics & Settings") {
                appState.openGameSettings(for: game)
            }
            if appState.isGameRunning(game) {
                Button(role: .destructive) {
                    appState.stopGame(game)
                } label: {
                    Label("Stop Game", systemImage: "stop.circle.fill")
                }
            } else if game.isInstalled {
                Button("Launch Game") {
                    appState.selectedLibraryGameId = game.id
                    appState.launchGame(game)
                }
            } else if game.store == .epic {
                Button("Install Game") {
                    appState.installEpicGame(game)
                }
            }
            Divider()
            Button("Purge Shader Cache") {
                let prefix = PathManager.shared.prefixURL(for: game.store)
                ShaderCacheManager.shared.clearShaderCaches(prefixURL: prefix)
            }
            Button("Backup Game Saves (Ludusavi)") {
                Task {
                    let prefix = PathManager.shared.prefixURL(for: game.store)
                    _ = try? await SaveManager.shared.createBackup(forBottleNamed: game.store.rawValue, prefixURL: prefix)
                }
            }
        }
    }

    private func hoverOverlay(isRunning: Bool) -> some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            HStack(spacing: 8) {
                actionButton(isRunning: isRunning)

                Spacer()

                Button {
                    appState.openGameSettings(for: game)
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color.white.opacity(0.2)))
                }
                .buttonStyle(.plain)
                .help("Configure Graphics & Bottle")
            }
            .padding(8)
        }
    }

    @ViewBuilder
    private func actionButton(isRunning: Bool) -> some View {
        if isRunning {
            Button {
                appState.stopGame(game)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 9))
                    Text("Stop")
                        .font(.system(size: 11, weight: .bold))
                }
            }
            .buttonStyle(ArcWickyButtonStyle(variant: .destructive, height: 26, horizontalPadding: 10))
        } else if game.isInstalled {
            Button {
                appState.launchGame(game)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 9))
                    Text("Play")
                        .font(.system(size: 11, weight: .bold))
                }
            }
            .buttonStyle(ArcWickyButtonStyle(variant: .primary, height: 26, horizontalPadding: 12))
        } else if game.store == .epic {
            Button {
                appState.installEpicGame(game)
            } label: {
                Text("Install")
                    .font(.system(size: 11, weight: .bold))
            }
            .buttonStyle(ArcWickyButtonStyle(variant: .primary, height: 26, horizontalPadding: 10))
        }
    }
}

// MARK: - Downsampled Cached Cover
struct LibraryCoverView: View {
    let game: InstalledGame
    @State private var image: NSImage?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            placeholder
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task(id: game.id) {
            if game.appId == "cuphead" || game.appId == "hades2" || game.appId == "mario" {
                let name = game.appId
                if let bundleURL = Bundle.main.url(forResource: name, withExtension: "jpg", subdirectory: "showcase") ??
                                   Bundle.main.url(forResource: name, withExtension: "jpg") ??
                                   Bundle.main.resourceURL?.appendingPathComponent("showcase/\(name).jpg"),
                   let data = try? Data(contentsOf: bundleURL),
                   let nsImage = NSImage(data: data) {
                    image = nsImage
                    return
                }
                let devPath = "Resources/showcase/\(name).jpg"
                if FileManager.default.fileExists(atPath: devPath),
                   let data = try? Data(contentsOf: URL(fileURLWithPath: devPath)),
                   let nsImage = NSImage(data: data) {
                    image = nsImage
                    return
                }
            }
            guard !game.coverURLs.isEmpty else { return }
            if let data = await CoverCache.load(urls: game.coverURLs, store: game.store, appId: game.appId) {
                #if canImport(ImageIO) && canImport(AppKit)
                image = CoverCache.downsample(data: data, maxPixelSize: 512) ?? NSImage(data: data)
                #else
                image = NSImage(data: data)
                #endif
            }
        }
    }

    private var placeholder: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.14, blue: 0.18),
                    Color(red: 0.08, green: 0.09, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(game.name)
                .font(ArcWickyTheme.Typography.captionMedium)
                .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                .lineLimit(3)
                .padding(10)
        }
    }
}
