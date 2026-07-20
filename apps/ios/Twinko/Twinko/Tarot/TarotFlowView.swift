import SwiftUI

/// The complete Tarot flow (Task 2, 2026-07-19): the intent-first
/// pre-reading (Task 1) is now the live public entry, and its
/// validated launch request feeds one canonical reading engine that
/// supports every MVP spread (1/3/4/5 cards) through the same shuffle
/// ritual → manual reveal → generalized result stages. One
/// `TarotReadingSession` owns the active reading; the pre-reading view
/// stays mounted underneath so its draft survives the New Reading /
/// discard boundary. Backgrounds follow the approved per-phase
/// mapping.
struct TarotFlowView: View {
    enum Stage {
        case shuffle, reveal, result, guidanceReveal
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var prefs: PrefsStore
    @EnvironmentObject private var chrome: ShellChrome
    @EnvironmentObject private var dailyTarot: DailyTarotStore

    /// Task 3: optional contextual entry (Chat / Home / Daily) —
    /// seeds the pre-reading at Recommended Spread Setup.
    var entryContext: TarotEntryContext?

    /// The one active reading source of truth. `nil` = pre-reading.
    @State private var session: TarotReadingSession?
    @State private var stage: Stage

    /// `restoredSession` reopens a completed reading (View Today's
    /// Guidance) directly at the result — no setup, no shuffle, no
    /// redraw; New Reading from there flows into the normal standard
    /// pre-reading.
    init(entryContext: TarotEntryContext? = nil,
         restoredSession: TarotReadingSession? = nil) {
        self.entryContext = entryContext
        self.isRestored = restoredSession != nil
        _session = State(initialValue: restoredSession)
        _stage = State(initialValue: restoredSession != nil ? .result : .shuffle)
    }
    @State private var showingExitConfirm = false
    /// Back before the result = leaving the committed draw: the
    /// explicit New Reading boundary (§16) — confirm, then return to
    /// the preserved Task 1 draft.
    @State private var showingDiscardConfirm = false
    private let provider: TarotInterpretationProviding = MockTarotInterpretationProvider()
    /// Phase A step 10 (provisional, founder review pending): one
    /// live-generation lifecycle per reading (consent → fetch →
    /// validate → enforce incl. reframe), mock fallback always.
    @StateObject private var liveModel = TarotLiveReadingModel.makeDefault()
    private let isRestored: Bool

    /// Pre-reading safety gate state (correction 2): consent and the
    /// deterministic safety preflight both resolve BEFORE any base
    /// card is drawn.
    @State private var pendingConsentRequest: TarotReadingLaunchRequest?
    @State private var preflightReframe: PreflightReframe?
    @State private var preflightSupport: TarotLLMSafetyCategory?

    struct PreflightReframe {
        let request: TarotReadingLaunchRequest
        var category: TarotLLMSafetyCategory
    }

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        ZStack {
            // The pre-reading flow owns the immersive token and pop
            // gate for the whole Tarot visit; it stays mounted (hidden)
            // during the reading so the draft survives New Reading.
            TarotPreReadingFlowView(onLaunch: handleLaunch, entryContext: entryContext)
                .opacity(session == nil ? 1 : 0)
                .allowsHitTesting(session == nil)
                .accessibilityHidden(session != nil)

            if session != nil {
                readingFlow
                    .transition(.opacity)
            }

            preflightOverlays
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: session != nil)
    }

    // MARK: Pre-reading safety gate (correction 2, 2026-07-21)
    //
    // Order: Setup Review → consent (when required) → deterministic
    // safety preflight → allow / user-approved reframe / replace →
    // only then Begin Reading commits the draw. Committed cards are
    // never reinterpreted under a changed question.

    private func handleLaunch(_ request: TarotReadingLaunchRequest) {
        if liveModel.isLiveCapable && !liveModel.hasConsent {
            pendingConsentRequest = request
            return
        }
        runPreflight(request)
    }

