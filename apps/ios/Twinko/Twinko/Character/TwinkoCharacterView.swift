import SwiftUI

/// Twinko's moods. One reusable component renders every appearance in the
/// app so face placement, proportions, and glow stay consistent across
/// screens (Brand Character Guide §3 consistency rules).
enum TwinkoMood {
    case neutral
    case listening
    case thinking
    case happy
    case concerned
    case tarot
    case astrology

    fileprivate var eyes: EyeStyle {
        switch self {
        case .happy, .astrology: return .happyArc
        case .thinking: return .lookUp
        case .concerned: return .soft
        default: return .open
        }
    }

    fileprivate var mouth: MouthStyle {
        switch self {
        case .happy, .astrology: return .grin
        case .thinking: return .hmm
        case .concerned: return .worried
        default: return .smile
        }
    }

    fileprivate var tilt: Double {
        switch self {
        case .listening: return 5
        case .thinking: return -4
        default: return 0
        }
    }
}

fileprivate enum EyeStyle { case open, happyArc, lookUp, soft }
fileprivate enum MouthStyle { case smile, grin, hmm, worried }

/// The one reusable Twinko character. Rounded five-point star body with a
/// golden gradient, soft internal glow, consistent face, mood variants,
/// and lightweight mode accessories (wizard hat for Tarot, sparkles for
/// Astrology). Drawn entirely with native shapes — no image assets.
struct TwinkoCharacterView: View {
    var mood: TwinkoMood = .neutral
    var size: CGFloat = 160

