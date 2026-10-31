import SwiftUI
import AppKit

// MARK: - Collection Safe Subscript
public extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Color Hex Initializer
public extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - ArcWicky Design System
// Tactile Vinyl & Spatial Cartoon Design System (Polar Fusion).
// Engineered for Apple Silicon Liquid Retina XDR displays.

public enum ArcWickyTheme {
    // MARK: - Palette (Polar Fusion & Tactile Vinyl Tokens)
    public enum Palette {
        /// Midnight Ink Canvas (#090B11)
        public static let canvas = Color(hex: "#090B11")
        /// Recessed Floor (#070E1F)
        public static let canvasLowest = Color(hex: "#070E1F")
        /// Chunky Deep Slate (#181F31)
        public static let surface = Color(hex: "#181F31")
        /// Recessed Base Tray (#141B2D)
        public static let surfaceContainerLow = Color(hex: "#141B2D")
        /// Muted Navy Container / Raised Cards (#232A3C)
        public static let surfaceElevated = Color(hex: "#232A3C")
        /// Highlight & Pop Surface (#2D3447)
        public static let surfaceHighlight = Color(hex: "#2D3447")
        /// Structural Boundary Outline (#303B59)
        public static let border = Color(hex: "#303B59")
        /// Interactive Outline Variant (#424848)
        public static let borderHover = Color(hex: "#424848")
        public static let borderSubtle = Color(hex: "#303B59").opacity(0.4)
        public static let glass = Color.white.opacity(0.04)

        /// Glacial Mint / Primary Fixed Accent (#CDE8EA / #DDF8FA)
        public static let accent = Color(hex: "#CDE8EA")
        public static let accentMint = Color(hex: "#DDF8FA")
        public static let accentMuted = Color(hex: "#50696B")
        public static let accentDeep = Color(hex: "#8BC4C9")
        public static let onPrimaryFixed = Color(hex: "#051F21")

        /// Crisp Specular / Primary Text (#DCE8FF)
        public static let textPrimary = Color(hex: "#DCE8FF")
        /// Secondary Specular / Label Text (#BBC7DD)
        public static let textSecondary = Color(hex: "#BBC7DD")
        /// Secondary Fixed Pale Blue (#D7E3FA)
        public static let secondaryFixed = Color(hex: "#D7E3FA")
        /// Muted Tertiary / Placeholder Text (#8B9292)
        public static let textMuted = Color(hex: "#8B9292")

        /// Ambient Violet Mist Glow (#F0EAFE)
        public static let violet = Color(hex: "#F0EAFE")
        public static let ambientViolet = Color(hex: "#F0EAFE")

        /// Tactile Status Diode Colors
        public static let success = Color(hex: "#27C93F")
        public static let warning = Color(hex: "#FFBD2E")
        public static let destructive = Color(hex: "#FF5F56")

        // Compatibility Aliases
        public static var obsidianBase: Color { canvas }
        public static var surfaceDeck: Color { surface }
        public static var cyanAccent: Color { accent }
        public static var solarAmber: Color { warning }
        public static var violetAccent: Color { violet }
        public static var cyanGradient: LinearGradient {
            LinearGradient(
                colors: [accentMint, accent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        public static var emeraldLaser: Color { success }
        public static var specularBorder: Color { border }
    }

    // MARK: - Typography (Chunky Cartoon & Editorial Geometry)
    public enum Typography {
        /// Monumental Cartoon Hero Title
        public static let displayHero = Font.system(size: 38, weight: .black, design: .rounded)
        public static let headline = Font.system(size: 18, weight: .bold, design: .rounded)
        public static let title = Font.system(size: 22, weight: .heavy, design: .rounded)
        public static let sectionHeader = Font.system(size: 14, weight: .bold, design: .rounded)
        public static let cardTitle = Font.system(size: 16, weight: .bold, design: .rounded)
        public static let body = Font.system(size: 14, weight: .medium, design: .rounded)
        public static let bodyMedium = Font.system(size: 14, weight: .semibold, design: .rounded)
        public static let bodyBold = Font.system(size: 14, weight: .bold, design: .rounded)
        public static let callsign = Font.system(size: 13, weight: .bold, design: .rounded)
        public static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
        public static let captionMedium = Font.system(size: 12, weight: .bold, design: .rounded)
        public static let mono = Font.system(size: 12, weight: .medium, design: .monospaced)
    }

    // MARK: - Dimensions (Chunky Vinyl Squircles & Pills)
    public enum Dimensions {
        public static let cornerCard: CGFloat = 32
        public static let cornerButton: CGFloat = 999
        public static let cornerPill: CGFloat = 999
        public static let cornerDock: CGFloat = 28
        public static let sidebarWidth: CGFloat = 240
    }
}

// MARK: - Modifiers
public extension View {
    /// Tactile vinyl squircle card container with double-stacked shadow and 1.5px structural border
    func arcWickyCard(
        cornerRadius: CGFloat = ArcWickyTheme.Dimensions.cornerCard,
        background: Color = ArcWickyTheme.Palette.surface
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.45), radius: 14, x: 0, y: 8)
    }

