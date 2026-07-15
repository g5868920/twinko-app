import SwiftUI

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
                    .foregroundStyle(index <= score
                        ? Color.twinkoGold
                        : Color.textInverseToken.opacity(0.35))
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
                        .foregroundStyle(Color.textInverseToken.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                Text(dimension.summary)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.92))
                    .multilineTextAlignment(.leading)
                if isExpanded {
                    Text(dimension.detail)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.78))
                        .lineSpacing(4)
                        .multilineTextAlignment(.leading)
                        .transition(reduceMotion ? .identity : .opacity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(TwinkoSpacing.m)
            .background(Color.deepSpace.opacity(0.45),
                        in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
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
            Label(HoroscopeStrings.luckyTitle(lang), systemImage: "sparkles")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.twinkoGold)
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
                                zodiacAsset: lucky.luckySign?.symbolAssetName)
                LuckyDetailItem(label: HoroscopeStrings.luckyItem(lang),
                                value: lucky.item)
            }
        }
        .padding(TwinkoSpacing.m)
        .background(Color.deepSpace.opacity(0.45),
                    in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
    }
}

struct LuckyDetailItem: View {
    let label: String
    let value: String
    var swatchHex: String? = nil
    var zodiacAsset: String? = nil

    var body: some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.65))
            HStack(spacing: 6) {
                if let zodiacAsset {
                    Image(zodiacAsset)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .accessibilityHidden(true)
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
        .frame(maxWidth: .infinity, minHeight: 62)
        .padding(TwinkoSpacing.s)
        .background(Color.textInverseToken.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 14))
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
                .foregroundStyle(Color.textInverseToken.opacity(0.94))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(TwinkoSpacing.m)
        .background(Color.menuDeep.opacity(0.55),
                    in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: TwinkoRadius.card)
                .strokeBorder(Color.twinkoGold.opacity(0.3), lineWidth: 1)
        )
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
            .buttonStyle(.twinkoPrimary)
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