    private var bodyGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 1.0, green: 0.85, blue: 0.38), .twinkoGold, .twinkoGoldDeep],
            startPoint: .top, endPoint: .bottom
        )
    }

    var body: some View {
        ZStack {
            TwinkoStar()
                .fill(bodyGradient)
                .overlay(
                    // Soft internal glow near the heart of the star.
                    TwinkoStar()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.35), .clear],
                                center: .init(x: 0.5, y: 0.42),
                                startRadius: 0, endRadius: size * 0.42
                            )
                        )
                )
                .frame(width: size, height: size)
                .shadow(color: Color.twinkoGold.opacity(0.55), radius: size * 0.10)
                .shadow(color: Color.warmOrange.opacity(0.25), radius: size * 0.22)

            face
                .offset(y: size * 0.02)

            if mood == .tarot {
                wizardHat
                    .frame(width: size * 0.52, height: size * 0.42)
                    .rotationEffect(.degrees(-12))
                    .offset(x: size * 0.06, y: -size * 0.46)
            }
            if mood == .astrology {
                sparkles
            }
        }
        .frame(width: size, height: size * (mood == .tarot ? 1.25 : 1), alignment: .bottom)
        .rotationEffect(.degrees(mood.tilt))
        .accessibilityLabel(Text("Twinko"))
        .accessibilityHidden(false)
    }

    // MARK: Face

    private var face: some View {
        VStack(spacing: size * 0.045) {
            HStack(spacing: size * 0.20) {
                eye
                eye
            }
            mouthView
            HStack(spacing: size * 0.40) {
                cheek
                cheek
            }
            .offset(y: -size * 0.085)
        }
    }

    @ViewBuilder
    private var eye: some View {
        switch mood.eyes {
        case .open:
            openEye(scale: 1)
        case .soft:
            openEye(scale: 0.82)
        case .lookUp:
            openEye(scale: 0.9)
                .offset(y: -size * 0.02)
        case .happyArc:
            HappyEyeArc()
                .stroke(Color.black.opacity(0.9),
                        style: StrokeStyle(lineWidth: size * 0.024, lineCap: .round))
                .frame(width: size * 0.10, height: size * 0.05)
        }
    }

    private func openEye(scale: CGFloat) -> some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.92))
                .frame(width: size * 0.085 * scale, height: size * 0.105 * scale)
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.028, height: size * 0.028)
                .offset(x: -size * 0.016, y: -size * 0.022)
        }
        .frame(width: size * 0.10, height: size * 0.11)
    }

    @ViewBuilder
    private var mouthView: some View {
        switch mood.mouth {
        case .smile:
            MouthCurve(depth: 0.55)
                .stroke(Color.black.opacity(0.85),
                        style: StrokeStyle(lineWidth: size * 0.022, lineCap: .round))
                .frame(width: size * 0.15, height: size * 0.06)
        case .grin:
            MouthCurve(depth: 1.0)
                .stroke(Color.black.opacity(0.85),
                        style: StrokeStyle(lineWidth: size * 0.024, lineCap: .round))
                .frame(width: size * 0.19, height: size * 0.08)
        case .hmm:
            Capsule()
                .fill(Color.black.opacity(0.8))
                .frame(width: size * 0.07, height: size * 0.018)
        case .worried:
            MouthCurve(depth: -0.4)
                .stroke(Color.black.opacity(0.8),
                        style: StrokeStyle(lineWidth: size * 0.02, lineCap: .round))
                .frame(width: size * 0.11, height: size * 0.05)
        }
    }

    private var cheek: some View {
        Ellipse()
            .fill(Color.cheekOrange.opacity(0.55))
            .frame(width: size * 0.105, height: size * 0.06)
    }

    // MARK: Accessories

    private var wizardHat: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // Brim
                Ellipse()
                    .fill(Color.cosmicPurple)
                    .frame(width: w, height: h * 0.28)
                    .offset(y: h * 0.36)
                // Cone
                WizardCone()
                    .fill(
                        LinearGradient(colors: [.skyPurple, .cosmicPurple],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: w * 0.62, height: h * 0.82)
                    .offset(y: -h * 0.05)
                // Gold band
                Capsule()
                    .fill(Color.twinkoGold)
                    .frame(width: w * 0.5, height: h * 0.09)
                    .offset(y: h * 0.30)
                // Tiny star on the cone
                TwinkoStar()
                    .fill(Color.twinkoGold)
                    .frame(width: w * 0.18, height: w * 0.18)
                    .offset(x: w * 0.04, y: -h * 0.08)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .accessibilityHidden(true)
    }

    private var sparkles: some View {
        ZStack {
            sparkle(0.34, -0.42, 0.10)
            sparkle(-0.40, -0.30, 0.075)
            sparkle(0.46, 0.05, 0.06)
            sparkle(-0.46, 0.16, 0.08)
        }
        .accessibilityHidden(true)
    }

    private func sparkle(_ dx: CGFloat, _ dy: CGFloat, _ s: CGFloat) -> some View {
        TwinkoStar(innerRatio: 0.42)
            .fill(Color.softWhite.opacity(0.9))
            .frame(width: size * s, height: size * s)
            .offset(x: size * dx, y: size * dy)
    }
}

// MARK: - Support shapes

fileprivate struct MouthCurve: Shape {
    /// Positive bows downward into a smile; negative bows up (worried).
    var depth: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.midY + rect.height * depth)
        )
        return path
    }
}

fileprivate struct HappyEyeArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.4)
        )
        return path
    }
}

fileprivate struct WizardCone: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        // Left side sweeping up to a slightly drooped tip.
        path.addQuadCurve(
            to: CGPoint(x: rect.midX + rect.width * 0.12, y: rect.minY),
            control: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.minY + rect.height * 0.25)
        )
        // Tip curls back down to the right edge.
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.maxX - rect.width * 0.05, y: rect.minY + rect.height * 0.45)
        )
        path.closeSubpath()
        return path
    }
}

#Preview("Moods") {
    ScrollView {
        VStack(spacing: 24) {
            ForEach([TwinkoMood.neutral, .listening, .thinking, .happy, .concerned, .tarot, .astrology], id: \.self) { mood in
                TwinkoCharacterView(mood: mood, size: 120)
            }
        }
        .padding()
    }
    .background(TwinkoBackground.sky)
}

extension TwinkoMood: Hashable {}
