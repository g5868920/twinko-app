import SwiftUI

// MARK: - Magical CTA press treatment (redesign §23)

/// One centralized press treatment for Tarot action CTAs: a gentle
/// 0.97 scale, a soft warm-gold halo, a few restrained edge sparkles,
/// and light haptic feedback. Pure navigation controls (Back, text
/// links) keep standard pressed feedback instead. Respects Reduce
/// Motion (no sparkles, no halo bloom — scale only).
struct TarotMagicPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && isEnabled
        configuration.label
            .background {
                if pressed && !reduceMotion {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(Color.twinkoGold)
                        .blur(radius: 18)
                        .opacity(0.35)
                        .padding(-4)
                        .allowsHitTesting(false)
                }
            }
            .overlay {
                if pressed && !reduceMotion {
                    TarotPressSparkles()
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .scaleEffect(pressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.18), value: pressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed && isEnabled {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }
}

/// A few tiny fixed sparks near the control edges — restrained, no
/// particle burst.
struct TarotPressSparkles: View {
    @State private var shown = false

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<4, id: \.self) { index in
                let p: [(x: CGFloat, y: CGFloat)] = [(0.08, 0.2), (0.93, 0.3),
                                                     (0.15, 0.85), (0.86, 0.78)]
                Image(systemName: "sparkle")
                    .font(.system(size: 7))
                    .foregroundStyle(Color.twinkoGold.opacity(shown ? 0.85 : 0))
                    .position(x: geo.size.width * p[index].x,
                              y: geo.size.height * p[index].y)
                    .animation(.easeOut(duration: 0.25).delay(Double(index) * 0.04),
                               value: shown)
            }
        }
        .onAppear { shown = true }
    }
}

// MARK: - Tarot CTA palette (premium amethyst system, 2026-07-17)

/// Brand logic: blue-violet = magical energy, antique gold = chosen /
/// sacred / resolved. CTAs move off the bright orange treatment onto
/// a deep amethyst base with antique-gold accents.
enum TarotCTAPalette {
    static let amethystTop = Color(hex: 0x6A4BAB)
    static let amethystBottom = Color(hex: 0x3E2578)
    static let deepSurface = Color(hex: 0x2C1A52)
    static let antiqueGold = Color(hex: 0xD8B36A)
    static let warmLightText = Color(hex: 0xF7EFDD)
    static let violetGlow = Color(hex: 0x8A6FD0)
}

