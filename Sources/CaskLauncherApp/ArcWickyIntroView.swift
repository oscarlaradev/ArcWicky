import SwiftUI
import AppKit

// MARK: - Screen 1: Instant Native Tactile Vinyl Living Sculpture Intro
// Pure native SwiftUI sculptural typography: zero WebKit processes, zero network delays, instant Metal rendering.
public struct ArcWickyIntroView: View {
    var onContinue: () -> Void
    @State private var hasProceeded = false
    @State private var scale: CGFloat = 0.94
    @State private var opacity: Double = 0.0
    @State private var breathingScale: CGFloat = 1.0

    public init(onContinue: @escaping () -> Void = {}) {
        self.onContinue = onContinue
    }

    public var body: some View {
        ZStack {
            // Dark tactile studio canvas
            ArcWickyTheme.Palette.canvas.ignoresSafeArea()

            // Ambient Glacial Mint atmospheric radial bloom
            RadialGradient(
                colors: [
                    ArcWickyTheme.Palette.accentMint.opacity(0.12),
                    Color(hex: "#101827").opacity(0.4),
                    Color.clear
                ],
                center: .center,
                startRadius: 40,
                endRadius: 520
            )
            .ignoresSafeArea()

            // Centerpiece: 3D Inflatable Balloon Vinyl Typography
            VStack(spacing: 8) {
                ZStack {
                    // Deep extruded drop shadow layers (Tactile Vinyl look)
                    Text("ARCWICKY")
                        .font(.system(size: 84, weight: .black, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.85))
                        .offset(y: 14)
                        .blur(radius: 12)

                    Text("ARCWICKY")
                        .font(.system(size: 84, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#070E1F"))
                        .offset(y: 8)

                    Text("ARCWICKY")
                        .font(.system(size: 84, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#1E293B"))
                        .offset(y: 5)

                    Text("ARCWICKY")
                        .font(.system(size: 84, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#334155"))
                        .offset(y: 2)

                    // Foreground inflatable porcelain / mint sheen
                    Text("ARCWICKY")
                        .font(.system(size: 84, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(hex: "#E0EDFF"),
                                    Color(hex: "#C6DBFC")
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: ArcWickyTheme.Palette.accentMint.opacity(0.35), radius: 24, x: 0, y: 0)
                }
                .scaleEffect(breathingScale)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            proceed()
        }
        .onAppear {
            // Snappy, instant entrance
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                scale = 1.0
                opacity = 1.0
            }

            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                breathingScale = 1.02
            }

            // Snappy auto-proceed (0.75s total duration for instant feel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                proceed()
            }
        }
    }

    private func proceed() {
        guard !hasProceeded else { return }
        hasProceeded = true
        withAnimation(.easeOut(duration: 0.22)) {
            opacity = 0.0
            scale = 1.04
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            onContinue()
        }
    }
}
