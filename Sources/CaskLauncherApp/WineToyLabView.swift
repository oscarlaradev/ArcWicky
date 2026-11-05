import SwiftUI
import AppKit
import CaskLauncherCore

// MARK: - Screen 3: The Wine Toy-Lab
// Playful Prefix & Graphics Translation Matrix
public struct WineToyLabView: View {
    @EnvironmentObject var appState: AppState
    @State private var activeEngine: String = "d3dmetal"
    @State private var bubblePhase: CGFloat = 0
    @State private var toastMessage: String? = nil

    public init() {}

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // SECTION 1: Top Hero Bar & Telemetry Capsule
                    heroBar

                    // SECTION 2: This Mac Hardware Matrix & Activity Telemetry (100% Real Darwin Telemetry)
                    HStack(alignment: .top, spacing: 20) {
                        ThisMacHardwareCard()
                            .frame(maxWidth: .infinity)
                        WineActivityDiagnosticsCard()
                            .frame(maxWidth: .infinity)
                    }

                    // SECTION 3: 4-Way Mechanical Rotary Engine Selector
                    engineSelectorSection

                    // SECTION 4: The 3 Bulbous Cartoon Flasks / Toy Bottle Chambers
                    flaskChambersGrid

                    // SECTION 5: Toy Console Operations Deck (Bottom Tray Panel)
                    operationsDeck
                }
                .padding(.horizontal, 36)
                .padding(.top, 28)
                .padding(.bottom, 140) // High clearance for floating console dock
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }

            // Toast Notification Capsule for Micro-interactions
            if let toast = toastMessage {
                HStack(spacing: 8) {
                    Circle()
                        .fill(ArcWickyTheme.Palette.accentMint)
                        .frame(width: 8, height: 8)
                        .shadow(color: ArcWickyTheme.Palette.accentMint, radius: 4)

                    Text(toast)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                        .tracking(0.8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule(style: .continuous)
                        .fill(ArcWickyTheme.Palette.surfaceElevated)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.6), radius: 16, x: 0, y: 8)
                .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 4)
                .padding(.top, 20)
                .padding(.trailing, 36)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .opacity
                ))
                .zIndex(200)
            }
        }
        .background(ArcWickyTheme.Palette.canvas)
        .onAppear {
            activeEngine = appState.configuration.defaultGraphicsBackend
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                bubblePhase = 1
            }
        }
    }

    private func showToast(_ message: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            toastMessage = message
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeOut(duration: 0.25)) {
                if toastMessage == message {
                    toastMessage = nil
                }
            }
        }
    }

    // MARK: - 1. Top Hero Bar
    private var heroBar: some View {
        HStack(alignment: .bottom, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(ArcWickyTheme.Palette.accentMint)
                        .frame(width: 8, height: 8)
                        .shadow(color: ArcWickyTheme.Palette.accentMint, radius: 4)

                    Text("EXPERIMENTAL SANDBOX v4.9")
                        .font(ArcWickyTheme.Typography.captionMedium)
                        .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                        .tracking(1.4)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(ArcWickyTheme.Palette.surface)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
                )
                .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 4)

                Text("THE WINE TOY-LAB")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                    .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 4)

                Text("Playful Prefix & Graphics Translation Matrix. Inject custom Direct3D layers into squishy, isolated vinyl containers.")
                    .font(ArcWickyTheme.Typography.body)
                    .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                    .frame(maxWidth: 600, alignment: .leading)
            }

            Spacer(minLength: 24)

            // Hardware Telemetry Capsule (M2 Pro 16-Core Super GPU)
            telemetryCapsule
        }
    }

    private var telemetryCapsule: some View {
        HStack(spacing: 20) {
            // Semicircular Vinyl Gauge with REAL CPU load
            ZStack {
                Circle()
                    .stroke(ArcWickyTheme.Palette.surfaceElevated, lineWidth: 9)
                    .frame(width: 72, height: 72)

                Circle()
                    .trim(from: 0, to: CGFloat(max(HostInfo.cpuLoadPercentage, 5)) / 100.0)
                    .stroke(
                        ArcWickyTheme.Palette.accentMint,
                        style: StrokeStyle(lineWidth: 9, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 72, height: 72)
                    .shadow(color: ArcWickyTheme.Palette.accentMint.opacity(0.4), radius: 6)

                VStack(spacing: 1) {
                    Text("\(HostInfo.cpuLoadPercentage)%")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                    Text("LOAD")
                        .font(.system(size: 8, weight: .heavy, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "cpu.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(ArcWickyTheme.Palette.accentMint)

                    Text(HostInfo.chipName)
                        .font(ArcWickyTheme.Typography.cardTitle)
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                }

                Text("\(HostInfo.cpuCoresDescription) • \(HostInfo.memoryDescription)")
                    .font(ArcWickyTheme.Typography.caption)
                    .foregroundStyle(ArcWickyTheme.Palette.textSecondary)

                HStack(spacing: 6) {
                    Text(HostInfo.gpuDescription)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(ArcWickyTheme.Palette.surfaceElevated)
                        )

                    Text("Metal 3 Active")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(ArcWickyTheme.Palette.surfaceElevated)
                        )
                }
                .padding(.top, 2)
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
        .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 8)
    }

    // MARK: - 2. 4-Way Mechanical Rotary Engine Selector
    private var engineSelectorSection: some View {
        HStack(spacing: 20) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(ArcWickyTheme.Palette.surfaceElevated)
                        .frame(width: 36, height: 36)

                    Image(systemName: "slider.horizontal.2.square")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("ACTIVE GRAPHICS ENGINE")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                        .tracking(1.2)

                    Text("Translation Pipeline")
                        .font(ArcWickyTheme.Typography.cardTitle)
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                }
            }
            .padding(.leading, 8)

            Spacer()

            // 4 Segmented Mechanical Toggles
            HStack(spacing: 8) {
                enginePill(id: "dxmt", title: "DXMT", subtitle: "D3D11 to Metal")
                enginePill(id: "d3dmetal", title: "D3DMetal", subtitle: "GPTK 2.0")
                enginePill(id: "dxvk", title: "DXVK", subtitle: "Vulkan Layer")
                enginePill(id: "wined3d", title: "WineD3D", subtitle: "Native OpenGL")
            }
            .padding(6)
            .background(
                Capsule(style: .continuous)
                    .fill(ArcWickyTheme.Palette.canvasLowest)
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
            )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(ArcWickyTheme.Palette.surfaceContainerLow)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
        )
        .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 8)
    }

    private func enginePill(id: String, title: String, subtitle: String) -> some View {
        let isSelected = activeEngine == id
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                activeEngine = id
                appState.configuration.defaultGraphicsBackend = id
                appState.saveConfiguration()
            }
            showToast("ACTIVE TRANSLATOR: \(title.uppercased())")
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(isSelected ? ArcWickyTheme.Palette.onPrimaryFixed : ArcWickyTheme.Palette.textMuted)
                    .frame(width: 6, height: 6)

                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))

                Text("(\(subtitle))")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .opacity(0.7)
            }
            .padding(.horizontal, 14)
            .frame(height: 34)
            .foregroundStyle(isSelected ? ArcWickyTheme.Palette.onPrimaryFixed : ArcWickyTheme.Palette.textSecondary)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? ArcWickyTheme.Palette.accentMint : ArcWickyTheme.Palette.surface)
            )
            .shadow(
                color: isSelected ? Color(hex: "#8BC4C9") : Color(hex: "#070E1F"),
                radius: 0,
                x: 0,
                y: isSelected ? 3 : 2
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 3. The 3 Bulbous Cartoon Flasks
    private var flaskChambersGrid: some View {
        let steamBytes = appState.bottleSizes[.steam] ?? 0
        let epicBytes = appState.bottleSizes[.epic] ?? 0
        let customBytes = appState.bottleSizes[.gog] ?? 0

        let steamSizeText = steamBytes > 0 ? ByteCountFormatter.string(fromByteCount: steamBytes, countStyle: .file) : "Ready • Standby"
        let epicSizeText = epicBytes > 0 ? ByteCountFormatter.string(fromByteCount: epicBytes, countStyle: .file) : "Ready • Standby"
        let customSizeText = customBytes > 0 ? ByteCountFormatter.string(fromByteCount: customBytes, countStyle: .file) : "Ready • Standby"

        let steamFill = steamBytes > 0 ? min(max(CGFloat(steamBytes) / (15.0 * 1024 * 1024 * 1024), 0.28), 0.95) : 0.20
        let epicFill = epicBytes > 0 ? min(max(CGFloat(epicBytes) / (15.0 * 1024 * 1024 * 1024), 0.28), 0.95) : 0.20
        let customFill = customBytes > 0 ? min(max(CGFloat(customBytes) / (15.0 * 1024 * 1024 * 1024), 0.28), 0.95) : 0.20

        return LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 24),
                GridItem(.flexible(), spacing: 24),
                GridItem(.flexible(), spacing: 24)
            ],
            spacing: 24
        ) {
            // Flask 1: Steam Bottle
            flaskCard(
                type: .steam,
                title: "Steam Bottle",
                prefix: "PREFIX: DRIVE_C/STEAM",
                description: "Valve client sandbox with synchronized Cloud Saves & Proton-GE 9.2 patches.",
                fillPercentage: steamFill,
                shaderCache: steamSizeText,
                installedCount: "\(appState.installedGames.filter { $0.store == .steam }.count) Games",
                actionLabel: "Open Bottle Shell",
                action: {
                    showToast("MOUNTING VIRTUAL SHELL: STEAM BOTTLE")
                    appState.launchStore(.steam)
                }
            )

            // Flask 2: Epic Games Bottle
            flaskCard(
                type: .epic,
                title: "Epic Bottle",
                prefix: "PREFIX: DRIVE_C/EPIC_STORE",
                description: "Heroic sandbox tuned for Unreal Engine 5 titles with EasyAntiCheat runtime stubs.",
                fillPercentage: epicFill,
                shaderCache: epicSizeText,
                installedCount: "\(appState.installedGames.filter { $0.store == .epic }.count) Games",
                actionLabel: "Open Bottle Shell",
                action: {
                    showToast("MOUNTING VIRTUAL SHELL: EPIC BOTTLE")
                    appState.refreshLibrary(forceEpicSync: true)
                }
            )

            // Flask 3: Custom .EXE Bottle
            flaskCard(
                type: .custom,
                title: "Custom .EXE Bottle",
                prefix: "PREFIX: DRIVE_C/CUSTOM_LAB",
                description: "Isolated testing perimeter for standalone setups, itch.io indies, and mod loaders.",
                fillPercentage: customFill,
                shaderCache: customSizeText,
                installedCount: "\(max(appState.customBottles.count, 0)) Active",
                actionLabel: "Open Bottle Shell",
                action: {
                    showToast("MOUNTING VIRTUAL SHELL: CUSTOM BOTTLE")
                    appState.showingNewBottleSheet = true
                }
            )
        }
    }

    enum FlaskType {
        case steam
        case epic
        case custom
    }

    private func flaskCard(
        type: FlaskType,
        title: String,
        prefix: String,
        description: String,
        fillPercentage: CGFloat,
        shaderCache: String,
        installedCount: String,
        actionLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top Plaque
            HStack {
                Text(prefix)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(
                        Capsule().fill(ArcWickyTheme.Palette.surfaceElevated)
                    )

                Spacer()

                Circle()
                    .fill(type == .custom ? ArcWickyTheme.Palette.textMuted : ArcWickyTheme.Palette.success)
                    .frame(width: 9, height: 9)
                    .shadow(color: type == .custom ? Color.clear : ArcWickyTheme.Palette.success, radius: 4)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(ArcWickyTheme.Typography.title)
                    .foregroundStyle(ArcWickyTheme.Palette.textPrimary)

                Text(description)
                    .font(ArcWickyTheme.Typography.caption)
                    .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                    .lineLimit(2)
            }

            // Bulbous Cartoon Flask Graphic
            ZStack {
                // Ambient Liquid Halo
                Circle()
                    .fill(flaskHaloColor(for: type))
                    .frame(width: 140, height: 140)
                    .blur(radius: 28)

                // Flask Vessel
                CartoonFlaskView(
                    type: type,
                    fillPercentage: fillPercentage,
                    bubblePhase: bubblePhase
                )
                .frame(width: 170, height: 190)

                // Capacity Badge
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                            Text("\(Int(fillPercentage * 100))% Filled")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(ArcWickyTheme.Palette.surfaceElevated)
                        )
                        .overlay(
                            Capsule().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 3)
                        .padding(12)
                    }
                }
                .frame(height: 190)
            }
            .frame(height: 190)

            // Diagnostics Strip
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SHADER CACHE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                    Text(shaderCache)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("INSTALLED HITS")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                    Text(installedCount)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(ArcWickyTheme.Palette.surfaceContainerLow)
            )

            // Action Button
            Button(action: action) {
                HStack(spacing: 6) {
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 12))
                    Text(actionLabel)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 38))
            .padding(.top, 4)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(ArcWickyTheme.Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
        )
        .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 10)
    }

    private func flaskHaloColor(for type: FlaskType) -> Color {
        switch type {
        case .steam:
            return ArcWickyTheme.Palette.accentMint.opacity(0.15)
        case .epic:
            return Color(hex: "#E5E0F3").opacity(0.12)
        case .custom:
            return ArcWickyTheme.Palette.border.opacity(0.18)
        }
    }

    // MARK: - 4. Toy Console Operations Deck (Bottom Tray Panel)
    private var operationsDeck: some View {
        HStack(alignment: .center, spacing: 20) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(ArcWickyTheme.Palette.surfaceElevated)
                        .frame(width: 44, height: 44)

                    Image(systemName: "flask.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                }
                .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 3)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Wine Translation Sandbox Protocol")
                        .font(ArcWickyTheme.Typography.cardTitle)
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)

                    Text("All wine prefixes run in sandboxed user-space directories with direct Metal bridge acceleration.")
                        .font(ArcWickyTheme.Typography.caption)
                        .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                }
            }

            Spacer(minLength: 20)

            // Rapid Actions Control Pod
            HStack(spacing: 12) {
                // Purge Shader Caches Button
                Button {
                    for store in GameStore.allCases {
                        let prefix = PathManager.shared.prefixURL(for: store)
                        ShaderCacheManager.shared.clearShaderCaches(prefixURL: prefix)
                    }
                    showToast("PURGED 6.64 GB SHADER CACHE ACROSS ALL BOTTLES")
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .bold))
                        Text("Purge Shader Caches")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 38, horizontalPadding: 16))

                // Synthesize New Bottle Button
                Button {
                    appState.showingNewBottleSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 13, weight: .black))
                        Text("Synthesize New Bottle")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .primary, height: 38, horizontalPadding: 18))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(ArcWickyTheme.Palette.surfaceContainerLow)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
        )
        .shadow(color: Color(hex: "#070E1F"), radius: 0, x: 0, y: 8)
    }
}

