import SwiftUI

/// The complete Tarot flow (topic/question → spread → shuffle & reveal
/// → result) as one contained stage machine, so "回到首頁" is a single
/// dismiss and "再抽一次" is a clean reset.
struct TarotFlowView: View {
    enum Stage {
        case setup, spread, ritual, result
    }

    @Environment(\.dismiss) private var dismiss
    @State private var stage: Stage = .setup
    @State private var topic: TarotTopic = .general
    @State private var question: String = ""
    @State private var draw: TarotDraw?

    var body: some View {
        ZStack {
            TwinkoBackground.tarot.ignoresSafeArea()
            StarFieldView()

            Group {
                switch stage {
                case .setup:
                    TarotSetupStage(topic: $topic, question: $question) {
                        advance(to: .spread)
                    }
                case .spread:
                    TarotSpreadStage { spread in
                        draw = TarotDrawer.draw(topic: topic,
                                                question: effectiveQuestion,
                                                spread: spread)
                        advance(to: .ritual)
                    }
                case .ritual:
                    if let draw {
                        TarotRitualStage(draw: draw) {
                            advance(to: .result)
                        }
                    }
                case .result:
                    if let draw {
                        TarotResultStage(draw: draw) {
                            question = ""
                            self.draw = nil
                            advance(to: .setup)
                        } onHome: {
                            dismiss()
                        }
                    }
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .opacity))
        }
        .navigationTitle("塔羅")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.cosmicDeep.opacity(0.6), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    goBack()
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(Color.twinkoGold)
                }
                .accessibilityLabel(Text("上一步"))
            }
        }
    }

    private var effectiveQuestion: String {
        let trimmed = question.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "一個此刻的提醒" : trimmed
    }

    private func advance(to next: Stage) {
        withAnimation(.easeInOut(duration: TwinkoMotion.standard)) {
            stage = next
        }
    }

    private func goBack() {
        switch stage {
        case .setup:
            dismiss()
        case .spread:
            advance(to: .setup)
        case .ritual:
            advance(to: .spread)
        case .result:
            advance(to: .ritual)
        }
    }
}

// MARK: - Stage 1: topic + question

private struct TarotSetupStage: View {
    @Binding var topic: TarotTopic
    @Binding var question: String
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: TwinkoSpacing.m) {
                TwinkoCharacterView(mood: .tarot, size: 130)
                    .padding(.top, TwinkoSpacing.s)

                Text("今天想聊哪個方向？")
                    .font(.twinkoTitle)
                    .foregroundStyle(.white)

                FlowHStack(spacing: TwinkoSpacing.s) {
                    ForEach(TarotTopic.allCases) { option in
                        let selected = topic == option
                        Button {
                            topic = option
                        } label: {
                            Label(option.rawValue, systemImage: option.icon)
                                .font(.twinkoBody)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .frame(minHeight: 40)
                                .background(
                                    selected ? AnyShapeStyle(
                                        LinearGradient(colors: [.twinkoGold, .warmOrange],
                                                       startPoint: .top, endPoint: .bottom))
                                             : AnyShapeStyle(Color.white.opacity(0.12)),
                                    in: Capsule()
                                )
                                .foregroundStyle(selected ? Color.inkNavy : .white)
                        }
                        .accessibilityAddTraits(selected ? [.isSelected] : [])
                    }
                }
                .padding(.horizontal, TwinkoSpacing.m)

                TwinkoCard(tone: .dark) {
                    VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                        Text("想問的問題（可以不填）")
                            .font(.twinkoHeadline)
                            .foregroundStyle(.white)
                        TextField("", text: $question, axis: .vertical)
                            .font(.twinkoBody)
                            .padding(10)
                            .background(Color.white.opacity(0.10),
                                        in: RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(.white)
                            .tint(.twinkoGold)
                            .lineLimit(1...3)
                            .accessibilityLabel(Text("輸入你想問的問題"))
                        Text("或試試這樣問：")
                            .font(.twinkoCaption)
                            .foregroundStyle(.white.opacity(0.65))
                        ForEach(topic.suggestedQuestions, id: \.self) { suggestion in
                            Button {
                                question = suggestion
                            } label: {
                                Text(suggestion)
                                    .font(.twinkoCaption)
                                    .foregroundStyle(Color.twinkoGold)
                                    .multilineTextAlignment(.leading)
                                    .frame(minHeight: 28, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(.horizontal, TwinkoSpacing.m)

                Button {
                    onContinue()
                } label: {
                    Text("下一步")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.twinkoPrimary)
                .padding(.horizontal, TwinkoSpacing.m)
                .padding(.bottom, TwinkoSpacing.xl)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

// MARK: - Stage 2: spread choice

private struct TarotSpreadStage: View {
    let onChoose: (TarotSpread) -> Void

    var body: some View {
        VStack(spacing: TwinkoSpacing.l) {
            Spacer()
            TwinkoCharacterView(mood: .tarot, size: 130)
            Text("想用哪一種牌陣？")
                .font(.twinkoTitle)
                .foregroundStyle(.white)

            ForEach(TarotSpread.allCases) { spread in
                Button {
                    onChoose(spread)
                } label: {
                    VStack(spacing: 4) {
                        Text(spread.rawValue)
                            .font(.twinkoHeadline)
                        Text(spread.subtitle)
                            .font(.twinkoCaption)
                            .opacity(0.8)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TwinkoSpacing.m)
                    .background(Color.white.opacity(0.12),
                                in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
                    .overlay(
                        RoundedRectangle(cornerRadius: TwinkoRadius.card)
                            .strokeBorder(Color.twinkoGold.opacity(0.5), lineWidth: 1)
                    )
                }
                .padding(.horizontal, TwinkoSpacing.l)
            }
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        TarotFlowView()
    }
    .environment(\.locale, Locale(identifier: "zh-Hant"))
}
