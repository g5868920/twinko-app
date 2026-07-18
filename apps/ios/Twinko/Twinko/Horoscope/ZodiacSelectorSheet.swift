import SwiftUI

/// Branded zodiac selector: three-column grid of the twelve canonical
/// symbol assets. Tapping applies immediately and dismisses; the
/// profile sign carries a "My Sign" badge; selected state is drawn in
/// code (gold ring + surface), never a separate PNG.
struct ZodiacSelectorSheet: View {
    let selected: ZodiacSign
    let mySign: ZodiacSign?
    let onSelect: (ZodiacSign) -> Void

    @EnvironmentObject private var prefs: PrefsStore
    @Environment(\.dismiss) private var dismiss

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        ZStack {
            // Deep-violet starry night — the sheet stays inside the
            // Twinko world instead of a flat near-black panel.
            LinearGradient(colors: [Color(hex: 0x1C1740),
                                    Color(hex: 0x2E2260),
                                    Color(hex: 0x171233)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            StarFieldView().opacity(0.5)

            VStack(spacing: TwinkoSpacing.s) {
                Capsule()
                    .fill(Color.textInverseToken.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                Text(HoroscopeStrings.selectorTitle(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.textInverseToken)
                    .padding(.top, 4)
                Text(HoroscopeStrings.selectorHelper(lang))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TwinkoSpacing.l)

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: TwinkoSpacing.s),
                                             count: 3),
                              spacing: TwinkoSpacing.s) {
                        ForEach(ZodiacSign.allCases, id: \.self) { sign in
                            ZodiacSelectorItem(sign: sign,
                                               isSelected: sign == selected,
                                               isMySign: sign == mySign,
                                               lang: lang) {
                                onSelect(sign)
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, TwinkoSpacing.m)
                    .padding(.vertical, TwinkoSpacing.s)
                }
            }
        }
        // Open tall enough that all 12 signs are visible
        // immediately — no drag needed (refinement 2026-07-16).
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}

struct ZodiacSelectorItem: View {
    let sign: ZodiacSign
    let isSelected: Bool
    let isMySign: Bool
    let lang: AppLanguage
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZodiacGlyphView(sign: sign, size: 44, emphasized: isSelected)
                Text(sign.displayName(for: lang))
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.textInverseToken)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if isMySign {
                    Text(HoroscopeStrings.mySign(lang))
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.inkNavy)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color.twinkoGold, in: Capsule())
                } else {
                    // Keeps all cells the same height.
                    Text(" ")
                        .font(.system(size: 9, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 96)
            .padding(.vertical, 8)
            // Shared illuminated night-glass selection language — the
            // same recipe as Meditation setup and Tarot chips.
            .twinkoNightChoice(cornerRadius: 16, selected: isSelected)
            .contentShape(Rectangle())
        }
        .buttonStyle(TwinkoHapticPressStyle())
        .accessibilityIdentifier("zodiacOption-\(sign.canonicalID)")
        .accessibilityLabel(Text(sign.horoscopeAccessibilityLabel(lang, isMySign: isMySign,
                                                                  isSelected: isSelected)))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
