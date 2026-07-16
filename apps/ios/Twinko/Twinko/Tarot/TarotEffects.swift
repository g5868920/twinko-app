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

/// The primary Tarot action CTA: the standard gold-gradient capsule
/// plus the magical press sequence (scale, halo, sparkles, haptic).
/// `buttonStyle` does not compose, so this style renders both layers.
struct TarotMagicPrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && isEnabled
        configuration.label
            .font(.twinkoHeadline)
            .foregroundStyle(.white)
            .padding(.vertical, 15)
            .padding(.horizontal, TwinkoSpacing.xl)
            .frame(minHeight: 44)
            .background(
                LinearGradient(colors: [.twinkoGold, .warmOrange],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                in: Capsule()
            )
            .background {
                if pressed && !reduceMotion {
                    Capsule()
                        .fill(Color.twinkoGold)
                        .blur(radius: 18)
                        .opacity(0.4)
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
            .shadow(color: Color.warmOrange.opacity(0.45), radius: 10, y: 4)
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

    /// The one warm-white matte reading surface used by every result
    /// group (redesign §28): warm ivory, restrained shadow, consistent
    /// radius and generous inner padding — one editorial system.
    func tarotReadingCard() -> some View {
        self
            .padding(TwinkoSpacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surfacePrimary.opacity(0.97),
                        in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
            .overlay(
                RoundedRectangle(cornerRadius: TwinkoRadius.card)
                    .strokeBorder(Color.borderSoft.opacity(0.8), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
            .padding(.horizontal, TwinkoSpacing.m)
    }
}