    private func runPreflight(_ request: TarotReadingLaunchRequest) {
        // The gate protects live generation; mock-only readings (no
        // key, or consent declined for this reading) keep the existing
        // local behavior unchanged.
        guard liveModel.isLiveCapable && liveModel.hasConsent else {
            commitReading(request)
            return
        }
        let draft = request.draft
        let category = TarotSafetyMatrix.preflightCategory(
            question: draft.trimmedQuestion,
            decisionContext: draft.trimmedDecisionContext,
            optionA: draft.trimmedOptionA,
            optionB: draft.trimmedOptionB,
            personLabel: draft.trimmedPersonLabel)
        switch TarotSafetyMatrix.action(for: category).policy {
        case .allowReflectiveReading, .allowWithConstraints:
            commitReading(request)
        case .requireUserApprovedReframe:
            preflightReframe = PreflightReframe(request: request, category: category)
        case .replaceWithSupport, .refuseRequest:
            // Category-only logging — never the question itself.
            LLMEngine.log.info("tarot preflight category=\(category.rawValue, privacy: .public)")
            preflightSupport = category
        }
    }

    /// User approved (or edited) the preflight reframe: the DRAFT
    /// question is updated before any card exists — nothing committed
    /// is ever rewritten. The approved text is re-screened; a still-
    /// restricted edit keeps the gate open.
    private func approvePreflightReframe(_ text: String) {
        guard let gate = preflightReframe else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let policy = TarotSafetyMatrix.action(
            for: TarotSafetyMatrix.preflightCategory(question: trimmed)).policy
        guard policy == .allowReflectiveReading || policy == .allowWithConstraints else {
            preflightReframe?.category = TarotSafetyMatrix.preflightCategory(question: trimmed)
            return
        }
        var draft = gate.request.draft
        draft.question = trimmed
        preflightReframe = nil
        commitReading(TarotReadingLaunchRequest(draft: draft))
    }

    @ViewBuilder
    private var preflightOverlays: some View {
        if let request = pendingConsentRequest {
            BrandedModal(
                icon: "sparkles",
                iconColor: .brandPurpleDeep,
                title: TarotLiveStrings.consentTitle(lang),
                content: {
                    Text(LLMPrivacyDisclosure.body(lang))
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.textSecondaryToken)
                        .multilineTextAlignment(.leading)
                },
                cancelTitle: TarotLiveStrings.consentNotNow(lang),
                confirmTitle: TarotLiveStrings.consentContinue(lang),
                isDestructive: false,
                onCancel: {
                    pendingConsentRequest = nil
                    liveModel.declineConsentOnce()
                    commitReading(request)
                },
                onConfirm: {
                    pendingConsentRequest = nil
                    liveModel.acceptConsent()
                    runPreflight(request)
                }
            )
            .transition(.opacity)
        }

        if let gate = preflightReframe {
            ScrollView {
                TarotReframeCard(category: gate.category, lang: lang,
                                 onContinue: { approvePreflightReframe($0) },
                                 onCancel: { preflightReframe = nil })
                    .padding(TwinkoSpacing.m)
                    .padding(.top, 70)
            }
            .background(Color.deepSpace.opacity(0.55).ignoresSafeArea())
            .transition(.opacity)
        }

