import SwiftUI
import AppKit
import UniformTypeIdentifiers
import CaskLauncherCore

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @FocusState private var searchFocused: Bool
    @State private var showingIntro = true

    var body: some View {
        ZStack {
            if showingIntro {
                ArcWickyIntroView(onContinue: {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        showingIntro = false
                        appState.isCheckingSetup = false
                    }
                })
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .scale(scale: 1.06).combined(with: .opacity)
                ))
                .zIndex(100)
            } else if shouldShowOnboarding {
                OnboardingView()
            } else {
                AppShell(searchFocused: $searchFocused)
            }
        }
        .ignoresSafeArea(.all)
        .background(ArcWickyTheme.Palette.canvas)
        .frame(minWidth: 1040, minHeight: 700)
        .alert("Something went wrong", isPresented: errorPresented) {
            Button("OK", role: .cancel) {
                appState.errorMessage = nil
            }
        } message: {
            if let error = appState.errorMessage {
                Text(error)
            }
        }
        .alert(appState.infoAlertTitle, isPresented: infoPresented) {
            Button("OK", role: .cancel) {
                appState.dismissInfoAlert()
            }
        } message: {
            if let info = appState.infoAlertMessage {
                Text(info)
            }
        }
        .fileImporter(
            isPresented: $appState.showingFilePicker,
            allowedContentTypes: [.item]
        ) { result in
            switch result {
            case .success(let url):
                appState.launchExecutable(at: url)
            case .failure(let error):
                appState.errorMessage = error.localizedDescription
            }
        }
    }

    private var shouldShowOnboarding: Bool {
        appState.setupFailed || appState.showOnboarding
    }

    private var errorPresented: Binding<Bool> {
        Binding(
            get: { appState.errorMessage != nil && appState.isSetupComplete && !appState.showOnboarding },
            set: { if !$0 { appState.errorMessage = nil } }
        )
    }

    private var infoPresented: Binding<Bool> {
        Binding(
            get: { appState.infoAlertMessage != nil && appState.isSetupComplete && !appState.showOnboarding },
            set: { if !$0 { appState.dismissInfoAlert() } }
        )
    }
}

struct SetupSplashView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ArcWickyIntroView(onContinue: {
            appState.isCheckingSetup = false
            appState.isSetupComplete = true
        })
    }
}

struct AppShell: View {
    @EnvironmentObject var appState: AppState
    var searchFocused: FocusState<Bool>.Binding
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 1. Top Command Deck (Traffic Dots seamlessly aligned with Search Capsule, Gamepad, Add .EXE)
                ArcWickyHeaderDeck(searchFocused: searchFocused)
                    .background(ArcWickyTheme.Palette.surface.opacity(0.95))
                    .overlay(
                        Rectangle()
                            .fill(ArcWickyTheme.Palette.border)
                            .frame(height: 1.5),
                        alignment: .bottom
                    )

                // 2. Main Studio Canvas (Full 100% width, no sidebar)
                ZStack {
                    ArcWickyTheme.Palette.canvas.ignoresSafeArea()

                    VStack(spacing: 0) {
                        content
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .ignoresSafeArea(.all, edges: .top)

            // 3. Screen 2 & 3: Floating Bottom Console Dock
            floatingConsoleDock
                .padding(.bottom, 20)
        }
        .ignoresSafeArea(.all)
        .background(ArcWickyTheme.Palette.canvas)
        .animation(reduceMotion ? .easeInOut(duration: 0.15) : .spring(response: 0.3, dampingFraction: 0.85), value: appState.section)
        .sheet(item: $appState.bottleToDelete) { store in
            DeleteBottleSheet(store: store) {
                appState.bottleToDelete = nil
                appState.resetStore(store)
            } onCancel: {
                appState.bottleToDelete = nil
            }
        }
        .sheet(isPresented: $appState.showingEpicAuth) {
            EpicAuthSheet()
                .environmentObject(appState)
        }
        .sheet(isPresented: $appState.showingNewBottleSheet) {
            NewBottleSheet()
                .environmentObject(appState)
        }
        .sheet(isPresented: $appState.showingUninstallSheet) {
            UninstallFlowView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $appState.showingLogViewer) {
            LogViewerSheet(
                appState: appState,
                store: appState.logViewerStore,
                customBottleID: appState.logViewerCustomBottleID
            )
        }
        .sheet(isPresented: $appState.showingDrmInstaller) {
            DrmFreeInstallerSheet(appState: appState)
        }
        .sheet(isPresented: $appState.showingDependencies) {
            DependenciesSheet(
                appState: appState,
                store: appState.dependenciesStore,
                customBottleID: appState.dependenciesCustomBottleID
            )
        }
        .sheet(isPresented: $appState.showingItchBrowser) {
            ItchBrowserView(appState: appState)
        }
        .sheet(isPresented: $appState.showingAmazonGames) {
            AmazonGamesSheet(appState: appState)
        }
    }

