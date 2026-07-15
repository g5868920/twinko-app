import SwiftUI

/// The complete Tarot flow as one contained stage machine:
/// setup (topic + optional question) → spread selection → shuffle
/// ritual → manual reveal → interpretation / result, with the optional
/// Guidance Card reveal woven into the result stage. Backgrounds
/// follow the approved usage spec per stage.
struct TarotFlowView: View {
    enum Stage {
        case setup, spread, shuffle, reveal, result, guidanceReveal
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var prefs: PrefsStore

    @State private var stage: Stage = .setup
    @State private var session = TarotReadingSession()
    private let provider: TarotInterpretationProviding = MockTarotInterpretationProvider()

    private var lang: AppLanguage { prefs.language }

    private var backgroundName: String {
        switch stage {
        case .setup, .spread:
            return "bg_tarot_celestial_altar_setup_v1"
        case .shuffle:
            return "bg_tarot_observatory_shuffle_v1"
        case .reveal, .result, .guidanceReveal:
            return "bg_tarot_moonlight_altar_result_v1"
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                stageContent
            }
        }
        .background {
            GeometryReader { geo in
                Image(backgroundName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .accessibilityHidden(true)
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: backgroundName)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private var stageContent: some View {
        Group {
            switch stage {
            case .setup:
                TarotSetupStage(session: $session) { advance(to: .spread) }
            case .spread:
                TarotSpreadStage { spread in
                    session.spread = spread
                    var engine = TarotDrawEngine()
                    session.cards = engine.draw(spread: spread)
                    session.guidanceCard = nil
                    session.createdAt = .now
                    advance(to: .shuffle)
                }
            case .shuffle:
                TarotShuffleStage { advance(to: .reveal) }
            case .reveal:
                TarotRevealStage(cards: session.cards,
                                 heading: session.spread == .single
                                     ? TarotStrings.revealSingle(lang)
                                     : TarotStrings.revealThree(lang)) {
                    advance(to: .result)
                }
            case .result:
                TarotResultStage(session: $session, provider: provider,
                                 onDrawGuidance: {
                    var engine = TarotDrawEngine()
                    session.guidanceCard = engine.drawGuidance(excluding: session.cards)
                    advance(to: .guidanceReveal)
                }, onRestart: {
                    session = TarotReadingSession(topic: session.topic)
                    advance(to: .setup)
                }, onHome: {
                    dismiss()
                })
            case .guidanceReveal:
                if let guidance = session.guidanceCard {
                    TarotRevealStage(cards: [guidance],
                                     heading: TarotStrings.revealGuidance(lang)) {
                        advance(to: .result)
                    }
                }
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity))
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            Text(TarotStrings.title(lang))
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.textInverseToken)
            HStack {
                Button {
                    goBack()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.accentGold)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(Text(lang == .english ? "Back" : "上一步"))
                .accessibilityIdentifier("tarotBackButton")
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 48)
    }

    private func advance(to next: Stage) {
        withAnimation(.easeInOut(duration: 0.3)) { stage = next }
    }

    private func goBack() {
        switch stage {
        case .setup:
            dismiss()
        case .spread:
            advance(to: .setup)
        case .shuffle, .reveal:
            advance(to: .spread)
        case .result, .guidanceReveal:
            advance(to: .setup)
        }
    }
}

// MARK: - Stage 1: topic + optional question

private struct TarotSetupStage: View {
    @Binding var session: TarotReadingSession
    let onContinue: () -> Void
    @EnvironmentObject private var prefs: PrefsStore

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        ScrollView {
            VStack(spacing: TwinkoSpacing.m) {
                Image("twinko_tarot_idle_v1_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .padding(.top, TwinkoSpacing.s)
                    .accessibilityHidden(true)

                Text(TarotStrings.setupTitle(lang))
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.textInverseToken)

                FlowHStack(spacing: TwinkoSpacing.s) {
                    ForEach(TarotTopicType.allCases) { option in
                        let selected = session.topic == option
                        Button {
                            session.topic = option
                        } label: {
                            Label(option.label(lang), systemImage: option.icon)
                                .font(.system(.body, design: .rounded))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .frame(minHeight: 40)
                                .background(
                                    selected ? AnyShapeStyle(
                                        LinearGradient(colors: [.twinkoGold, .warmOrange],
                                                       startPoint: .top, endPoint: .bottom))
                                             : AnyShapeStyle(Color.deepSpace.opacity(0.35)),
                                    in: Capsule()
                                )
                                .foregroundStyle(selected ? Color.inkNavy : Color.textInverseToken)
                        }
                        .accessibilityAddTraits(selected ? [.isSelected] : [])
                    }
                }
                .padding(.horizontal, TwinkoSpacing.m)

                VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                    Text(TarotStrings.questionLabel(lang))
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.textInverseToken)
                    TextField("", text: $session.question, axis: .vertical)
                        .font(.system(.body, design: .rounded))
                        .padding(10)
                        .background(Color.deepSpace.opacity(0.35),
                                    in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(Color.textInverseToken)
                        .tint(.accentGold)
                        .lineLimit(1...3)
                        .accessibilityLabel(Text(TarotStrings.questionLabel(lang)))
                        .accessibilityIdentifier("tarotQuestionField")
                    Text(TarotStrings.questionHint(lang))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.65))
                    ForEach(session.topic.suggestedQuestions(lang), id: \.self) { suggestion in
                        Button {
                            session.question = suggestion
                        } label: {
                            Text(suggestion)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(Color.twinkoGold)
                                .multilineTextAlignment(.leading)
                                .frame(minHeight: 28, alignment: .leading)
                        }
                    }
                }
                .padding(TwinkoSpacing.m)
                .background(Color.deepSpace.opacity(0.45),
                            in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
                .padding(.horizontal, TwinkoSpacing.m)

                Button {
                    onContinue()
                } label: {
                    Text(TarotStrings.next(lang))
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

// MARK: - Stage 2: spread selection (visual cards, spec §8)

private struct TarotSpreadStage: View {
    let onChoose: (TarotSpreadType) -> Void
    @EnvironmentObject private var prefs: PrefsStore
    @State private var pressed: TarotSpreadType?

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        VStack(spacing: TwinkoSpacing.l) {
            Spacer()
            Image("twinko_tarot_idle_v1_transparent")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .accessibilityHidden(true)
            Text(TarotStrings.spreadTitle(lang))
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.textInverseToken)

            HStack(spacing: TwinkoSpacing.m) {
                spreadCard(.single, preview: "tarot_spread_single_preview_v1_transparent")
                spreadCard(.three, preview: "tarot_spread_three_preview_v1_transparent")
            }
            .padding(.horizontal, TwinkoSpacing.l)
            Spacer()
            Spacer()
        }
    }

    private func spreadCard(_ spread: TarotSpreadType, preview: String) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) { pressed = spread }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                onChoose(spread)
            }
        } label: {
            VStack(spacing: 10) {
                Image(preview)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 110)
                Text(spread.title(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.textInverseToken)
                Text(spread.subtitle(lang))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TwinkoSpacing.m)
            .padding(.horizontal, TwinkoSpacing.s)
            .background(Color.deepSpace.opacity(0.45),
                        in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
            .overlay(
                RoundedRectangle(cornerRadius: TwinkoRadius.card)
                    .strokeBorder(Color.accentGold.opacity(pressed == spread ? 0.9 : 0.45),
                                  lineWidth: pressed == spread ? 2 : 1)
            )
            .scaleEffect(pressed == spread ? 1.03 : 1.0)
        }
        .accessibilityLabel(Text("\(spread.title(lang))，\(spread.subtitle(lang))"))
    }
}
