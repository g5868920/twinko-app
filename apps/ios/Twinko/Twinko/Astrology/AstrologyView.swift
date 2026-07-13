import SwiftUI

/// 每日星座 (S-021): zodiac from the locally stored birthday, with the
/// full approved field set on a cosmic card layout. Content is local,
/// deterministic, and framed as reflection/entertainment.
struct AstrologyView: View {
    @EnvironmentObject private var profileStore: ProfileStore

    private var sign: ZodiacSign {
        if let birthday = profileStore.profile?.birthday {
            return ZodiacSign.from(date: birthday)
        }
        return .aries
    }

    private var daily: DailyAstrology {
        AstrologyContent.daily(for: sign)
    }

    var body: some View {
        ZStack {
            TwinkoBackground.cosmos.ignoresSafeArea()
            StarFieldView()

            ScrollView {
                VStack(spacing: TwinkoSpacing.m) {
                    header

                    insightCard(title: "整體運勢", icon: "sun.max.fill", text: daily.overall)
                    insightCard(title: "愛情", icon: "heart.fill", text: daily.love)
                    insightCard(title: "事業", icon: "briefcase.fill", text: daily.career)
                    insightCard(title: "財運", icon: "dollarsign.circle.fill", text: daily.finance)

                    luckyGrid

                    Text(AstrologyContent.disclaimer)
                        .font(.twinkoCaption)
                        .foregroundStyle(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TwinkoSpacing.l)
                        .padding(.bottom, TwinkoSpacing.xl)
                }
                .padding(.horizontal, TwinkoSpacing.m)
            }
        }
        .navigationTitle("每日星座")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.cosmicDeep.opacity(0.6), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var header: some View {
        VStack(spacing: TwinkoSpacing.s) {
            TwinkoCharacterView(mood: .astrology, size: 110)
                .padding(.top, TwinkoSpacing.s)
            Text("\(sign.symbol) \(sign.rawValue)")
                .font(.twinkoLargeTitle)
                .foregroundStyle(.white)
            Text(Date.now.formatted(date: .complete, time: .omitted))
                .font(.twinkoCaption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .accessibilityElement(children: .combine)
    }

    private func insightCard(title: String, icon: String, text: String) -> some View {
        TwinkoCard(tone: .dark) {
            VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                Label(title, systemImage: icon)
                    .font(.twinkoHeadline)
                    .foregroundStyle(Color.twinkoGold)
                Text(text)
                    .font(.twinkoBody)
                    .foregroundStyle(.white.opacity(0.92))
                    .lineSpacing(4)
            }
        }
    }

    private var luckyGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: TwinkoSpacing.s),
                            GridItem(.flexible(), spacing: TwinkoSpacing.s)],
                  spacing: TwinkoSpacing.s) {
            luckyCell(title: "幸運數字", value: "\(daily.luckyNumber)", icon: "number")
            luckyCell(title: "幸運顏色", value: daily.luckyColor, icon: "paintpalette.fill")
            luckyCell(title: "幸運星座", value: "\(daily.luckySign.symbol) \(daily.luckySign.rawValue)", icon: "sparkles")
            luckyCell(title: "幸運小物", value: daily.luckyItem, icon: "gift.fill")
        }
    }

    private func luckyCell(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Label(title, systemImage: icon)
                .font(.twinkoCaption)
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .font(.twinkoHeadline)
                .foregroundStyle(Color.twinkoGold)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 76)
        .padding(TwinkoSpacing.s)
        .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(title)：\(value)"))
    }
}

#Preview {
    NavigationStack {
        AstrologyView()
            .environmentObject(ProfileStore())
    }
    .environment(\.locale, Locale(identifier: "zh-Hant"))
}