    // MARK: - Floating Bottom Console Dock
    private var floatingConsoleDock: some View {
        HStack(spacing: 12) {
            dockItem(
                title: "Playground",
                systemImage: "gamecontroller.fill",
                isSelected: appState.section == .library
            ) {
                appState.section = .library
            }

            dockItem(
                title: "Stores & Loot",
                systemImage: "storefront.fill",
                isSelected: appState.section == .stores
            ) {
                appState.section = .stores
            }

            dockItem(
                title: "Wine Toy-Lab",
                systemImage: "flask.fill",
                isSelected: isToyLabActive
            ) {
                appState.section = .wineToyLab
            }

            dockItem(
                title: "Activity Logs",
                systemImage: "list.bullet.rectangle.portrait.fill",
                badge: appState.gameDownloads.isEmpty ? nil : "\(appState.gameDownloads.count)",
                isSelected: appState.section == .downloads
            ) {
                appState.section = .downloads
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(ArcWickyTheme.Palette.surface.opacity(0.92))
        )
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.6), radius: 24, x: 0, y: 12)
        .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 6)
    }

    private var isToyLabActive: Bool {
        switch appState.section {
        case .wineToyLab, .bottle, .customBottle:
            return true
        default:
            return false
        }
    }

    private func dockItem(
        title: String,
        systemImage: String,
        badge: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: systemImage)
                        .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                        .foregroundStyle(isSelected ? ArcWickyTheme.Palette.accentMint : ArcWickyTheme.Palette.textSecondary)
                        .frame(width: 44, height: 38)
                        .background(
                            isSelected ? ArcWickyTheme.Palette.surfaceElevated : Color.clear
                        )
                        .clipShape(Capsule(style: .continuous))

                    if let badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundStyle(ArcWickyTheme.Palette.onPrimaryFixed)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Capsule().fill(ArcWickyTheme.Palette.accentMint))
                            .offset(x: 4, y: -2)
                    }
                }

                // Active Indicator Dot
                Circle()
                    .fill(isSelected ? ArcWickyTheme.Palette.accentMint : Color.clear)
                    .frame(width: 4.5, height: 4.5)
                    .shadow(color: ArcWickyTheme.Palette.accentMint, radius: isSelected ? 4 : 0)
            }
        }
        .buttonStyle(.plain)
        .help(title)
    }

    @ViewBuilder
    private var content: some View {
        switch appState.section {
        case .library:
            LibraryView()
        case .stores:
            StoresView()
        case .wineToyLab:
            WineToyLabView()
        case .downloads:
            DownloadsView()
        case .bottle(let store):
            BottleDetailView(store: store)
        case .customBottle(let id):
            CustomBottleDetailView(bottleID: id)
        case .settings:
            SettingsView()
        }
    }
}

