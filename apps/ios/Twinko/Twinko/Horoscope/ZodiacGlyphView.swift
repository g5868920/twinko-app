import SwiftUI

/// Code-rendered zodiac glyph (refinement 2026-07-16): replaces the
/// raster symbol assets, whose edges were not clean enough to keep
/// maintaining. Uses the Unicode zodiac glyphs in a rounded system
/// weight with a brand-gold gradient and a soft glow — consistent
/// style, clean edges, brandable, and selected/unselected friendly.
struct ZodiacGlyphView: View {
    let sign: ZodiacSign
    var size: CGFloat = 44
    var emphasized: Bool = true

    var body: some View {
        // U+FE0E forces text presentation — without it the system
        // renders the emoji squircle variant of the zodiac glyph.
        Text(sign.symbol + "\u{FE0E}")
            .font(.system(size: size * 0.82, weight: .semibold, design: .rounded))
            .foregroundStyle(
                LinearGradient(colors: emphasized
                                ? [Color(hex: 0xF6D57C), Color.twinkoGold]
                                : [Color.twinkoGold.opacity(0.85), Color.twinkoGold.opacity(0.65)],
                               startPoint: .top, endPoint: .bottom)
            )
            .shadow(color: Color.twinkoGold.opacity(emphasized ? 0.45 : 0.25),
                    radius: size * 0.10)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
