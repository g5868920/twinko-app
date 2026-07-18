import SwiftUI

// MARK: - Horoscope CTA family (feature-scoped, 2026-07-17)

/// Horoscope's premium action treatment: deep grape base with
/// antique-gold accents — calmer than the old bright-gold fill, and
/// deliberately distinct from Tarot's amethyst so the surface keeps
/// its own identity against the starry background.
enum HoroscopeCTAPalette {
    static let grapeTop = Color(hex: 0x5B3A94)
    static let grapeBottom = Color(hex: 0x372359)
    static let antiqueGold = Color(hex: 0xD8B36A)
    static let warmLightText = Color(hex: 0xF7EFDD)
}

/// Same construction as Tarot's magic primary (capsule, gradient
/// fill, antique-gold gradient rim, glow shadow, press sparkles +
/// light haptic) — only the hue stays Horoscope's grape.
struct HoroscopeGrapePrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && isEnabled
        configuration.label
            .labelStyle(HoroscopeGoldIconLabelStyle())
            .font(.twinkoHeadline)
            .foregroundStyle(HoroscopeCTAPalette.warmLightText)
            .padding(.vertical, 15)
            .padding(.horizontal, TwinkoSpacing.xl)
            .frame(minHeight: 44)
            .background(
                LinearGradient(colors: [HoroscopeCTAPalette.grapeTop,
                                        HoroscopeCTAPalette.grapeBottom],
                               startPoint: .top, endPoint: .bottom),
                in: Capsule()
            )
            .overlay(
                Capsule().strokeBorder(
                    LinearGradient(colors: [HoroscopeCTAPalette.antiqueGold.opacity(0.95),
                                            HoroscopeCTAPalette.antiqueGold.opacity(0.45)],
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

/// Clear night-glass capsule secondary — identical construction to
/// Tarot's magic secondary.
struct HoroscopeGrapeSecondaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && isEnabled
        configuration.label
            .labelStyle(HoroscopeGoldIconLabelStyle())
            .font(.system(.headline, design: .rounded))
            .foregroundStyle(HoroscopeCTAPalette.warmLightText.opacity(0.95))
            .padding(.vertical, 13)
            .padding(.horizontal, TwinkoSpacing.l)
            .frame(minHeight: 44)
            .background {
                Capsule()
                    .fill(LinearGradient(colors: [Color(hex: 0x9C8CD8).opacity(0.42),
                                                  Color(hex: 0x6E5FB0).opacity(0.34)],
                                         startPoint: .top, endPoint: .bottom))
                    .overlay(
                        Capsule().fill(LinearGradient(stops: [
                            .init(color: Color.white.opacity(0.14), location: 0),
                            .init(color: Color.white.opacity(0), location: 0.35),
                        ], startPoint: .top, endPoint: .bottom))
                    )
            }
            .overlay(
                Capsule().strokeBorder(
                    LinearGradient(stops: [
                        .init(color: Color.white.opacity(0.40), location: 0),
                        .init(color: Color(hex: 0xD1C4FF).opacity(0.18), location: 1),
                    ], startPoint: .top, endPoint: .bottom),
                    lineWidth: 1)
            )
            .shadow(color: Color.deepSpace.opacity(0.18), radius: 6, y: 3)
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

/// Antique-gold icon + warm-ivory title for Horoscope actions.
struct HoroscopeGoldIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 7) {
            configuration.icon.foregroundStyle(HoroscopeCTAPalette.antiqueGold)
            configuration.title
        }
    }
}

extension ButtonStyle where Self == HoroscopeGrapePrimaryButtonStyle {
    static var horoscopeGrapePrimary: HoroscopeGrapePrimaryButtonStyle {
        HoroscopeGrapePrimaryButtonStyle()
    }
}
extension ButtonStyle where Self == HoroscopeGrapeSecondaryButtonStyle {
    static var horoscopeGrapeSecondary: HoroscopeGrapeSecondaryButtonStyle {
        HoroscopeGrapeSecondaryButtonStyle()
    }
}

// MARK: - Score view

/// 1–5 star score with an accessible text label. Gold stars, never a
/// warning treatment for low scores.
struct HoroscopeScoreView: View {
    let score: Int
    let lang: AppLanguage

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= score ? "star.fill" : "star")
                    .font(.system(size: 12))
                    // Hollow stars sit in the lilac-white rim family,
                    // not neutral gray.
                    .foregroundStyle(index <= score
                        ? Color.twinkoGold
                        : Color(hex: 0xD1C4FF).opacity(0.45))
            }
            Text(HoroscopeScoreLabel.text(score, lang))
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.8))
                .padding(.leading, 3)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(HoroscopeScoreLabel.accessibilityText(score, lang)))
    }
}

// MARK: - Dimension card

/// Expandable dimension card: title + score + summary always visible,
/// detail revealed on tap. Only one card expands at a time (bound
/// through `expandedKind`).
struct HoroscopeDimensionCard: View {
    let kind: HoroscopeDimensionKind
    let dimension: HoroscopeDimension
    let lang: AppLanguage
    @Binding var expandedKind: HoroscopeDimensionKind?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isExpanded: Bool { expandedKind == kind }

