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
    /// Owns the whole reading, including `revealSeen` — reveal state
    /// lives on the session, never in stage-local view `@State` (§41).
    @State private var session = TarotReadingSession()
    @State private var showingExitConfirm = false
    @State private var immersiveToken = UUID()
    private let provider: TarotInterpretationProviding = MockTarotInterpretationProvider()

    private var lang: AppLanguage { prefs.language }

    private var backgroundName: String {
        switch stage {
        case .setup, .spread:
            return "bg_tarot_celestial_altar_setup_v3"
        case .shuffle:
            return "bg_tarot_observatory_shuffle_v3"
        case .reveal, .result, .guidanceReveal:
            return "bg_tarot_moonlight_altar_result_v3"
        }
    }

    var body: some View {
        // Phase 1 (2026-07-19): the intent-first pre-reading flow is
        // development-gated (`-tarotPreReadingV2`) because the live
        // engine cannot yet safely draw 4/5-card spreads; the public
        // entry keeps this proven flow untouched until Task 2.
        if TarotPreReadingFlowView.isDevEntryEnabled {
            TarotPreReadingFlowView()
        } else {
            legacyFlow
        }
    }

    private var legacyFlow: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                stageContent
            }

            if showingExitConfirm {
                BrandedModal(
                    icon: "sparkles",
                    iconColor: .brandPurpleDeep,
                    title: TarotStrings.exitConfirmTitle(lang),
                    content: {
                        Text(TarotStrings.exitConfirmBody(lang))
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color.textSecondaryToken)
                            .multilineTextAlignment(.center)
                    },
                    cancelTitle: TarotStrings.exitConfirmStay(lang),
                    confirmTitle: TarotStrings.exitConfirmLeave(lang),
                    isDestructive: true,
                    onCancel: { showingExitConfirm = false },
                    onConfirm: {
                        showingExitConfirm = false
                        exitFlow()
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: showingExitConfirm)
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
            // Immersive Tarot: registers its token so the tab bar
            // stays hidden while any Tarot stage is on screen.
            chrome.setImmersive(immersiveToken, active: true)
            InteractivePopGate.isBlocked = true
        }
        .onDisappear {
            // Pushed children (Tarot-derived Meditation) hold their own
            // token, so the handover keeps the bar hidden seamlessly.
            chrome.setImmersive(immersiveToken, active: false)
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
                    session.revealSeen = false
                    advance(to: .shuffle)
                }
            case .shuffle:
                TarotShuffleStage(cardCount: session.cards.count) { advance(to: .reveal) }
            case .reveal:
                TarotRevealStage(cards: session.cards,
                                 heading: session.spread == .single
                                     ? TarotStrings.revealSingle(lang)
                                     : TarotStrings.revealThree(lang),
                                 initiallyRevealed: session.revealSeen) {
                    session.revealSeen = true
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

    // MARK: Header (Back + flow exit — no redundant page title, §9)

    /// Top-left Back = previous Tarot step. Top-right X = leave the
    /// whole flow back to its original source (Explore, Home, …) —
    /// with a branded confirmation once meaningful reading state
    /// exists (2026-07-17).
    /// One coherent floating control system (§ unified Back/X): both
    /// icons share the restrained warm-gold treatment, size, weight,
    /// 44×44 target, press feedback, and light haptic — no local bar,
    /// background, or safe-area fill behind them.
    private var header: some View {
        HStack {
            Button {
                goBack()
            } label: {
                Image(systemName: "chevron.backward")
                    .tarotHeaderControlIcon()
            }
            .buttonStyle(TarotHeaderControlStyle())
            .accessibilityLabel(Text(lang == .english ? "Back" : "上一步"))
            .accessibilityIdentifier("tarotBackButton")
            Spacer()
            Button {
                if Self.requiresExitConfirmation(stage: stage) {
                    showingExitConfirm = true
                } else {
                    exitFlow()
                }
            } label: {
                Image(systemName: "xmark")
                    .tarotHeaderControlIcon()
            }
            .buttonStyle(TarotHeaderControlStyle())
            .accessibilityLabel(Text(lang == .english ? "Leave Tarot" : "離開塔羅"))
            .accessibilityIdentifier("tarotExitButton")
        }
        .padding(.horizontal, 8)
        .frame(height: 48)
    }

    /// Meaningful reading state begins with the shuffle: from then on
    /// (shuffle / reveal / result / guidance) leaving is destructive
    /// and requires confirmation. Setup and spread exit directly.
    static func requiresExitConfirmation(stage: Stage) -> Bool {
        switch stage {
        case .setup, .spread: return false
        case .shuffle, .reveal, .result, .guidanceReveal: return true
        }
    }

    /// Leaves the entire Tarot flow to its original source: the flow is
    /// one pushed view, so dismiss pops back to wherever it was entered
    /// from (Explore, Home, …) — never forced to Home. The revealed
    /// root restores its own bottom-navigation visibility.
    private func exitFlow() {
        dismiss()
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

    /// Guided stages read as scenes, not documents (§ no-scroll rule):
    /// at standard Dynamic Type on a modern iPhone the setup fits
    /// without scrolling; `ViewThatFits` falls back to a scroll only
    /// for small devices, Accessibility Dynamic Type, or the keyboard.
    var body: some View {
        ViewThatFits(in: .vertical) {
            content
            ScrollView {
                content
            }
            .scrollDismissesKeyboard(.interactively)
        }
        // Greedy outer frame: the stage keeps filling the screen (the
        // flow background sizes to it) while ViewThatFits still
        // measures the fixed-height content for the scroll decision.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var content: some View {
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
                                    .foregroundStyle(selected
                                        ? TarotCTAPalette.antiqueGold
                                        : TarotCTAPalette.warmLightText.opacity(0.85))
                                Text(option.label(lang))
                                    .font(.system(.subheadline, design: .rounded)
                                        .weight(.medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            // Shared illuminated night-glass selection
                            // language (same recipe as Meditation setup).
                            .twinkoNightChoice(cornerRadius: 14, selected: selected)
                            .foregroundStyle(TarotCTAPalette.warmLightText)
                            .contentShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(TwinkoHapticPressStyle())
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
                        // Night glass instead of a dead dark slab — the
                        // rim light and inner highlight keep the field
                        // clearly alive/enabled.
                        .twinkoGlass(cornerRadius: 12, tint: 0.46, night: true)
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
                                // Warm-white copy with gold reserved for
                                // the icon + thin border accents — all-gold
                                // rows were too loud side by side.
                                Text(suggestion)
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundStyle(TarotCTAPalette.warmLightText)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .background(
                                LinearGradient(colors: [Color(hex: 0x9C8CD8).opacity(0.28),
                                                        Color(hex: 0x6E5FB0).opacity(0.22)],
                                               startPoint: .top, endPoint: .bottom),
                                in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.twinkoGold.opacity(0.30), lineWidth: 1))
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(TarotSuggestionPressStyle())
                        .accessibilityHint(Text(lang == .english
                            ? "Fills the question field" : "會填入問題欄位"))
                    }
                }
                .padding(TwinkoSpacing.m)
                .twinkoGlass(cornerRadius: TwinkoRadius.card, tint: 0.32, night: true)
                .padding(.horizontal, TwinkoSpacing.m)

                Button {
                    onContinue()
                } label: {
                    Text(TarotStrings.next(lang))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.tarotMagicPrimary)
                .padding(.horizontal, TwinkoSpacing.m)
                .padding(.bottom, TwinkoSpacing.m)
            }
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
                spreadCard(.single)
                spreadCard(.three)
            }
            .padding(.horizontal, TwinkoSpacing.l)
            Spacer()
            Spacer()
        }
    }

    /// Both options share one fixed illustration container, title
    /// baseline, and subtitle region, so Single Card and Three Cards
    /// carry identical visual weight (§15). The previews are composed
    /// from the canonical card back: both center cards are the same
    /// size, with the three-card sides at ~84% tucked behind.
    private func spreadPreview(_ spread: TarotSpreadType) -> some View {
        ZStack {
            if spread == .three {
                TarotCardBack(width: 52)
                    .rotationEffect(.degrees(-9))
                    .offset(x: -30, y: 5)
                TarotCardBack(width: 52)
                    .rotationEffect(.degrees(9))
                    .offset(x: 30, y: 5)
            }
            TarotCardBack(width: 62)
        }
        .frame(height: 104)
        .accessibilityHidden(true)
    }

    private func spreadCard(_ spread: TarotSpreadType) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) { pressed = spread }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onChoose(spread)
            }
        } label: {
            VStack(spacing: 10) {
                spreadPreview(spread)
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
            // Night glass at rest; the chosen card briefly "lights up"
            // (illuminated fill + gold rim) before the stage advances —
            // the same selection moment as every other night chip.
            .twinkoNightChoice(cornerRadius: TwinkoRadius.card,
                               selected: pressed == spread)
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
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }
}
