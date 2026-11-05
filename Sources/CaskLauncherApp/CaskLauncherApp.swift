import SwiftUI
import AppKit
import Darwin
import CaskLauncherCore

@main
struct CaskLauncherApp: App {
    @NSApplicationDelegateAdaptor(VermutAppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()

    init() {
        #if DEBUG
        _ = VermutPalette.assertAllTokensResolve()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .tint(Color.Vermut.primary)
                .background(WindowFit())
                .frame(minWidth: 1024, minHeight: 680)
                .frame(idealWidth: 1280, idealHeight: 800)
                .ignoresSafeArea(.all)
                .onAppear {
                    appDelegate.appState = appState
                }
        }
        .defaultSize(width: 1280, height: 800)
        .windowResizability(.contentMinSize)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About \(VermutProject.name)") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            .applicationName: VermutProject.name,
                            .applicationVersion: VermutProject.version,
                            .version: VermutProject.version,
                            .credits: NSAttributedString(
                                string: "\(VermutProject.tagline)\nTactile Vinyl & Spatial Cartoon gaming hub for Apple Silicon Macs.\nCreated by Oscar Alfredo Pérez Lara.\nEpic Games uses Legendary (GPLv3).\nDXMT from v0.80 is LGPL 2.1+ (3Shain/dxmt).\nWine engines are LGPL 2.1+."
                            )
                        ]
                    )
                }
                
                Divider()
                
                Button("Check for Updates…") {
                    Task {
                        await appState.checkForUpdateManually()
                    }
                }
                .disabled(appState.isCheckingForUpdate)
            }
            CommandGroup(after: .appSettings) {
                Button("Settings…") {
                    appState.section = .settings
                }
                .keyboardShortcut(",", modifiers: .command)
                Divider()
                Button("Uninstall \(VermutProject.name)…") {
                    appState.showingUninstallSheet = true
                }
            }
            CommandGroup(after: .newItem) {
                Button(String(localized: "New Bottle…", comment: "File menu new bottle")) {
                    appState.showingNewBottleSheet = true
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
            CommandGroup(after: .sidebar) {
                Button(String(localized: "Game Settings", comment: "View menu inspector")) {
                    appState.toggleGameSettingsInspector()
                }
                .keyboardShortcut("i", modifiers: [.option, .command])
                .disabled(appState.installedGames.isEmpty)
            }
            CommandGroup(after: .textEditing) {
                Button("Find in ArcWicky") {
                    NotificationCenter.default.post(name: NSNotification.Name("ArcWickyFocusSearch"), object: nil)
                }
                .keyboardShortcut("k", modifiers: .command)
            }
            CommandMenu("Navigate") {
                Button("Playground") {
                    appState.section = .library
                }
                .keyboardShortcut("1", modifiers: .command)

                Button("Stores & Loot") {
                    appState.section = .stores
                }
                .keyboardShortcut("2", modifiers: .command)

                Button("The Wine Toy-Lab") {
                    appState.section = .wineToyLab
                }
                .keyboardShortcut("3", modifiers: .command)

                Button("Activity Logs") {
                    appState.section = .downloads
                }
                .keyboardShortcut("4", modifiers: .command)
            }
        }
    }
}

/// Stops Vermut-managed Wine/Steam processes on quit (native Mac apps untouched).
@MainActor
final class VermutAppDelegate: NSObject, NSApplicationDelegate {
    weak var appState: AppState?
    private var didReplyToTerminate = false

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Post-data-wipe: do not start Wine cleanup. Prefer process-local gate over
        // weak `appState` (QA: flag on AppState was invisible / terminateNow left PID alive).
        if UninstallPersistenceGate.immediateExitArmed
            || UninstallPersistenceGate.writesSuppressed
            || appState?.isUninstallComplete == true {
            appState?.noteQuitCleanupFinished()
            // `.terminateNow` / AE quit / NSRunningApplication.terminate all left the PID
            // alive >15s in Mac QA r1–r3. Hard-exit only in this uninstall session.
            exit(EXIT_SUCCESS)
        }

        didReplyToTerminate = false
        Task { @MainActor [weak self] in
            // Re-check gate: wipe may have finished while terminateLater was pending.
            if UninstallPersistenceGate.immediateExitArmed
                || UninstallPersistenceGate.writesSuppressed
                || self?.appState?.isUninstallComplete == true {
                self?.appState?.noteQuitCleanupFinished()
                exit(EXIT_SUCCESS)
            }
            await Task.detached(priority: .userInitiated) {
                WineManager.shared.stopAllVermutManagedProcesses()
            }.value
            guard let self else { return }
            if UninstallPersistenceGate.immediateExitArmed
                || UninstallPersistenceGate.writesSuppressed
                || self.appState?.isUninstallComplete == true {
                self.appState?.noteQuitCleanupFinished()
                exit(EXIT_SUCCESS)
            }
            self.appState?.noteQuitCleanupFinished()
            self.replyToTerminate()
        }
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 10_000_000_000)
            self?.replyToTerminate()
        }
        return .terminateLater
    }

    private func replyToTerminate() {
        guard !didReplyToTerminate else { return }
        // If uninstall armed while we waited, never reply with a soft continue — exit.
        if UninstallPersistenceGate.immediateExitArmed
            || UninstallPersistenceGate.writesSuppressed
            || appState?.isUninstallComplete == true {
            appState?.noteQuitCleanupFinished()
            exit(EXIT_SUCCESS)
        }
        didReplyToTerminate = true
        NSApp.reply(toApplicationShouldTerminate: true)
    }
}

private struct WindowFit: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            Self.apply(view.window)
            if let window = view.window {
                NotificationCenter.default.addObserver(
                    forName: NSWindow.didResizeNotification,
                    object: window,
                    queue: .main
                ) { [weak window] _ in
                    DispatchQueue.main.async {
                        Self.positionControls(window)
                    }
                }
            }
        }
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        DispatchQueue.main.async { Self.apply(view.window) }
    }

    private static func apply(_ window: NSWindow?) {
        guard let window else { return }
        window.styleMask.insert(.resizable)
        window.styleMask.insert(.titled)
        window.styleMask.insert(.fullSizeContentView)
        window.title = ""
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.titlebarSeparatorStyle = .none
        window.isMovableByWindowBackground = true
        window.isOpaque = true
        window.backgroundColor = NSColor(red: 0x0A/255.0, green: 0x0D/255.0, blue: 0x14/255.0, alpha: 1.0)
        window.toolbar = nil

        window.minSize = NSSize(width: 1024, height: 680)
        window.contentMinSize = NSSize(width: 1024, height: 680)
        window.contentMaxSize = NSSize(width: 10_000, height: 10_000)

        positionControls(window)

        if window.frame.width < 1024 || window.frame.height < 680 {
            window.setContentSize(NSSize(width: 1280, height: 800))
            window.center()
        }
    }

    private static func positionControls(_ window: NSWindow?) {
        guard let window,
              let close = window.standardWindowButton(.closeButton),
              let mini = window.standardWindowButton(.miniaturizeButton),
              let zoom = window.standardWindowButton(.zoomButton),
              let titlebar = close.superview else { return }

        let yOrigin = (titlebar.bounds.height - close.bounds.height) / 2
        close.setFrameOrigin(CGPoint(x: 18, y: yOrigin))
        mini.setFrameOrigin(CGPoint(x: 38, y: yOrigin))
        zoom.setFrameOrigin(CGPoint(x: 58, y: yOrigin))
    }
}