        if let category = preflightSupport {
            ScrollView {
                VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                    HStack(spacing: 7) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(Color.accentGold)
                        Text(TarotLiveStrings.reframeTitle(lang))
                            .foregroundStyle(Color.deepPlum)
                    }
                    .font(.system(.headline, design: .rounded))
                    Text(TarotSafetyMatrix.supportiveResponse(for: category, lang: lang)
                         ?? TarotLiveStrings.strongerDisclaimer(lang))
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.textPrimaryToken)
                        .lineSpacing(6)
                    Button {
                        preflightSupport = nil
                    } label: {
                        Text(lang == .english ? "Back" : "回到設定")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.tarotMagicSecondary)
                    .accessibilityIdentifier("tarotPreflightSupportBack")
                }
                .tarotReadingCard()
                .padding(TwinkoSpacing.m)
                .padding(.top, 70)
                .accessibilityIdentifier("tarotPreflightSupport")
            }
            .background(Color.deepSpace.opacity(0.55).ignoresSafeArea())
            .transition(.opacity)
        }
    }

    // MARK: Launch boundary (Task 1 → Task 2)

    /// Consumes the validated launch request: integrity-guards the
    /// canonical definition, creates exactly one session, and draws
    /// one unique card per canonical position (the existing ritual
    /// pattern draws at commit time — identity never comes from the
    /// animation). Inputs are copied verbatim; the manually selected
    /// spread wins.
    private func commitReading(_ request: TarotReadingLaunchRequest) {
        let definition = TarotSpreadLibrary.definition(for: request.draft.selectedSpreadID)
        guard definition.cardCount > 0,
              definition.positionIDs.count == definition.cardCount else {
            assertionFailure("Invalid spread definition: \(definition.id)")
            return
        }
        var newSession = TarotReadingSession(request: request)
        var engine = TarotDrawEngine()
        newSession.cards = engine.draw(spreadID: newSession.spreadID)
        guard newSession.cards.count == definition.cardCount else {
            assertionFailure("Draw mismatch for \(definition.id)")
            return
        }
        stage = .shuffle
        session = newSession
    }

    // MARK: Reading flow

    private var backgroundName: String {
        switch stage {
        case .shuffle:
            return "bg_tarot_observatory_shuffle_v3"
        case .reveal, .result, .guidanceReveal:
            return "bg_tarot_moonlight_altar_result_v3"
        }
    }

    private var readingFlow: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                stageContent
            }

            if showingExitConfirm || showingDiscardConfirm {
                BrandedModal(
                    icon: "sparkles",
                    iconColor: .brandPurpleDeep,
                    title: showingDiscardConfirm
                        ? TarotStrings.discardConfirmTitle(lang)
                        : TarotStrings.exitConfirmTitle(lang),
                    content: {
                        Text(showingDiscardConfirm
                             ? TarotStrings.discardConfirmBody(lang)
                             : TarotStrings.exitConfirmBody(lang))
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color.textSecondaryToken)
                            .multilineTextAlignment(.center)
                    },
                    cancelTitle: TarotStrings.exitConfirmStay(lang),
                    confirmTitle: showingDiscardConfirm
                        ? TarotStrings.discardConfirmLeave(lang)
                        : TarotStrings.exitConfirmLeave(lang),
                    isDestructive: true,
                    onCancel: {
                        showingExitConfirm = false
                        showingDiscardConfirm = false
                    },
                    onConfirm: {
                        if showingDiscardConfirm {
                            showingDiscardConfirm = false
                            discardReading()
                        } else {
                            showingExitConfirm = false
                            dismiss()
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2),
                   value: showingExitConfirm || showingDiscardConfirm)
        .background {
            GeometryReader { geo in
                ZStack {
                    Image(backgroundName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    // Restrained readability overlay: the approved art
                    // stays visible but secondary behind text-heavy
                    // content.
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
        // Stage-wise edge-back mirrors the Back button; native pop
        // stays gated off by the pre-reading owner.
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
    }

    @ViewBuilder
    private var stageContent: some View {
        Group {
            if let current = session {
                switch stage {
                case .shuffle:
                    TarotShuffleStage(cardCount: current.cards.count) {
                        advance(to: .reveal)
                    }
                case .reveal:
                    TarotRevealStage(cards: current.cards,
                                     heading: current.cards.count == 1
                                         ? TarotStrings.revealSingle(lang)
                                         : TarotStrings.revealGeneric(lang),
                                     initiallyRevealed: current.revealSeen,
                                     onReveal: { drawn in
                                         session?.markRevealed(drawn.positionID)
                                     }) {
                        session?.revealSeen = true
                        // Daily completion happens exactly here: the
                        // base reading is fully drawn and revealed and
                        // the result becomes available (§16). Setup,
                        // partial draws, and abandonment never record.
                        if let completed = session,
                           completed.contextKind == .dailyCheckIn {
                            dailyTarot.recordCompletion(of: completed)
                        }
                        advance(to: .result)
                    }
                case .result:
                    TarotResultStage(session: bindingToSession, provider: provider,
                                     liveModel: liveModel,
                                     onResultAppear: { prepareLiveReading(for: current) },
                                     onConsentContinue: { startLiveReading(for: current) },
                                     onReframeContinue: { approved in
                                         startReframedNewReading(text: approved,
                                                                 from: current)
                                     },
                                     onDrawGuidance: {
                        // One optional Guidance Card per reading — from
                        // the remaining deck, never a duplicate, never
                        // a numbered position.
                        guard session?.canDrawGuidance == true else { return }
                        var engine = TarotDrawEngine()
                        session?.guidanceCard = engine.drawGuidance(excluding: current.cards)
                        // A later Guidance Card updates the same
                        // current-day Daily record — never a second
                        // completion (§22).
                        if let updated = session,
                           updated.contextKind == .dailyCheckIn {
                            dailyTarot.attachGuidance(from: updated)
                        }
                        advance(to: .guidanceReveal)
                    }, onRestart: {
                        // New Reading = the explicit reset boundary:
                        // back to the preserved Task 1 draft; the next
                        // launch creates a fresh session and deck.
                        discardReading()
                    }, onHome: {
                        goHome()
                    })
                case .guidanceReveal:
                    if let guidance = current.guidanceCard {
                        TarotRevealStage(cards: [guidance],
                                         heading: TarotStrings.revealGuidance(lang)) {
                            advance(to: .result)
                        }
                    }
                }
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity))
    }

    private var bindingToSession: Binding<TarotReadingSession> {
        Binding(
            get: { session ?? TarotReadingSession() },
            set: { session = $0 })
    }

    // MARK: Live reading lifecycle (Phase A step 10)

    /// A restored Daily reading reuses today's stored validated
    /// response (same session only) — no new call, no drift.
    private func restoredLiveResponse(for current: TarotReadingSession) -> TarotLLMResponse? {
        guard isRestored,
              let today = dailyTarot.todayRecord,
              today.readingSnapshot.sessionID == current.id else { return nil }
        return today.liveReading
    }

    private func prepareLiveReading(for current: TarotReadingSession) {
        liveModel.prepare(session: current, lang: lang,
                          isRestored: isRestored,
                          restoredResponse: restoredLiveResponse(for: current),
                          onLiveResponse: { response in
                              dailyTarot.attachLiveReading(response, for: current)
                          })
    }

    private func startLiveReading(for current: TarotReadingSession) {
        liveModel.consentGranted(session: current, lang: lang,
                                 onLiveResponse: { response in
                                     dailyTarot.attachLiveReading(response, for: current)
                                 })
    }

    /// Post-draw discovery (second safety layer): the user accepted
    /// the offer of a NEW safely reframed reading. The committed
    /// session is never mutated and its cards are never reinterpreted
    /// — a fresh session with a fresh draw starts through the normal
    /// shuffle → reveal ritual. A still-restricted edit resolves to
    /// the labeled mock instead.
    private func startReframedNewReading(text: String, from base: TarotReadingSession) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let policy = TarotSafetyMatrix.action(
            for: TarotSafetyMatrix.preflightCategory(question: trimmed)).policy
        guard policy == .allowReflectiveReading || policy == .allowWithConstraints else {
            liveModel.declineReframe()
            return
        }
        var fresh = TarotReadingSession(spreadID: base.spreadID,
                                        topic: base.topic,
                                        intent: base.intent,
                                        question: trimmed,
                                        decisionContext: base.decisionContext,
                                        optionA: base.optionA,
                                        optionB: base.optionB,
                                        relationshipPersonLabel: base.relationshipPersonLabel)
        fresh.source = base.source
        fresh.contextKind = base.contextKind
        var engine = TarotDrawEngine()
        fresh.cards = engine.draw(spreadID: fresh.spreadID)
        stage = .shuffle
        session = fresh
    }

    // MARK: Header (Back + flow exit)

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
                showingExitConfirm = true
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

    private func advance(to next: Stage) {
        withAnimation(.easeInOut(duration: 0.3)) { stage = next }
    }

    /// Back always returns to the previous step without mutating the
    /// reading. Before the result exists, leaving the committed draw
    /// is the New Reading boundary (confirmed, draft preserved) —
    /// cards are never silently reinterpreted or reassigned.
    private func goBack() {
        switch stage {
        case .shuffle, .reveal:
            showingDiscardConfirm = true
        case .result:
            advance(to: .reveal)
        case .guidanceReveal:
            advance(to: .result)
        }
    }

    /// Clears the active reading and returns to the still-mounted
    /// Task 1 pre-reading (draft intact). The next Begin Reading
    /// creates a new session ID and a new deck.
    private func discardReading() {
        withAnimation(.easeInOut(duration: 0.3)) { session = nil }
        stage = .shuffle
    }

    /// Source-aware result exit (§33): Chat-origin readings return to
    /// the originating conversation (pop only — the Chat stack is
    /// preserved underneath); Home/Daily/direct return to the Home
    /// root and restore the bottom navigation.
    private func goHome() {
        if session?.source != .chat {
            chrome.selectedTab = .home
        }
        dismiss()
    }
}