    func arcWickyPanel(
        cornerRadius: CGFloat = ArcWickyTheme.Dimensions.cornerCard,
        backgroundColor: Color = ArcWickyTheme.Palette.surface
    ) -> some View {
        self.arcWickyCard(cornerRadius: cornerRadius, background: backgroundColor)
    }

    func arcWickyGlow(color: Color = ArcWickyTheme.Palette.accentMint, radius: CGFloat = 8) -> some View {
        self.shadow(color: color.opacity(0.25), radius: radius)
    }
}

// MARK: - Button Style (Tactile Vinyl & Extruded Toy Physics)
public struct ArcWickyButtonStyle: ButtonStyle {
    public enum Variant {
        case primary
        case secondary
        case destructive
        case ghost
        case pill(selected: Bool)
        case toyMint
        
        public static var ghostGlass: Variant { .secondary }
        public static var stopCrimson: Variant { .destructive }
        public static var primaryCyan: Variant { .primary }
    }

    var variant: Variant = .primary
    var height: CGFloat = 32
    var horizontalPadding: CGFloat = 16

    public init(variant: Variant = .primary, height: CGFloat = 32, horizontalPadding: CGFloat = 16) {
        self.variant = variant
        self.height = height
        self.horizontalPadding = horizontalPadding
    }

    public init(kind: Variant, height: CGFloat = 32, horizontalPadding: CGFloat = 16) {
        self.variant = kind
        self.height = height
        self.horizontalPadding = horizontalPadding
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ArcWickyTheme.Typography.bodyBold)
            .lineLimit(1)
            .padding(.horizontal, horizontalPadding)
            .frame(height: height)
            .foregroundStyle(foreground)
            .background(background(isPressed: configuration.isPressed))
            .overlay(border)
            .clipShape(Capsule(style: .continuous))
            .shadow(
                color: shadowColor,
                radius: 0,
                x: 0,
                y: configuration.isPressed ? 1 : shadowDepth
            )
            .offset(y: configuration.isPressed ? (shadowDepth - 1) : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }

    private var foreground: Color {
        switch variant {
        case .primary, .toyMint:
            return ArcWickyTheme.Palette.onPrimaryFixed
        case .destructive:
            return Color.white
        case .secondary, .ghost:
            return ArcWickyTheme.Palette.textPrimary
        case .pill(let selected):
            return selected ? ArcWickyTheme.Palette.onPrimaryFixed : ArcWickyTheme.Palette.textSecondary
        }
    }

    private var shadowDepth: CGFloat {
        switch variant {
        case .primary, .toyMint: return 4
        case .secondary, .pill: return 3
        case .destructive: return 4
        case .ghost: return 0
        }
    }

    private var shadowColor: Color {
        switch variant {
        case .primary, .toyMint:
            return ArcWickyTheme.Palette.accentDeep
        case .destructive:
            return Color(hex: "#93000A")
        case .secondary, .pill:
            return Color(hex: "#070E1F")
        case .ghost:
            return Color.clear
        }
    }

    @ViewBuilder
    private func background(isPressed: Bool) -> some View {
        switch variant {
        case .primary, .toyMint:
            ArcWickyTheme.Palette.accent
        case .secondary:
            ArcWickyTheme.Palette.surfaceElevated
        case .destructive:
            ArcWickyTheme.Palette.destructive
        case .ghost:
            isPressed ? Color.white.opacity(0.08) : Color.clear
        case .pill(let selected):
            if selected {
                ArcWickyTheme.Palette.accentMint
            } else {
                ArcWickyTheme.Palette.surfaceElevated
            }
        }
    }