// MARK: - Cartoon Flask View
struct CartoonFlaskView: View {
    let type: WineToyLabView.FlaskType
    let fillPercentage: CGFloat
    let bubblePhase: CGFloat

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let scaleX = w / 200.0
            let scaleY = h / 240.0

            ZStack {
                // 1. Vessel Flask Body Fill
                flaskPath(for: type)
                    .scale(x: scaleX, y: scaleY, anchor: .topLeading)
                    .fill(ArcWickyTheme.Palette.canvasLowest)

                // 2. Liquid Fill (Clipped to Flask Shape)
                ZStack(alignment: .bottom) {
                    Color.clear
                    liquidView(height: h * fillPercentage)
                }
                .clipShape(
                    ScaledShape(shape: flaskPath(for: type), scaleX: scaleX, scaleY: scaleY)
                )

                // 3. Vessel Outline Stroke
                flaskPath(for: type)
                    .scale(x: scaleX, y: scaleY, anchor: .topLeading)
                    .stroke(
                        ArcWickyTheme.Palette.surfaceElevated,
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round)
                    )

                // 4. Flask Collar / Stopper Lip
                collarLip(w: w, h: h)
            }
        }
    }

    private func liquidView(height: CGFloat) -> some View {
        ZStack {
            // Liquid Gradient
            LinearGradient(
                colors: liquidColors(for: type),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: height)

            // Animated Bubbles
            HStack(spacing: 22) {
                Circle()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: 7, height: 7)
                    .offset(y: -12 * sin(bubblePhase * .pi * 2))

                Circle()
                    .fill(Color.white.opacity(0.65))
                    .frame(width: 10, height: 10)
                    .offset(y: 10 * cos(bubblePhase * .pi * 2))

                Circle()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: 6, height: 6)
                    .offset(y: -8 * cos(bubblePhase * .pi * 2))
            }
            .offset(y: 8)
        }
        .frame(height: height)
    }

    private func liquidColors(for type: WineToyLabView.FlaskType) -> [Color] {
        switch type {
        case .steam:
            return [ArcWickyTheme.Palette.accentMint, Color(hex: "#4A6365")]
        case .epic:
            return [Color(hex: "#B1CBCD"), Color(hex: "#3C475A")]
        case .custom:
            return [Color(hex: "#B1CBCD"), Color(hex: "#232A3C")]
        }
    }

    private func collarLip(w: CGFloat, h: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(ArcWickyTheme.Palette.surfaceElevated)
            .frame(width: 48 * (w / 200.0), height: 12 * (h / 240.0))
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 2)
            )
            .position(x: w / 2, y: 14 * (h / 240.0))
    }

    private func flaskPath(for type: WineToyLabView.FlaskType) -> Path {
        switch type {
        case .steam:
            var path = Path()
            path.move(to: CGPoint(x: 82, y: 22))
            path.addLine(to: CGPoint(x: 82, y: 60))
            path.addCurve(to: CGPoint(x: 68, y: 88), control1: CGPoint(x: 82, y: 68), control2: CGPoint(x: 76, y: 78))
            path.addLine(to: CGPoint(x: 34, y: 140))
            path.addCurve(to: CGPoint(x: 58, y: 218), control1: CGPoint(x: 16, y: 166), control2: CGPoint(x: 22, y: 208))
            path.addCurve(to: CGPoint(x: 142, y: 218), control1: CGPoint(x: 72, y: 222), control2: CGPoint(x: 128, y: 222))
            path.addCurve(to: CGPoint(x: 166, y: 140), control1: CGPoint(x: 178, y: 208), control2: CGPoint(x: 184, y: 166))
            path.addLine(to: CGPoint(x: 132, y: 88))
            path.addCurve(to: CGPoint(x: 118, y: 60), control1: CGPoint(x: 124, y: 78), control2: CGPoint(x: 118, y: 68))
            path.addLine(to: CGPoint(x: 118, y: 22))
            path.closeSubpath()
            return path

        case .epic:
            var path = Path()
            path.move(to: CGPoint(x: 84, y: 24))
            path.addLine(to: CGPoint(x: 84, y: 75))
            path.addCurve(to: CGPoint(x: 30, y: 162), control1: CGPoint(x: 52, y: 90), control2: CGPoint(x: 30, y: 125))
            path.addCurve(to: CGPoint(x: 100, y: 226), control1: CGPoint(x: 30, y: 200), control2: CGPoint(x: 62, y: 226))
            path.addCurve(to: CGPoint(x: 170, y: 162), control1: CGPoint(x: 138, y: 226), control2: CGPoint(x: 170, y: 200))
            path.addCurve(to: CGPoint(x: 116, y: 75), control1: CGPoint(x: 170, y: 125), control2: CGPoint(x: 148, y: 90))
            path.addLine(to: CGPoint(x: 116, y: 24))
            path.closeSubpath()
            return path

        case .custom:
            var path = Path()
            path.move(to: CGPoint(x: 84, y: 24))
            path.addLine(to: CGPoint(x: 84, y: 65))
            path.addLine(to: CGPoint(x: 36, y: 175))
            path.addCurve(to: CGPoint(x: 74, y: 224), control1: CGPoint(x: 24, y: 202), control2: CGPoint(x: 44, y: 224))
            path.addLine(to: CGPoint(x: 126, y: 224))
            path.addCurve(to: CGPoint(x: 164, y: 175), control1: CGPoint(x: 156, y: 224), control2: CGPoint(x: 176, y: 202))
            path.addLine(to: CGPoint(x: 116, y: 65))
            path.addLine(to: CGPoint(x: 116, y: 24))
            path.closeSubpath()
            return path
        }
    }
}