/// Primary Tarot CTA (下一步 / 抽一張指引牌 / 生成專屬冥想 / core
/// actions): deep amethyst gradient, antique-gold border, light warm
/// text, restrained violet glow — plus the magical press sequence
/// (scale, halo, sparkles, light haptic). `buttonStyle` does not
/// compose, so this style renders the full treatment.
struct TarotMagicPrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && isEnabled
        configuration.label
            .font(.twinkoHeadline)
            .foregroundStyle(TarotCTAPalette.warmLightText)
            .padding(.vertical, 15)
            .padding(.horizontal, TwinkoSpacing.xl)
            .frame(minHeight: 44)
            .background(
                LinearGradient(colors: [TarotCTAPalette.amethystTop,
                                        TarotCTAPalette.amethystBottom],
                               startPoint: .top, endPoint: .bottom),
                in: Capsule()
            )
            .overlay(
                Capsule().strokeBorder(
                    LinearGradient(colors: [TarotCTAPalette.antiqueGold.opacity(0.95),
                                            TarotCTAPalette.antiqueGold.opacity(0.45)],
                                   startPoint: .top, endPoint: .bottom),
                    lineWidth: 1.4)
            )
            .background {
                if pressed && !reduceMotion {
                    Capsule()
                        .fill(TarotCTAPalette.violetGlow)
                        .blur(radius: 18)
                        .opacity(0.45)
                        .padding(-4)
                        .allowsHitTesting(false)
                }
            }
            .overlay {
                if pressed && !reduceMotion {
                    TarotPressSparkles()
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .shadow(color: TarotCTAPalette.violetGlow.opacity(0.4), radius: 10, y: 4)
            .opacity(isEnabled ? 1 : 0.55)
            .scaleEffect(pressed ? 0.97 : 1)
            .animation(.easeOut(duration: TwinkoMotion.quick), value: pressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed && isEnabled {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }
}

extension ButtonStyle where Self == TarotMagicPrimaryButtonStyle {
    static var tarotMagicPrimary: TarotMagicPrimaryButtonStyle {
        TarotMagicPrimaryButtonStyle()
    }
}

/// Secondary Tarot CTA (儲存指引小卡 / 開始新的占卜): quieter deep-
/// purple surface with a thin antique-gold border — same family and
/// hierarchy as the primary, with the same restrained press feedback.
struct TarotMagicSecondaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && isEnabled
        configuration.label
            .font(.system(.headline, design: .rounded))
            .foregroundStyle(TarotCTAPalette.warmLightText.opacity(0.95))
            .padding(.vertical, 13)
            .padding(.horizontal, TwinkoSpacing.l)
            .frame(minHeight: 44)
            .background(TarotCTAPalette.deepSurface.opacity(0.72), in: Capsule())
            .overlay(
                Capsule().strokeBorder(TarotCTAPalette.antiqueGold.opacity(0.5),
                                       lineWidth: 1)
            )
            .overlay {
                if pressed && !reduceMotion {
                    TarotPressSparkles()
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .opacity(isEnabled ? 1 : 0.55)
            .scaleEffect(pressed ? 0.97 : 1)
            .animation(.easeOut(duration: TwinkoMotion.quick), value: pressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed && isEnabled {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }
}

extension ButtonStyle where Self == TarotMagicSecondaryButtonStyle {
    static var tarotMagicSecondary: TarotMagicSecondaryButtonStyle {
        TarotMagicSecondaryButtonStyle()
    }
}

// MARK: - Magical divider (redesign §29)

/// Reusable subtle divider for major result-page group transitions:
/// a thin low-opacity warm-gold line with a small centered sparkle and
/// faint dust. Decorative only — hidden from VoiceOver. Never placed
/// between every paragraph.
struct TarotMagicalDivider: View {
    var body: some View {
        HStack(spacing: 10) {
            line
            Image(systemName: "sparkle")
                .font(.system(size: 10))
                .foregroundStyle(Color.twinkoGold.opacity(0.75))
            line
        }
        .overlay {
            HStack(spacing: 56) {
                dust
                dust
            }
        }
        .padding(.horizontal, 44)
        .padding(.vertical, TwinkoSpacing.s)
        .accessibilityHidden(true)
    }

    private var line: some View {
        LinearGradient(colors: [Color.twinkoGold.opacity(0.02),
                                Color.twinkoGold.opacity(0.4),
                                Color.twinkoGold.opacity(0.02)],
                       startPoint: .leading, endPoint: .trailing)
            .frame(height: 1)
    }

    private var dust: some View {
        Circle()
            .fill(Color.twinkoGold.opacity(0.35))
            .frame(width: 2.5, height: 2.5)
    }
}

// MARK: - Revealed-card magic effect (redesign §22)

/// Subtle confirmation that a card has been revealed and activated:
/// a soft warm-gold outer glow with a faint slow breathing shimmer.
/// Static glow under Reduce Motion; never neon, flashing, or a burst.
struct TarotRevealedGlow: ViewModifier {
    let active: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathing = false

    func body(content: Content) -> some View {
        content
            .shadow(color: Color.twinkoGold.opacity(active ? (breathing ? 0.55 : 0.35) : 0),
                    radius: active ? 10 : 0)
            .onChange(of: active) { _, nowActive in
                guard nowActive, !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    breathing = true
                }
            }
            .onAppear {
                guard active, !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    breathing = true
                }
            }
    }
}

extension View {
    func tarotRevealedGlow(_ active: Bool) -> some View {
        modifier(TarotRevealedGlow(active: active))
    }

    /// The one moonlit-ivory matte reading surface used by every
    /// result group: warm ivory with a subtle lavender undertone —
    /// never pure white — restrained shadow, consistent radius, and
    /// generous inner padding. One editorial system.
    func tarotReadingCard() -> some View {
        self
            .padding(TwinkoSpacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: [Color(hex: 0xFAF4E6),
                                        Color(hex: 0xF1EAF2)],
                               startPoint: .top, endPoint: .bottom)
                    .opacity(0.96),
                in: RoundedRectangle(cornerRadius: TwinkoRadius.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TwinkoRadius.card)
                    .strokeBorder(Color(hex: 0xD8B36A).opacity(0.35), lineWidth: 1)
            )
            .shadow(color: Color(hex: 0x2C1A52).opacity(0.18), radius: 7, y: 3)
            .padding(.horizontal, TwinkoSpacing.m)
    }
}