// MARK: - Header Deck Component (Screen 2: Clean Traffic Lights, Search Capsule, Gamepad, Add .EXE)
struct ArcWickyHeaderDeck: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var gamepadManager = GamepadManager.shared
    var searchFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: 14) {
            // Left: Space reserved for native macOS traffic lights (close, minimize, zoom)
            // macOS places the buttons natively at (x ≈ 18, center_y ≈ 18..20), perfectly aligned
            Color.clear
                .frame(width: 76, height: 32)

            // Center: Tactile Vinyl Search Capsule
            ArcWickySearchField(
                text: $appState.searchQuery,
                placeholder: "Find games, stores, or bottles…"
            )
            .focused(searchFocused)
            .onExitCommand { searchFocused.wrappedValue = false }
            .frame(maxWidth: 420)

            Spacer()

            // Right: Gamepad Indicator + Add .EXE + Settings
            HStack(spacing: 12) {
                // Gamepad status capsule (Clickable to scan/refresh controllers)
                Button {
                    gamepadManager.refreshGamepads()
                } label: {
                    HStack(spacing: 7) {
                        Circle()
                            .fill(gamepadManager.connectedGamepads.isEmpty ? ArcWickyTheme.Palette.textMuted : ArcWickyTheme.Palette.success)
                            .frame(width: 8, height: 8)
                            .shadow(
                                color: gamepadManager.connectedGamepads.isEmpty ? Color.clear : ArcWickyTheme.Palette.success,
                                radius: 4
                            )

                        Image(systemName: gamepadIcon)
                            .font(.system(size: 13))
                            .foregroundStyle(gamepadManager.connectedGamepads.isEmpty ? ArcWickyTheme.Palette.textMuted : ArcWickyTheme.Palette.accentMint)

                        Text(gamepadTitle)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(gamepadManager.connectedGamepads.isEmpty ? ArcWickyTheme.Palette.textMuted : ArcWickyTheme.Palette.textSecondary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 32)
                    .background(
                        Capsule(style: .continuous)
                            .fill(ArcWickyTheme.Palette.surface)
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
                    )
                    .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 3)
                }
                .buttonStyle(.plain)
                .help(gamepadHelp)

                // Add .EXE Button
                Button {
                    appState.showingFilePicker = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .black))
                        Text("Add .EXE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 32, horizontalPadding: 14))
                .help("Install or run a Windows game (.exe / .msi)")

                // Settings Gear
                Button {
                    appState.section = .settings
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(appState.section == .settings ? ArcWickyTheme.Palette.accentMint : ArcWickyTheme.Palette.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(appState.section == .settings ? ArcWickyTheme.Palette.surfaceElevated : ArcWickyTheme.Palette.surface)
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(appState.section == .settings ? ArcWickyTheme.Palette.accentMint : ArcWickyTheme.Palette.border, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
                .help("Launcher Settings")
            }
            .padding(.trailing, 20)
        }
        .padding(.vertical, 6)
        .frame(height: 44)
    }

    private var gamepadIcon: String {
        if let first = gamepadManager.connectedGamepads.first {
            switch first.type {
            case .dualSense, .dualShock: return "gamecontroller.fill"
            case .xbox: return "gamecontroller.fill"
            case .switchPro, .switchJoyCon: return "gamecontroller.fill"
            case .generic: return "gamecontroller.fill"
            }
        }
        return "gamecontroller"
    }

    private var gamepadTitle: String {
        if let first = gamepadManager.connectedGamepads.first {
            let shortVendor = first.vendorName
                .replacingOccurrences(of: " Wireless Controller", with: "")
                .replacingOccurrences(of: " Controller", with: "")
            if let battery = first.batteryLevel, battery >= 0 {
                return "\(shortVendor) • \(Int(battery * 100))%"
            }
            return "\(shortVendor) • Ready"
        }
        return "No Controller"
    }

    private var gamepadHelp: String {
        if let first = gamepadManager.connectedGamepads.first {
            return "\(first.vendorName) is connected and mapped for Wine & Apple Silicon gaming."
        }
        return "No game controller detected. Connect a PlayStation DualSense, Xbox, or Switch Pro controller via Bluetooth or USB."
    }
}
