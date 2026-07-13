import SwiftUI

/// Result stage: each card with its (position-framed) interpretation,
/// the three-card integrated summary, the reflection/entertainment
/// disclaimer, and restart / home actions.
struct TarotResultStage: View {
    let draw: TarotDraw
    let onRestart: () -> Void
    let onHome: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: TwinkoSpacing.m) {
                TwinkoCharacterView(mood: .tarot, size: 100)
                    .padding(.top, TwinkoSpacing.s)

                Text(draw.question)
                    .font(.twinkoHeadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TwinkoSpacing.l)

                ForEach(Array(draw.cards.enumerated()), id: \.element.id) { index, card in
                    cardSection(card: card, index: index)
                }

                if let summary = TarotInterpreter.integratedSummary(for: draw) {
                    TwinkoCard(tone: .dark) {
                        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                            Label("整體來看", systemImage: "sparkles")
                                .font(.twinkoHeadline)
                                .foregroundStyle(Color.twinkoGold)
                            Text(summary)
                                .font(.twinkoBody)
                                .foregroundStyle(.white.opacity(0.92))
                                .lineSpacing(4)
                        }
                    }
                    .padding(.horizontal, TwinkoSpacing.m)
                }

                Text(TarotInterpreter.disclaimer)
                    .font(.twinkoCaption)
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TwinkoSpacing.l)

                VStack(spacing: TwinkoSpacing.s) {
                    Button {
                        onRestart()
                    } label: {
                        Text("再抽一次")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.twinkoPrimary)

                    Button {
                        onHome()
                    } label: {
                        Text("回到首頁")
                            .font(.twinkoHeadline)
                            .foregroundStyle(.white.opacity(0.85))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                }
                .padding(.horizontal, TwinkoSpacing.m)
                .padding(.bottom, TwinkoSpacing.xl)
            }
        }
    }

    @ViewBuilder
    private func cardSection(card: TarotCard, index: Int) -> some View {
        let position: TarotPosition? = draw.spread == .three
            ? TarotPosition.allCases[index]
            : nil

        VStack(spacing: TwinkoSpacing.s) {
            HStack(spacing: TwinkoSpacing.m) {
                TarotCardFace(card: card, width: 84)
                VStack(alignment: .leading, spacing: 4) {
                    if let position {
                        Text(position.rawValue)
                            .font(.twinkoCaption)
                            .foregroundStyle(Color.inkNavy)
                            .padding(.horizontal, TwinkoSpacing.s)
                            .padding(.vertical, 3)
                            .background(Color.twinkoGold, in: Capsule())
                    }
                    Text(card.name)
                        .font(.twinkoTitle)
                        .foregroundStyle(.white)
                }
                Spacer()
            }

            TwinkoCard(tone: .dark) {
                VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                    Text(TarotInterpreter.interpretation(for: card, topic: draw.topic,
                                                         position: position))
                        .font(.twinkoBody)
                        .foregroundStyle(.white.opacity(0.92))
                        .lineSpacing(4)
                    Divider().overlay(Color.white.opacity(0.2))
                    Label(card.gentleAction, systemImage: "hand.point.right.fill")
                        .font(.twinkoCaption)
                        .foregroundStyle(Color.twinkoGold)
                }
            }
        }
        .padding(.horizontal, TwinkoSpacing.m)
    }
}