    @ViewBuilder
    private var border: some View {
        switch variant {
        case .primary, .toyMint:
            Capsule().strokeBorder(ArcWickyTheme.Palette.textPrimary.opacity(0.6), lineWidth: 1.5)
        case .secondary:
            Capsule().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
        case .pill(let selected):
            if selected {
                Capsule().strokeBorder(ArcWickyTheme.Palette.textPrimary, lineWidth: 1.5)
            } else {
                Capsule().strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - Giant Monumental "PLAY!" Trigger Button
public struct ArcWickyToyPlayButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .black, design: .rounded))
            .foregroundStyle(ArcWickyTheme.Palette.onPrimaryFixed)
            .padding(.horizontal, 42)
            .frame(height: 60)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#E5F7F8"), ArcWickyTheme.Palette.accentMint],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(Capsule(style: .continuous))
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(Color.white.opacity(0.8), lineWidth: 2)
            )
            .shadow(
                color: Color(hex: "#50696B"),
                radius: 0,
                x: 0,
                y: configuration.isPressed ? 2 : 8
            )
            .shadow(
                color: Color.black.opacity(0.5),
                radius: 16,
                x: 0,
                y: 12
            )
            .offset(y: configuration.isPressed ? 6 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

// MARK: - Status Badge
public struct ArcWickyBadge: View {
    public enum Tone {
        case success
        case accent
        case warning
        case neutral
        case destructive
        
        public static var emerald: Tone { .success }
        public static var cyan: Tone { .accent }

        var color: Color {
            switch self {
            case .success: return ArcWickyTheme.Palette.success
            case .accent: return ArcWickyTheme.Palette.accent
            case .warning: return ArcWickyTheme.Palette.warning
            case .neutral: return ArcWickyTheme.Palette.textMuted
            case .destructive: return ArcWickyTheme.Palette.destructive
            }
        }
    }

    var text: String
    var tone: Tone = .neutral
    var showDot: Bool = true

    public init(text: String, tone: Tone = .neutral, showDot: Bool = true) {
        self.text = text
        self.tone = tone
        self.showDot = showDot
    }

    public init(text: String, diode: Tone, showDot: Bool = true) {
        self.text = text
        self.tone = diode
        self.showDot = showDot
    }

    public var body: some View {
        HStack(spacing: 5) {
            if showDot {
                Circle()
                    .fill(tone.color)
                    .frame(width: 5, height: 5)
            }
            Text(text)
                .font(ArcWickyTheme.Typography.captionMedium)
        }
        .foregroundStyle(tone.color)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: ArcWickyTheme.Dimensions.cornerPill, style: .continuous)
                .fill(tone.color.opacity(0.12))
        )
    }
}

// MARK: - Brand Emblem
public struct ArcWickyBrandMark: View {
    var size: CGFloat = 22

    public init(size: CGFloat = 22) {
        self.size = size
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.20, green: 0.52, blue: 0.98),
                            Color(red: 0.12, green: 0.30, blue: 0.75)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.75)
                )

            // Dynamic geometric "A" arch
            Image(systemName: "triangle.fill")
                .font(.system(size: size * 0.44, weight: .bold))
                .foregroundStyle(Color.white)
                .offset(y: -size * 0.03)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Search Field (Tactile Vinyl Capsule)
public struct ArcWickySearchField: View {
    @Binding var text: String
    var placeholder = "Find games, stores, or bottles…"

    public init(text: Binding<String>, placeholder: String = "Find games, stores, or bottles…") {
        self._text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(ArcWickyTheme.Palette.textMuted)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(ArcWickyTheme.Typography.body)
                .foregroundStyle(ArcWickyTheme.Palette.textPrimary)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                }
                .buttonStyle(.plain)
            } else {
                Text("⌘K")
                    .font(ArcWickyTheme.Typography.mono)
                    .foregroundStyle(ArcWickyTheme.Palette.textMuted)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1.5)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
            }
        }
        .padding(.horizontal, 14)
        .frame(minWidth: 200, idealWidth: 320, maxWidth: 440)
        .frame(height: 34)
        .background(
            Capsule(style: .continuous)
                .fill(ArcWickyTheme.Palette.surface)
        )
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(ArcWickyTheme.Palette.border, lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
    }
}