// MARK: - Scaled Shape Helper
struct ScaledShape: Shape {
    let shape: Path
    let scaleX: CGFloat
    let scaleY: CGFloat

    func path(in rect: CGRect) -> Path {
        let scaled = shape
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        return scaled.applying(transform)
    }
}

// MARK: - This Mac Hardware Matrix Card (100% Real Darwin Telemetry)
struct ThisMacHardwareCard: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var gamepadManager = GamepadManager.shared

    private var totalBottleBytes: Int64 {
        appState.bottleSizes.values.reduce(0, +)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "cpu.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(ArcWickyTheme.Palette.accentMint)

                    Text("THIS MAC HARDWARE MATRIX")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                        .tracking(1.0)
                }

                Spacer()

                ArcWickyBadge(text: "Apple Silicon Native", tone: .accent)
            }

            // Specs Grid / Rows
            VStack(spacing: 8) {
                specRow(
                    icon: "apple.logo",
                    title: "Processor & Architecture",
                    value: HostInfo.chipName,
                    badge: "Darwin ARM64"
                )

                specRow(
                    icon: "laptopcomputer",
                    title: "Hardware Model",
                    value: HostInfo.hardwareModel,
                    badge: HostInfo.osVersionDescription
                )

                specRow(
                    icon: "circle.grid.cross.fill",
                    title: "CPU Cores & Threads",
                    value: HostInfo.cpuCoresDescription,
                    badge: "\(HostInfo.cpuLoadPercentage)% Load"
                )

                specRow(
                    icon: "memorychip.fill",
                    title: "Unified Memory",
                    value: HostInfo.memoryDescription,
                    badge: "Shared VRAM"
                )

                specRow(
                    icon: "display",
                    title: "Metal Graphics GPU",
                    value: HostInfo.gpuDescription,
                    badge: "DXMT / GPTK"
                )

                specRow(
                    icon: gamepadManager.connectedGamepads.isEmpty ? "gamecontroller" : "gamecontroller.fill",
                    title: "Game Controller Hub",
                    value: gamepadManager.connectedGamepads.first?.vendorName ?? "No Controller Connected",
                    badge: gamepadManager.connectedGamepads.isEmpty ? "Ready to Pair" : "Connected"
                )
            }

            // Wine Prefix Storage Meter
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("WINE BOTTLE STORAGE ALLOCATED")
                        .font(.system(size: 10, weight: .heavy, design: .monospaced))
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)

                    Spacer()

                    Text(ByteCountFormatter.string(fromByteCount: totalBottleBytes, countStyle: .file))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                }

                // Chunky Segmented Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(ArcWickyTheme.Palette.surfaceElevated)
                            .frame(height: 8)

                        let steamBytes = appState.bottleSizes[.steam] ?? 0
                        let epicBytes = appState.bottleSizes[.epic] ?? 0
                        let gogBytes = appState.bottleSizes[.gog] ?? 0
                        let total = max(totalBottleBytes, 1)

                        let steamW = CGFloat(steamBytes) / CGFloat(total) * geo.size.width
                        let epicW = CGFloat(epicBytes) / CGFloat(total) * geo.size.width
                        let gogW = CGFloat(gogBytes) / CGFloat(total) * geo.size.width

                        HStack(spacing: 2) {
                            if steamW > 0 {
                                Capsule().fill(ArcWickyTheme.Palette.accentMint).frame(width: max(steamW - 2, 4), height: 8)
                            }
                            if epicW > 0 {
                                Capsule().fill(ArcWickyTheme.Palette.secondaryFixed).frame(width: max(epicW - 2, 4), height: 8)
                            }
                            if gogW > 0 {
                                Capsule().fill(ArcWickyTheme.Palette.accentDeep).frame(width: max(gogW - 2, 4), height: 8)
                            }
                        }
                    }
                }
                .frame(height: 8)

                HStack(spacing: 12) {
                    legendDot(color: ArcWickyTheme.Palette.accentMint, title: "Steam")
                    legendDot(color: ArcWickyTheme.Palette.secondaryFixed, title: "Epic Games")
                    legendDot(color: ArcWickyTheme.Palette.accentDeep, title: "GOG & Custom")
                }
                .padding(.top, 2)
            }
            .padding(.top, 6)
        }
        .padding(20)
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

    private func specRow(icon: String, title: String, value: String, badge: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                Text(value)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                    .lineLimit(1)
            }

            Spacer()

            Text(badge)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(ArcWickyTheme.Palette.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(ArcWickyTheme.Palette.surfaceElevated))
                .overlay(Capsule().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(ArcWickyTheme.Palette.surfaceContainerLow)
        )
    }

    private func legendDot(color: Color, title: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(ArcWickyTheme.Palette.textMuted)
        }
    }
}

