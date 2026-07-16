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
    @EnvironmentObject private var chrome: ShellChrome

    @State private var stage: Stage = .setup
    @State private var session = TarotReadingSession()
    /// Whether this reading's cards were already revealed once, so
    /// Back from the result never re-hides them (§41).
    @State private var revealSeen = false
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
                ZStack {
                    Image(backgroundName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    // Restrained readability overlay (spec §8): the
                    // approved art stays visible but secondary behind
                    // text-heavy content.
                    // Deeper purple-black overlay (§24): backgrounds
                    // stay atmospheric while foreground text wins.
                    LinearGradient(
                        stops: [
                            .init(color: Color.deepSpace.opacity(0.30), location: 0),
                            .init(color: Color.deepSpace.opacity(0.22), location: 0.35),
                            .init(color: Color.deepSpace.opacity(0.38), location: 1),
                        ],
                        startPoint: .top, endPoint: .bottom)
                }
                .accessibilityHidden(true)
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: backgroundName)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        // Stage-wise edge-back: Tarot's pages are stages inside one
        // pushed view, so a narrow leading-edge drag mirrors the Back
        // button while the native pop stays gated off (§11). The strip
        // starts below the header so the Back button stays tappable.
        .overlay(alignment: .leading) {
            Color.clear
                .frame(width: 22)
                .contentShape(Rectangle())
                .padding(.top, 60)
                .gesture(
                    DragGesture(minimumDistance: 24)
                        .onEnded { value in
                            if value.translation.width > 60,
                               abs(value.translation.height) < 90 {
                                goBack()
                            }
                        }
                )
                .accessibilityHidden(true)
        }
        .onAppear {
            // Immersive Tarot: the shell tab bar stays hidden until
            // navigation returns to a root tab.
            chrome.tabBarHidden = true
            InteractivePopGate.isBlocked = true
        }
        .onDisappear {
            // Pushed children (Tarot-derived Meditation) get the native
            // pop back; the tab bar stays hidden until a root reappears.
            InteractivePopGate.isBlocked = false
        }
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
                    revealSeen = false
                    advance(to: .shuffle)
                }
            case .shuffle:
                TarotShuffleStage(cardCount: session.cards.count) { advance(to: .reveal) }
            case .reveal:
                TarotRevealStage(cards: session.cards,
                                 heading: session.spread == .single
                                     ? TarotStrings.revealSingle(lang)
                                     : TarotStrings.revealThree(lang),
                                 initiallyRevealed: revealSeen) {
                    revealSeen = true
                    advance(to: .result)
                }
            case .result:
                TarotResultStage(session: $session, provider: provider,
                                 onDrawGuidance: {
                    // One optional Guidance Card per reading (§33).
                    guard session.canDrawGuidance else { return }
                    var engine = TarotDrawEngine()
                    session.guidanceCard = engine.drawGuidance(excluding: session.cards)
                    advance(to: .guidanceReveal)
                }, onRestart: {
                    session = TarotReadingSession(topic: session.topic)
                    revealSeen = false
                    advance(to: .setup)
                }, onHome: {
                    goHome()
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

    // MARK: Header (Back only — no redundant page title, §9)

    private var header: some View {
        ZStack {
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

    /// Back (button and edge swipe) always returns to the previous
    /// page; the reading state is preserved and never silently redrawn
    /// (§11). Cards redraw only when the user explicitly re-chooses a
    /// spread or starts a new reading.
    private func goBack() {
        switch stage {
        case .setup:
            dismiss()
        case .spread:
            advance(to: .setup)
        case .shuffle, .reveal:
            advance(to: .spread)
        case .result:
            advance(to: .reveal)
        case .guidanceReveal:
            advance(to: .result)
        }
    }

    /// Result-page exits (§12–13): Back to Home always returns to the
    /// Home root and restores the bottom navigation; Start a New
    /// Reading stays immersive and returns to topic setup.
    fileprivate func goHome() {
        chrome.tabBarHidden = false
        chrome.selectedTab = .home
        dismiss()
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
                TarotTwinkoView(state: .idle, size: TarotTwinkoSize.supporting,
                                effect: .idleGlow)
                    .padding(.top, TwinkoSpacing.s)

                Text(TarotStrings.setupTitle(lang))
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.textInverseToken)

                // Six approved topics in a fixed equal 2×3 grid (§5):
                // width never depends on text length, and selection is
                // a filled surface + check, never border color alone.
                LazyVGrid(columns: [GridItem(.flexible(), spacing: TwinkoSpacing.s),
                                    GridItem(.flexible(), spacing: TwinkoSpacing.s)],
                          spacing: TwinkoSpacing.s) {
                    ForEach(TarotTopicType.allCases) { option in
                        let selected = session.topic == option
                        Button {
                            session.topic = option
                        } label: {
                            HStack(spacing: 7) {
                                Image(systemName: selected ? "checkmark.circle.fill"
                                                           : option.icon)
                                    .font(.system(size: 14))
                                Text(option.label(lang))
                                    .font(.system(.subheadline, design: .rounded)
                                        .weight(.medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(
                                selected ? AnyShapeStyle(
                                    LinearGradient(colors: [.twinkoGold, .warmOrange],
                                                   startPoint: .top, endPoint: .bottom))
                                         : AnyShapeStyle(Color.deepSpace.opacity(0.45)),
                                in: RoundedRectangle(cornerRadius: 14)
                            )
                            .foregroundStyle(selected ? Color.inkNavy : Color.textInverseToken)
                            .contentShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .accessibilityIdentifier("tarotTopic-\(option.rawValue)")
                        .accessibilityLabel(Text(selected
                            ? (lang == .english ? "\(option.label(lang)), selected"
                                                : "\(option.label(lang))，已選取")
                            : option.label(lang)))
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
                        .background(Color.deepSpace.opacity(0.55),
                                    in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.textInverseToken.opacity(0.18), lineWidth: 1))
                        .foregroundStyle(Color.textInverseToken)
                        .tint(.accentGold)
                        .lineLimit(1...3)
                        .accessibilityLabel(Text(TarotStrings.questionLabel(lang)))
                        .accessibilityIdentifier("tarotQuestionField")
                    Text(TarotStrings.questionHint(lang))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.65))
                    // Topic-specific suggestions as equal full-width
                    // rows — tapping fills the question input (§6–7).
                    ForEach(session.topic.suggestedQuestions(lang), id: \.self) { suggestion in
                        Button {
                            session.question = suggestion
                        } label: {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.twinkoGold.opacity(0.85))
                                    .padding(.top, 2)
                                Text(suggestion)
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundStyle(Color.twinkoGold)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .background(Color.twinkoGold.opacity(0.10),
                                        in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.twinkoGold.opacity(0.35), lineWidth: 1))
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(TarotSuggestionPressStyle())
                        .accessibilityHint(Text(lang == .english
                            ? "Fills the question field" : "會填入問題欄位"))
                    }
                }
                .padding(TwinkoSpacing.m)
                .background(Color.deepSpace.opacity(0.5),
                            in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
                .padding(.horizontal, TwinkoSpacing.m)

                Button {
                    onContinue()
                } label: {
                    Text(TarotStrings.next(lang))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.tarotMagicPrimary)
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
            TarotTwinkoView(state: .idle, size: TarotTwinkoSize.supporting,
                            effect: .idleGlow)
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

    /// Both options share one fixed illustration container, title
    /// baseline, and subtitle region, so Single Card and Three Cards
    /// carry identical visual weight (§15).
    private func spreadCard(_ spread: TarotSpreadType, preview: String) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) { pressed = spread }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onChoose(spread)
            }
        } label: {
            VStack(spacing: 10) {
                Image(preview)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: spread == .single ? 92 : 100)
                    .frame(height: 104)
                Text(spread.title(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.textInverseToken)
                Text(spread.subtitle(lang))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .frame(height: 32, alignment: .top)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TwinkoSpacing.m)
            .padding(.horizontal, TwinkoSpacing.s)
            .background(Color.deepSpace.opacity(0.5),
                        in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
            .overlay(
                RoundedRectangle(cornerRadius: TwinkoRadius.card)
                    .strokeBorder(Color.accentGold.opacity(pressed == spread ? 0.9 : 0.45),
                                  lineWidth: pressed == spread ? 2 : 1)
            )
        }
        .buttonStyle(TarotMagicPressStyle())
        .accessibilityIdentifier("tarotSpread-\(spread.rawValue)")
        .accessibilityLabel(Text("\(spread.title(lang))，\(spread.subtitle(lang))"))
    }
}

/// Quiet pressed feedback for suggestion rows (not a full magic CTA).
struct TarotSuggestionPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
