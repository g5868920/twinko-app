import SwiftUI

// MARK: - Palette
// Working palette families from the Brand Character Guide §7: Twinko Gold,
// Warm Orange, Lavender, pink-lavender sky, Deep Cosmic Purple, Midnight
// Navy, Soft White. Values tuned against the master visual reference.

extension Color {
    static let twinkoGold = Color(red: 1.00, green: 0.78, blue: 0.24)
    static let twinkoGoldDeep = Color(red: 0.97, green: 0.63, blue: 0.16)
    static let warmOrange = Color(red: 0.96, green: 0.55, blue: 0.26)
    static let cheekOrange = Color(red: 0.94, green: 0.44, blue: 0.27)
    static let lavender = Color(red: 0.72, green: 0.62, blue: 0.88)
    static let skyPink = Color(red: 0.91, green: 0.66, blue: 0.77)
    static let skyPurple = Color(red: 0.56, green: 0.44, blue: 0.76)
    static let cosmicPurple = Color(red: 0.30, green: 0.23, blue: 0.48)
    static let cosmicDeep = Color(red: 0.18, green: 0.13, blue: 0.33)
    static let midnightNavy = Color(red: 0.10, green: 0.12, blue: 0.24)
    static let nightGlow = Color(red: 0.32, green: 0.22, blue: 0.30)
    static let softWhite = Color(red: 0.99, green: 0.97, blue: 0.93)
    static let inkNavy = Color(red: 0.13, green: 0.14, blue: 0.25)
}

// MARK: - Mode environments

enum TwinkoBackground {
    /// Pink/lavender/warm sky — Welcome and Home.
    static let sky = LinearGradient(
        colors: [.skyPurple, .skyPink, Color(red: 0.97, green: 0.75, blue: 0.55)],
        startPoint: .top, endPoint: .bottom
    )
    /// Warm night room — Chat.
    static let night = LinearGradient(
        colors: [.midnightNavy, Color(red: 0.16, green: 0.15, blue: 0.30), .nightGlow],
        startPoint: .top, endPoint: .bottom
    )
    /// Deep violet star field — Tarot.
    static let tarot = LinearGradient(
        colors: [.cosmicDeep, .cosmicPurple, Color(red: 0.36, green: 0.24, blue: 0.52)],
        startPoint: .top, endPoint: .bottom
    )
    /// Cosmic tone — Astrology.
    static let cosmos = LinearGradient(
        colors: [Color(red: 0.14, green: 0.12, blue: 0.32), .cosmicPurple, .skyPurple],
        startPoint: .top, endPoint: .bottom
    )
}

// MARK: - Metrics

enum TwinkoSpacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
}

enum TwinkoRadius {
    static let card: CGFloat = 20
    static let tile: CGFloat = 24
    static let bubble: CGFloat = 16
}

enum TwinkoMotion {
    static let quick: Double = 0.2
    static let standard: Double = 0.35
    static let reveal: Double = 0.8
}

// MARK: - Typography
// Rounded native typography per Brand Guide §8; system rounded design
// falls back cleanly for Traditional Chinese glyphs.

extension Font {
    static let twinkoLargeTitle = Font.system(size: 38, weight: .bold, design: .rounded)
    static let twinkoTitle = Font.system(.title2, design: .rounded).weight(.bold)
    static let twinkoHeadline = Font.system(.headline, design: .rounded)
    static let twinkoBody = Font.system(.body, design: .rounded)
    static let twinkoCaption = Font.system(.caption, design: .rounded)
}

// MARK: - Star field decoration

/// Small deterministic scatter of soft gold stars used on sky/cosmic
/// backgrounds. Positions are fixed (no randomness) so screens render
/// identically on every launch.
struct StarFieldView: View {
    var tint: Color = .twinkoGold
    private static let points: [(x: CGFloat, y: CGFloat, s: CGFloat)] = [
        (0.10, 0.08, 5), (0.85, 0.06, 4), (0.30, 0.16, 3), (0.68, 0.20, 5),
        (0.15, 0.32, 4), (0.92, 0.30, 3), (0.05, 0.55, 3), (0.88, 0.52, 5),
        (0.22, 0.72, 3), (0.78, 0.78, 4), (0.45, 0.05, 3), (0.55, 0.88, 3)
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(Self.points.enumerated()), id: \.offset) { _, p in
                Circle()
                    .fill(tint.opacity(0.55))
                    .frame(width: p.s, height: p.s)
                    .position(x: geo.size.width * p.x, y: geo.size.height * p.y)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