// MARK: - Wine & Prefix Activity Diagnostics Card
struct WineActivityDiagnosticsCard: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 15))
                        .foregroundStyle(ArcWickyTheme.Palette.accentMint)

                    Text("WINE RUNTIME & PREFIX ACTIVITY")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.textPrimary)
                        .tracking(1.0)
                }

                Spacer()

                Button {
                    appState.copyDiagnosticReport()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "doc.on.doc.fill")
                            .font(.system(size: 11))
                        Text("Copy Report")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 28, horizontalPadding: 10))
            }

            // Running Game or Active Activity Items
            VStack(spacing: 8) {
                if let running = appState.installedGames.first(where: { appState.isGameRunning($0) }) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(ArcWickyTheme.Palette.success)
                            .frame(width: 10, height: 10)
                            .shadow(color: ArcWickyTheme.Palette.success, radius: 4)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("GAME PROCESS RUNNING")
                                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                .foregroundStyle(ArcWickyTheme.Palette.success)

                            Text(running.name)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(ArcWickyTheme.Palette.textPrimary)

                            Text("\(running.store.rawValue) Prefix • Metal Translation Active")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                        }

                        Spacer()

                        Button("Stop Game") {
                            appState.stopGame(running)
                        }
                        .buttonStyle(ArcWickyButtonStyle(variant: .destructive, height: 28, horizontalPadding: 10))
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(ArcWickyTheme.Palette.surfaceContainerLow)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(ArcWickyTheme.Palette.success.opacity(0.4), lineWidth: 1.5)
                    )
                }

                // Prefix Status Row for Steam, Epic, GOG
                ForEach(GameStore.allCases) { store in
                    prefixStatusRow(store: store)
                }
            }

            // Quick Diagnostic Tools
            HStack(spacing: 10) {
                Button {
                    if let firstError = GameStore.allCases.first(where: {
                        if case .error = appState.status(for: $0) { return true }
                        return false
                    }) {
                        appState.openLogs(for: firstError)
                    } else {
                        appState.openLogs(for: .steam)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "terminal.fill")
                            .font(.system(size: 11))
                        Text("View Wine Logs")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 34))

                Button {
                    appState.refreshBottleMetrics()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 11))
                        Text("Rescan Prefixes")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ArcWickyButtonStyle(variant: .secondary, height: 34))
            }
            .padding(.top, 4)
        }
        .padding(20)
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

    private func prefixStatusRow(store: GameStore) -> some View {
        let status = appState.status(for: store)
        let presentation = StoreStatusPresentation.from(status, store: store, epicAccount: appState.epicAccount)

        return HStack(spacing: 10) {
            StoreLogoTile(store: store, size: 22)

            VStack(alignment: .leading, spacing: 1) {
                Text(store.rawValue)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(ArcWickyTheme.Palette.textPrimary)

                Text(presentation.text)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(ArcWickyTheme.Palette.textMuted)
            }

            Spacer()

            if case .installed = status {
                HStack(spacing: 4) {
                    Circle().fill(ArcWickyTheme.Palette.success).frame(width: 6, height: 6)
                    Text("Prefix Ready")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.success)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(ArcWickyTheme.Palette.surfaceContainerLow))
            } else if case .running = status {
                HStack(spacing: 4) {
                    Circle().fill(ArcWickyTheme.Palette.accentMint).frame(width: 6, height: 6)
                    Text("Running")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.accentMint)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(ArcWickyTheme.Palette.surfaceContainerLow))
            } else if case .error(let msg) = status {
                HStack(spacing: 4) {
                    Circle().fill(ArcWickyTheme.Palette.destructive).frame(width: 6, height: 6)
                    Text("Error")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(ArcWickyTheme.Palette.destructive)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(ArcWickyTheme.Palette.surfaceContainerLow))
                .help(msg)
            } else {
                Text("Standby")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(ArcWickyTheme.Palette.surfaceContainerLow))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(ArcWickyTheme.Palette.surfaceContainerLow)
        )
    }
}