    var body: some View {
        Button {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.22)) {
                expandedKind = isExpanded ? nil : kind
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(kind.title(lang), systemImage: kind.icon)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.twinkoGold)
                    Spacer()
                    HoroscopeScoreView(score: dimension.score, lang: lang)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color(hex: 0xD1C4FF).opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                Text(dimension.summary)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.textInverseToken)
                    .multilineTextAlignment(.leading)
                if isExpanded {
                    Text(dimension.detail)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.85))
                        .lineSpacing(4)
                        .multilineTextAlignment(.leading)
                        .transition(reduceMotion ? .identity : .opacity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(TwinkoSpacing.m)
            // Shared night glass instead of a dark slab; 整體運勢 stays
            // a step denser as the primary reading entry point.
            // Readability comes from the page-level veil, never a dark
            // base per card — separate dark blocks broke the scene.
            .twinkoGlass(cornerRadius: TwinkoRadius.card,
                         tint: kind == .overall ? 0.48 : 0.40, night: true)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("horoscopeDimension-\(kind.rawValue)")
        .accessibilityLabel(Text(
            "\(kind.title(lang))，\(HoroscopeScoreLabel.accessibilityText(dimension.score, lang))。\(dimension.summary)"))
        .accessibilityHint(Text(lang == .english
            ? (isExpanded ? "Double tap to collapse" : "Double tap to expand")
            : (isExpanded ? "點兩下收合" : "點兩下展開")))
    }
}

// MARK: - Lucky details

struct LuckyDetailsGrid: View {
    let lucky: LuckyDetails
    let lang: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            // Supporting section — deliberately quieter than the
            // primary reading blocks.
            Label(HoroscopeStrings.luckyTitle(lang), systemImage: "sparkles")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.twinkoGold.opacity(0.85))
            LazyVGrid(columns: [GridItem(.flexible(), spacing: TwinkoSpacing.s),
                                GridItem(.flexible(), spacing: TwinkoSpacing.s)],
                      spacing: TwinkoSpacing.s) {
                LuckyDetailItem(label: HoroscopeStrings.luckyNumber(lang),
                                value: "\(lucky.number)")
                LuckyDetailItem(label: HoroscopeStrings.luckyColor(lang),
                                value: lucky.color.displayName(lang),
                                swatchHex: lucky.color.hex)
                LuckyDetailItem(label: HoroscopeStrings.luckyZodiac(lang),
                                value: lucky.luckySign?.displayName(for: lang) ?? "—",
                                zodiacSign: lucky.luckySign)
                LuckyDetailItem(label: HoroscopeStrings.luckyItem(lang),
                                value: lucky.item)
            }
        }
        .padding(TwinkoSpacing.m)
        .twinkoGlass(cornerRadius: TwinkoRadius.card, tint: 0.38, night: true)
    }
}

struct LuckyDetailItem: View {
    let label: String
    let value: String
    var swatchHex: String? = nil
    var zodiacSign: ZodiacSign? = nil

    var body: some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.75))
            HStack(spacing: 6) {
                if let zodiacSign {
                    ZodiacGlyphView(sign: zodiacSign, size: 18, emphasized: false)
                }
                if let swatchHex, let color = Color(horoscopeHex: swatchHex) {
                    Circle()
                        .fill(color)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().strokeBorder(Color.textInverseToken.opacity(0.4),
                                                       lineWidth: 0.5))
                        .accessibilityHidden(true)
                }
                Text(value)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.twinkoGold)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 56)
        .padding(TwinkoSpacing.s)
        // Lighter nested night glass (no extra shadow inside the
        // parent card).
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: 0x9C8CD8).opacity(0.26),
                                              Color(hex: 0x6E5FB0).opacity(0.20)],
                                     startPoint: .top, endPoint: .bottom))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    LinearGradient(stops: [
                        .init(color: Color.white.opacity(0.28), location: 0),
                        .init(color: Color(hex: 0xD1C4FF).opacity(0.14), location: 1),
                    ], startPoint: .top, endPoint: .bottom),
                    lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(label)：\(value)"))
    }
}

// MARK: - Twinko message block

struct TwinkoMessageBlock: View {
    let message: String
    let lang: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(HoroscopeStrings.twinkoSays(lang))
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.twinkoGold)
            Text(message)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textInverseToken)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(TwinkoSpacing.m)
        // Twinko's own words ride the warm-night speech glass, same as
        // the Meditation source card.
        .twinkoGlass(cornerRadius: TwinkoRadius.card, tint: 0.42,
                     warm: true, night: true)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Empty / retry state

struct HoroscopeEmptyStateView: View {
    let lang: AppLanguage
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: TwinkoSpacing.m) {
            Spacer()
            Image("twinko_horoscope_default_v1_transparent")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .accessibilityHidden(true)
            Text(HoroscopeStrings.emptyMessage(lang))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, TwinkoSpacing.l)
            Button {
                onRetry()
            } label: {
                Text(HoroscopeStrings.retry(lang))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.horoscopeGrapePrimary)
            .padding(.horizontal, TwinkoSpacing.xl)
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Hex color

extension Color {
    /// Parses "#RRGGBB" swatch values from horoscope content.
    init?(horoscopeHex: String) {
        var text = horoscopeHex.trimmingCharacters(in: .whitespaces)
        if text.hasPrefix("#") { text.removeFirst() }
        guard text.count == 6, let value = UInt32(text, radix: 16) else { return nil }
        self.init(hex: value)
    }
}
