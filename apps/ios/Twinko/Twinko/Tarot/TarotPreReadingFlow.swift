import SwiftUI

// MARK: - Phase 1 pre-reading flow (2026-07-19)
//
// Intent-first pre-reading per the Phase 1 implementation instruction
// and `docs/features/tarot/TWINKOTALK_TAROT_USAGE_SPEC.md`:
//
//   Intent Selection → (optional inline Refinement) → Recommended
//   Spread Setup → Setup Review → validated launch boundary.
//
// Activation boundary: the live reading engine only accepts
// `TarotSpreadType` (1/3 cards, past/present/future semantics), so
// there is no safe seam that can launch the new spread IDs without
// changing draw/reveal/result logic. The public Tarot entry therefore
// keeps the existing live flow; this flow is reachable only through
// the existing launch-argument development mechanism
// (`-tarotPreReadingV2`, same pattern as the `-uiTest…` hooks). The
// Begin Reading CTA validates the draft and produces one canonical
// `TarotReadingLaunchRequest`; Task 2 connects it to a generalized
// draw engine. No cards, orientations, reveal, or result state are
// created here.

// MARK: Draft state (one canonical pre-reading source of truth)

enum TarotPreReadingPhase: String, Codable {
    case intentSelection, spreadSetup, setupReview, readyToLaunch
}

/// The complete pre-reading draft. Owned by `TarotPreReadingFlowView`
/// (one owner); every screen reads and mutates this same value, so
/// question and structured inputs survive Back navigation and Change
/// Spread. Nothing here is persisted, and no translated string is
/// stored as data.
struct TarotReadingDraft: Identifiable, Equatable {
    let id: UUID

    var recommendedSpreadID: TarotSpreadID
    var selectedSpreadID: TarotSpreadID

    var intent: TarotIntent
    var refinement: TarotIntentRefinement?

    var question = ""

    var decisionContext = ""
    var optionA = ""
    var optionB = ""

    var relationshipPersonLabel = ""

    var phase: TarotPreReadingPhase = .spreadSetup

    /// Task 3 routing context: entry source and context kind travel on
    /// the draft into the launch request and session. Defaults model
    /// the direct intent-first entry.
    var source: TarotEntrySource = .direct
    var contextKind: TarotEntryContextKind = .standard
    /// Optional one-line contextual explanation (Chat/Home/Daily) —
    /// display-only.
    var contextSummary: String?

    init(id: UUID = UUID(), intent: TarotIntent,
         refinement: TarotIntentRefinement?, spreadID: TarotSpreadID) {
        self.id = id
        self.intent = intent
        self.refinement = refinement
        self.recommendedSpreadID = spreadID
        self.selectedSpreadID = spreadID
    }

    var selectedDefinition: TarotSpreadDefinition {
        TarotSpreadLibrary.definition(for: selectedSpreadID)
    }

    /// The user changed away from the recommendation; the setup must
    /// not keep presenting recommendation copy for the manual choice.
    var isManualSelection: Bool { selectedSpreadID != recommendedSpreadID }

    var trimmedQuestion: String { question.trimmingCharacters(in: .whitespacesAndNewlines) }
    var trimmedDecisionContext: String { decisionContext.trimmingCharacters(in: .whitespacesAndNewlines) }
    var trimmedOptionA: String { optionA.trimmingCharacters(in: .whitespacesAndNewlines) }
    var trimmedOptionB: String { optionB.trimmingCharacters(in: .whitespacesAndNewlines) }
    var trimmedPersonLabel: String {
        relationshipPersonLabel.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Required fields that are still empty (after trimming) for the
    /// currently selected spread. The general question follows the
    /// existing product behavior and stays optional; Two-Choice and
    /// Relationship fields follow the canonical usage spec (§22).
    var missingRequiredFields: Set<TarotDraftField> {
        var missing: Set<TarotDraftField> = []
        switch selectedDefinition.inputKind {
        case .generalQuestion:
            break
        case .twoChoice:
            if trimmedDecisionContext.isEmpty { missing.insert(.decisionContext) }
            if trimmedOptionA.isEmpty { missing.insert(.optionA) }
            if trimmedOptionB.isEmpty { missing.insert(.optionB) }
        case .relationship:
            if trimmedQuestion.isEmpty { missing.insert(.question) }
        }
        return missing
    }

    var isLaunchable: Bool { missingRequiredFields.isEmpty }
}

enum TarotDraftField: Hashable {
    case question, decisionContext, optionA, optionB
}

/// The canonical pre-reading handoff boundary: one validated draft,
/// ready for the Task 2 reading engine.
struct TarotReadingLaunchRequest: Equatable {
    let draft: TarotReadingDraft
}

// MARK: - Flow view

struct TarotPreReadingFlowView: View {
    /// Task 2 launch boundary: receives the one validated canonical
    /// launch request when the user taps Begin Reading. (The Task 1
    /// `-tarotPreReadingV2` development gate is retired — this flow is
    /// now the live public pre-reading entry.)
    var onLaunch: (TarotReadingLaunchRequest) -> Void = { _ in }
    /// Task 3: contextual entry (Chat / Home / Daily). When present,
    /// the flow seeds one draft through the shared context→draft
    /// boundary and opens directly at Recommended Spread Setup —
    /// everything stays editable and Change Spread remains available.
    var entryContext: TarotEntryContext?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var prefs: PrefsStore
    @EnvironmentObject private var chrome: ShellChrome

    /// One canonical draft owner. `nil` only before the first intent
    /// selection; re-picking an intent updates the same draft (text
    /// input is preserved), starting the flow again creates a new one.
    @State private var draft: TarotReadingDraft?
    @State private var expandedIntent: TarotIntent?
    @State private var showingChangeSpread = false
    /// Where the Change Spread sheet was opened from — a change made
    /// on the review returns to setup so newly required fields can be
    /// completed.
    @State private var changeSpreadFromReview = false
    @State private var validationAttempted = false
    @State private var immersiveToken = UUID()

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .background {
            GeometryReader { geo in
                ZStack {
                    Image("bg_tarot_celestial_altar_setup_v3")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
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
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        // Same stage-wise edge-back convention as the live Tarot flow.
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
        .sheet(isPresented: $showingChangeSpread) { changeSpreadSheet }
        .onAppear {
            chrome.setImmersive(immersiveToken, active: true)
            InteractivePopGate.isBlocked = true
            // Contextual entries (Chat/Home/Daily) seed one draft via
            // the shared boundary and open at Recommended Spread Setup.
            if draft == nil, let context = entryContext {
                draft = TarotReadingDraft(context: context)
            }
        }
        .onDisappear {
            chrome.setImmersive(immersiveToken, active: false)
            InteractivePopGate.isBlocked = false
        }
    }

    private var phase: TarotPreReadingPhase { draft?.phase ?? .intentSelection }

    @ViewBuilder
    private var content: some View {
        Group {
            switch phase {
            case .intentSelection:
                landing
            case .spreadSetup:
                if draft != nil { setup }
            case .setupReview, .readyToLaunch:
                if draft != nil { review }
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity))
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: phase)
    }

    // MARK: Header (Back + exit, same control family as the live flow)

    private var header: some View {
        HStack {
            Button { goBack() } label: {
                Image(systemName: "chevron.backward")
                    .tarotHeaderControlIcon()
            }
            .buttonStyle(TarotHeaderControlStyle())
            .accessibilityLabel(Text(lang == .english ? "Back" : "上一步"))
            .accessibilityIdentifier("tarotPreBackButton")
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .tarotHeaderControlIcon()
            }
            .buttonStyle(TarotHeaderControlStyle())
            .accessibilityLabel(Text(lang == .english ? "Leave Tarot" : "離開塔羅"))
            .accessibilityIdentifier("tarotPreExitButton")
        }
        .padding(.horizontal, 8)
        .frame(height: 48)
    }

    /// Back walks the pre-reading steps without discarding the draft
    /// (§24): review → setup → intent selection → leave the flow.
    private func goBack() {
        switch phase {
        case .intentSelection:
            dismiss()
        case .spreadSetup:
            withAnim { draft?.phase = .intentSelection }
        case .setupReview, .readyToLaunch:
            withAnim { draft?.phase = .spreadSetup }
        }
    }

    private func withAnim(_ body: () -> Void) {
        if reduceMotion { body() } else {
            withAnimation(.easeInOut(duration: 0.3), body)
        }
    }

    // MARK: Intent selection (landing)

    private var landing: some View {
        ScrollView {
            VStack(spacing: TwinkoSpacing.s) {
                TarotTwinkoView(state: .idle, size: TarotTwinkoSize.supporting,
                                effect: .idleGlow)
                    .padding(.top, TwinkoSpacing.s)
                Text(TarotPreReadingStrings.landingTitle(lang))
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.textInverseToken)
                    .padding(.bottom, TwinkoSpacing.xs)

                ForEach(TarotIntent.allCases) { intent in
                    intentCard(intent)
                }
            }
            .padding(.horizontal, TwinkoSpacing.m)
            .padding(.bottom, TwinkoSpacing.l)
        }
    }

    private func intentCard(_ intent: TarotIntent) -> some View {
        let expanded = expandedIntent == intent
        return VStack(spacing: 0) {
            Button {
                if intent.refinements.isEmpty {
                    select(intent: intent, refinement: nil)
                } else {
                    withAnim { expandedIntent = expanded ? nil : intent }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: intent.icon)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(TarotCTAPalette.antiqueGold)
                        .frame(width: 26)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(intent.title(lang))
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(TarotCTAPalette.warmLightText)
                        Text(intent.supportingCopy(lang))
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(TarotCTAPalette.warmLightText.opacity(0.72))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                    if !intent.refinements.isEmpty {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(TarotCTAPalette.warmLightText.opacity(0.6))
                            .rotationEffect(.degrees(expanded ? 180 : 0))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(TwinkoHapticPressStyle())
            .accessibilityIdentifier("tarotIntent-\(intent.rawValue)")
            .accessibilityLabel(Text("\(intent.title(lang))，\(intent.supportingCopy(lang))"))

            // Lightweight in-flow refinement (§11.4/§11.5) — never a
            // second full-screen questionnaire.
            if expanded {
                VStack(spacing: 6) {
                    ForEach(intent.refinements) { refinement in
                        Button {
                            select(intent: intent, refinement: refinement)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.turn.down.right")
                                    .font(.system(size: 11))
                                    .foregroundStyle(TarotCTAPalette.antiqueGold.opacity(0.8))
                                Text(refinement.title(lang))
                                    .font(.system(.footnote, design: .rounded))
                                    .foregroundStyle(TarotCTAPalette.warmLightText)
                                    .multilineTextAlignment(.leading)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .background(Color.white.opacity(0.06),
                                        in: RoundedRectangle(cornerRadius: 10))
                            .contentShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(TwinkoHapticPressStyle())
                        .accessibilityIdentifier("tarotRefinement-\(refinement.rawValue)")
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                .transition(.opacity)
            }
        }
        .twinkoNightChoice(cornerRadius: TwinkoRadius.card, selected: expanded)
    }

    /// One intent (+ optional refinement) deterministically resolves
    /// to one recommended spread. Re-selecting keeps previously typed
    /// input on the same draft (compatible input is never destroyed by
    /// ordinary pre-reading navigation).
    private func select(intent: TarotIntent, refinement: TarotIntentRefinement?) {
        guard let spread = TarotSpreadLibrary.recommendedSpread(for: intent,
                                                                refinement: refinement)
        else { return }
        validationAttempted = false
        withAnim {
            if var existing = draft {
                existing.intent = intent
                existing.refinement = refinement
                existing.recommendedSpreadID = spread
                existing.selectedSpreadID = spread
                existing.phase = .spreadSetup
                draft = existing
            } else {
                draft = TarotReadingDraft(intent: intent, refinement: refinement,
                                          spreadID: spread)
            }
            expandedIntent = nil
        }
    }

    // MARK: Recommended Spread Setup

    @ViewBuilder
    private var setup: some View {
        if let draft {
            let definition = draft.selectedDefinition
            ScrollView {
                VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                    // Small badge — never embedded in the title. After a
                    // manual change the recommendation copy disappears
                    // and a quiet "your choice" caption takes over.
                    HStack {
                        if draft.isManualSelection {
                            Text(TarotPreReadingStrings.yourChoiceBadge(lang))
                                .font(.system(.caption2, design: .rounded).weight(.semibold))
                                .foregroundStyle(TarotCTAPalette.warmLightText.opacity(0.8))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.10), in: Capsule())
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 9))
                                Text(TarotPreReadingStrings.twinkoSuggests(lang))
                                    .font(.system(.caption2, design: .rounded).weight(.semibold))
                            }
                            .foregroundStyle(TarotCTAPalette.antiqueGold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(TarotCTAPalette.antiqueGold.opacity(0.14), in: Capsule())
                            .accessibilityIdentifier("tarotSuggestsBadge")
                        }
                        Spacer()
                        Text(definition.id.cardCountLabel(lang))
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Color.textInverseToken.opacity(0.75))
                    }

                    Text(definition.id.title(lang))
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(Color.textInverseToken)
                        .accessibilityIdentifier("tarotSetupSpreadTitle")

                    if !draft.isManualSelection {
                        Text(definition.id.recommendationReason(lang))
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(TarotCTAPalette.antiqueGold.opacity(0.95))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Contextual entries: one brief line explaining
                    // the suggestion (Daily explanation, Chat/Home
                    // context) — display only, never a claim.
                    if let summary = draft.contextSummary {
                        Text(summary)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(Color.textInverseToken.opacity(0.75))
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("tarotContextSummary")
                    }

                    Text(definition.id.purpose(lang))
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)

                    TarotSpreadPreviewView(definition: definition, lang: lang)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, TwinkoSpacing.s)

                    inputSection(definition: definition)

                    Button {
                        changeSpreadFromReview = false
                        showingChangeSpread = true
                    } label: {
                        Text(TarotPreReadingStrings.changeSpread(lang))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.tarotMagicSecondary)
                    .accessibilityIdentifier("tarotChangeSpreadButton")

                    Button {
                        continueToReview()
                    } label: {
                        Text(TarotPreReadingStrings.continueCTA(lang))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.tarotMagicPrimary)
                    .accessibilityIdentifier("tarotSetupContinue")
                    .padding(.bottom, TwinkoSpacing.m)
                }
                .padding(.horizontal, TwinkoSpacing.m)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private func continueToReview() {
        guard let current = draft else { return }
        if current.isLaunchable {
            validationAttempted = false
            withAnim { draft?.phase = .setupReview }
        } else {
            withAnim { validationAttempted = true }
        }
    }

    // MARK: Inputs

    @ViewBuilder
    private func inputSection(definition: TarotSpreadDefinition) -> some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            Text(definition.id.questionGuidance(lang))
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.textInverseToken)
                .fixedSize(horizontal: false, vertical: true)

            switch definition.inputKind {
            case .generalQuestion:
                multilineField(text: questionBinding,
                               placeholder: definition.id.questionPlaceholder(lang),
                               identifier: "tarotPreQuestionField",
                               label: definition.id.questionGuidance(lang))
            case .twoChoice:
                fieldLabel(TarotPreReadingStrings.decisionContextLabel(lang))
                multilineField(text: binding(\.decisionContext),
                               placeholder: definition.id.questionPlaceholder(lang),
                               identifier: "tarotDecisionContextField",
                               label: TarotPreReadingStrings.decisionContextLabel(lang))
                inlineError(.decisionContext,
                            TarotPreReadingStrings.validationContextRequired(lang))
                fieldLabel(TarotPreReadingStrings.optionALabel(lang))
                singleLineField(text: binding(\.optionA),
                                identifier: "tarotOptionAField",
                                label: TarotPreReadingStrings.optionALabel(lang))
                inlineError(.optionA, TarotPreReadingStrings.validationOptionARequired(lang))
                fieldLabel(TarotPreReadingStrings.optionBLabel(lang))
                singleLineField(text: binding(\.optionB),
                                identifier: "tarotOptionBField",
                                label: TarotPreReadingStrings.optionBLabel(lang))
                inlineError(.optionB, TarotPreReadingStrings.validationOptionBRequired(lang))
            case .relationship:
                multilineField(text: questionBinding,
                               placeholder: definition.id.questionPlaceholder(lang),
                               identifier: "tarotPreQuestionField",
                               label: definition.id.questionGuidance(lang))
                inlineError(.question,
                            TarotPreReadingStrings.validationRelationshipQuestionRequired(lang))
                fieldLabel(TarotPreReadingStrings.personLabelLabel(lang))
                singleLineField(text: binding(\.relationshipPersonLabel),
                                identifier: "tarotRelationshipLabelField",
                                label: TarotPreReadingStrings.personLabelLabel(lang))
            }

            Text(TarotPreReadingStrings.helperCopy(lang))
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)

            // Two or three selectable examples: prefill only, never
            // submit; user text stays freely editable.
            let examples = Array(definition.id.exampleQuestions(lang).prefix(3))
            if !examples.isEmpty {
                ForEach(examples, id: \.self) { example in
                    Button {
                        if definition.inputKind == .twoChoice {
                            draft?.decisionContext = example
                        } else {
                            draft?.question = example
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.twinkoGold.opacity(0.85))
                                .padding(.top, 2)
                            Text(example)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(TarotCTAPalette.warmLightText)
                                .multilineTextAlignment(.leading)
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
                        ? "Fills the field" : "會填入欄位"))
                }
            }
        }
        .padding(TwinkoSpacing.m)
        .twinkoGlass(cornerRadius: TwinkoRadius.card, tint: 0.32, night: true)
    }

    private var questionBinding: Binding<String> { binding(\.question) }

    private func binding(_ keyPath: WritableKeyPath<TarotReadingDraft, String>) -> Binding<String> {
        Binding(
            get: { draft?[keyPath: keyPath] ?? "" },
            set: { draft?[keyPath: keyPath] = $0 })
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(.subheadline, design: .rounded).weight(.semibold))
            .foregroundStyle(Color.textInverseToken)
    }

    private func multilineField(text: Binding<String>, placeholder: String,
                                identifier: String, label: String) -> some View {
        TextField("", text: text,
                  prompt: Text(placeholder)
                    .foregroundStyle(Color.textInverseToken.opacity(0.45)),
                  axis: .vertical)
            .font(.system(.body, design: .rounded))
            .padding(10)
            .twinkoGlass(cornerRadius: 12, tint: 0.46, night: true)
            .foregroundStyle(Color.textInverseToken)
            .tint(.accentGold)
            .lineLimit(1...4)
            .accessibilityLabel(Text(label))
            .accessibilityIdentifier(identifier)
    }

    private func singleLineField(text: Binding<String>, identifier: String,
                                 label: String) -> some View {
        TextField("", text: text)
            .font(.system(.body, design: .rounded))
            .padding(10)
            .frame(minHeight: 44)
            .twinkoGlass(cornerRadius: 12, tint: 0.46, night: true)
            .foregroundStyle(Color.textInverseToken)
            .tint(.accentGold)
            .accessibilityLabel(Text(label))
            .accessibilityIdentifier(identifier)
    }

    /// Field-level inline validation (no native alerts, nothing
    /// invented, nothing erased) — shown only after an attempted
    /// continue while the field is still empty.
    @ViewBuilder
    private func inlineError(_ field: TarotDraftField, _ message: String) -> some View {
        if validationAttempted, draft?.missingRequiredFields.contains(field) == true {
            HStack(spacing: 5) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 11))
                Text(message)
                    .font(.system(.caption, design: .rounded))
            }
            .foregroundStyle(Color(hex: 0xF3B8B8))
            .accessibilityIdentifier("tarotValidation-\(String(describing: field))")
            .transition(.opacity)
        }
    }

    // MARK: Setup Review

    @ViewBuilder
    private var review: some View {
        if let draft {
            let definition = draft.selectedDefinition
            ScrollView {
                VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                    Text(TarotPreReadingStrings.reviewTitle(lang))
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(Color.textInverseToken)
                        .accessibilityIdentifier("tarotReviewTitle")

                    // The user's own words.
                    VStack(alignment: .leading, spacing: TwinkoSpacing.xs) {
                        switch definition.inputKind {
                        case .generalQuestion:
                            reviewRow(label: TarotPreReadingStrings.reviewQuestion(lang),
                                      value: draft.trimmedQuestion)
                        case .twoChoice:
                            reviewRow(label: TarotPreReadingStrings.decisionContextLabel(lang),
                                      value: draft.trimmedDecisionContext)
                            reviewRow(label: TarotPreReadingStrings.optionALabel(lang),
                                      value: draft.trimmedOptionA)
                            reviewRow(label: TarotPreReadingStrings.optionBLabel(lang),
                                      value: draft.trimmedOptionB)
                        case .relationship:
                            reviewRow(label: TarotPreReadingStrings.reviewQuestion(lang),
                                      value: draft.trimmedQuestion)
                            if !draft.trimmedPersonLabel.isEmpty {
                                reviewRow(label: TarotPreReadingStrings.personLabelLabel(lang),
                                          value: draft.trimmedPersonLabel)
                            }
                        }
                    }
                    .padding(TwinkoSpacing.m)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .twinkoGlass(cornerRadius: TwinkoRadius.card, tint: 0.32, night: true)

                    // The spread and its ordered position meanings.
                    VStack(alignment: .leading, spacing: TwinkoSpacing.xs) {
                        HStack {
                            Text(definition.id.title(lang))
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(Color.textInverseToken)
                            Spacer()
                            Text(definition.id.cardCountLabel(lang))
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(Color.textInverseToken.opacity(0.75))
                        }
                        Text(definition.id.purpose(lang))
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(Color.textInverseToken.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                        Rectangle()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 1)
                            .padding(.vertical, 2)
                            .accessibilityHidden(true)
                        Text(TarotPreReadingStrings.positionsLabel(lang))
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(Color.textInverseToken)
                        ForEach(Array(definition.positionIDs.enumerated()), id: \.offset) { index, position in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(index + 1)")
                                    .font(.system(.caption2, design: .rounded).weight(.bold))
                                    .foregroundStyle(TarotCTAPalette.antiqueGold)
                                    .frame(width: 18, height: 18)
                                    .background(TarotCTAPalette.antiqueGold.opacity(0.15),
                                                in: Circle())
                                Text(position.label(lang))
                                    .font(.system(.footnote, design: .rounded))
                                    .foregroundStyle(Color.textInverseToken.opacity(0.9))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(TwinkoSpacing.m)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .twinkoGlass(cornerRadius: TwinkoRadius.card, tint: 0.32, night: true)

                    Button {
                        withAnim { self.draft?.phase = .spreadSetup }
                    } label: {
                        Text(TarotPreReadingStrings.editQuestion(lang))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.tarotMagicSecondary)
                    .accessibilityIdentifier("tarotReviewEditQuestion")

                    Button {
                        changeSpreadFromReview = true
                        showingChangeSpread = true
                    } label: {
                        Text(TarotPreReadingStrings.changeSpread(lang))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.tarotMagicSecondary)
                    .accessibilityIdentifier("tarotReviewChangeSpread")

                    Button {
                        beginReading()
                    } label: {
                        Text(TarotPreReadingStrings.beginReading(lang))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.tarotMagicPrimary)
                    .accessibilityIdentifier("tarotReviewBegin")
                    .padding(.bottom, TwinkoSpacing.m)
                }
                .padding(.horizontal, TwinkoSpacing.m)
            }
        }
    }

    private func reviewRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.65))
            Text(value.isEmpty ? TarotPreReadingStrings.notProvided(lang) : value)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textInverseToken
                    .opacity(value.isEmpty ? 0.5 : 1.0))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Launch boundary: revalidate, then hand exactly one canonical
    /// validated launch request to the reading engine (Task 2). No
    /// cards are created here.
    private func beginReading() {
        guard var current = draft, current.isLaunchable else {
            withAnim { draft?.phase = .spreadSetup; validationAttempted = true }
            return
        }
        current.phase = .readyToLaunch
        draft = current
        onLaunch(TarotReadingLaunchRequest(draft: current))
        // Returning after New Reading resumes at the review with the
        // draft intact.
        draft?.phase = .setupReview
    }

    // MARK: Change Spread sheet

    private var changeSpreadSheet: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                Text(TarotPreReadingStrings.changeSpread(lang))
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(Color.textInverseToken)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, TwinkoSpacing.m)

                ForEach(TarotSpreadLibrary.SelectorGroup.allCases) { group in
                    Text(group.title(lang))
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(TarotCTAPalette.antiqueGold)
                        .padding(.top, TwinkoSpacing.xs)
                    ForEach(group.spreadIDs) { spreadID in
                        spreadRow(spreadID)
                    }
                }
            }
            .padding(.horizontal, TwinkoSpacing.m)
            .padding(.bottom, TwinkoSpacing.l)
        }
        .background {
            LinearGradient(colors: [Color(hex: 0x2A2140), Color(hex: 0x1A1430)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func spreadRow(_ spreadID: TarotSpreadID) -> some View {
        let selected = draft?.selectedSpreadID == spreadID
        return Button {
            changeSpread(to: spreadID)
        } label: {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(spreadID.title(lang))
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(TarotCTAPalette.warmLightText)
                    Text(spreadID.purpose(lang))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(TarotCTAPalette.warmLightText.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                    if spreadID == .relationshipFive {
                        Text(TarotPreReadingStrings.romanticCaption(lang))
                            .font(.system(.caption2, design: .rounded).weight(.medium))
                            .foregroundStyle(Color(hex: 0xF0A8C0))
                    }
                }
                .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 4) {
                    Text(spreadID.cardCountLabel(lang))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(TarotCTAPalette.warmLightText.opacity(0.7))
                    if selected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(TarotCTAPalette.antiqueGold)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(TwinkoHapticPressStyle())
        .twinkoNightChoice(cornerRadius: 14, selected: selected)
        .accessibilityIdentifier("tarotSpreadOption-\(spreadID.rawValue)")
        .accessibilityLabel(Text("\(spreadID.title(lang))，\(spreadID.cardCountLabel(lang))"))
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    /// Changing spread mutates the same draft: compatible general
    /// question text is preserved, structured values stay attached to
    /// the draft (shown again if the user returns before beginning),
    /// nothing auto-starts, and a change made from the review returns
    /// to setup so newly required fields can be completed.
    private func changeSpread(to spreadID: TarotSpreadID) {
        validationAttempted = false
        withAnim {
            draft?.selectedSpreadID = spreadID
            if changeSpreadFromReview { draft?.phase = .spreadSetup }
        }
        showingChangeSpread = false
    }
}

// MARK: - Spread preview (lightweight functional diagrams)

/// Compact position preview built from the canonical card back — card
/// count, order, and semantic grouping only. Implements exactly the
/// five MVP layout kinds; not a general layout engine, and reusable by
/// the future result overview.
struct TarotSpreadPreviewView: View {
    let definition: TarotSpreadDefinition
    let lang: AppLanguage

    var body: some View {
        Group {
            switch definition.layoutKind {
            case .single:
                miniCard(index: 0, width: 56)
            case .threeLinear:
                HStack(alignment: .top, spacing: TwinkoSpacing.m) {
                    ForEach(0..<3, id: \.self) { miniCard(index: $0, width: 44) }
                }
            case .fourGrid:
                VStack(spacing: TwinkoSpacing.s) {
                    HStack(alignment: .top, spacing: TwinkoSpacing.l) {
                        miniCard(index: 0, width: 44)
                        miniCard(index: 1, width: 44)
                    }
                    HStack(alignment: .top, spacing: TwinkoSpacing.l) {
                        miniCard(index: 2, width: 44)
                        miniCard(index: 3, width: 44)
                    }
                }
            case .twoChoiceFive:
                VStack(spacing: TwinkoSpacing.s) {
                    HStack(alignment: .top, spacing: TwinkoSpacing.l) {
                        sideColumn(header: lang == .english ? "Option A" : "選項 A",
                                   indices: [0, 2])
                        sideColumn(header: lang == .english ? "Option B" : "選項 B",
                                   indices: [1, 3])
                    }
                    miniCard(index: 4, width: 40)
                }
            case .relationshipFive:
                VStack(spacing: TwinkoSpacing.s) {
                    HStack(alignment: .top, spacing: TwinkoSpacing.l) {
                        sideColumn(header: lang == .english ? "Me" : "我",
                                   indices: [0, 1])
                        sideColumn(header: lang == .english ? "The Other Person" : "對方",
                                   indices: [2, 3])
                    }
                    miniCard(index: 4, width: 40)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilitySummary))
        .accessibilityIdentifier("tarotSpreadPreview-\(definition.id.rawValue)")
    }

    private var accessibilitySummary: String {
        let positions = definition.positionIDs.enumerated()
            .map { "\($0.offset + 1) \($0.element.label(lang))" }
            .joined(separator: lang == .english ? ", " : "，")
        return "\(definition.id.cardCountLabel(lang))\(lang == .english ? ": " : "：")\(positions)"
    }

    private func sideColumn(header: String, indices: [Int]) -> some View {
        VStack(spacing: TwinkoSpacing.xs) {
            Text(header)
                .font(.system(.caption2, design: .rounded).weight(.semibold))
                .foregroundStyle(TarotCTAPalette.antiqueGold.opacity(0.9))
            HStack(alignment: .top, spacing: TwinkoSpacing.s) {
                ForEach(indices, id: \.self) { miniCard(index: $0, width: 36) }
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }

    private func miniCard(index: Int, width: CGFloat) -> some View {
        VStack(spacing: 4) {
            TarotCardBack(width: width)
                .overlay(alignment: .topLeading) {
                    Text("\(index + 1)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x2A2140))
                        .frame(width: 15, height: 15)
                        .background(TarotCTAPalette.antiqueGold, in: Circle())
                        .offset(x: -4, y: -4)
                }
            Text(definition.positionIDs[index].previewLabel(lang))
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.85))
                .lineLimit(1)
        }
    }
}

// MARK: - Screen-level copy

/// Localized copy for the pre-reading screens (spread- and
/// position-level copy lives with the enums in TarotSpreadLibrary).
enum TarotPreReadingStrings {
    static func landingTitle(_ l: AppLanguage) -> String {
        l == .english ? "What would you like clarity on?" : "這次想從哪個角度看看？"
    }
    static func twinkoSuggests(_ l: AppLanguage) -> String {
        l == .english ? "Twinko Suggests" : "Twinko 建議"
    }
    static func yourChoiceBadge(_ l: AppLanguage) -> String {
        l == .english ? "Your choice" : "自選牌陣"
    }
    static func changeSpread(_ l: AppLanguage) -> String {
        l == .english ? "Change Spread" : "更換牌陣"
    }
    static func continueCTA(_ l: AppLanguage) -> String {
        l == .english ? "Continue" : "繼續"
    }
    static func reviewTitle(_ l: AppLanguage) -> String {
        l == .english ? "Review your setup before you begin" : "開始前，確認這次的設定"
    }
    static func reviewQuestion(_ l: AppLanguage) -> String {
        l == .english ? "Your question" : "你的問題"
    }
    static func positionsLabel(_ l: AppLanguage) -> String {
        l == .english ? "Position meanings" : "牌位意義"
    }
    static func editQuestion(_ l: AppLanguage) -> String {
        l == .english ? "Edit Question" : "修改問題"
    }
    static func beginReading(_ l: AppLanguage) -> String {
        l == .english ? "Begin Reading" : "開始抽牌"
    }
    static func notProvided(_ l: AppLanguage) -> String {
        l == .english ? "Not filled in" : "未填寫"
    }
    static func decisionContextLabel(_ l: AppLanguage) -> String {
        l == .english ? "What decision are you considering?" : "你正在考慮什麼？"
    }
    static func optionALabel(_ l: AppLanguage) -> String {
        l == .english ? "Option A" : "選項 A"
    }
    static func optionBLabel(_ l: AppLanguage) -> String {
        l == .english ? "Option B" : "選項 B"
    }
    static func personLabelLabel(_ l: AppLanguage) -> String {
        l == .english ? "Person or relationship label (optional)" : "對方稱呼（選填）"
    }
    static func romanticCaption(_ l: AppLanguage) -> String {
        l == .english ? "Romantic relationships" : "感情限定"
    }
    static func helperCopy(_ l: AppLanguage) -> String {
        l == .english
            ? "Open-ended questions usually work best, such as “What might I need to see?” or “How can I understand this situation more clearly?”"
            : "比較適合開放式問題，例如「我需要看見什麼？」或「我可以如何理解這件事？」"
    }
    static func validationContextRequired(_ l: AppLanguage) -> String {
        l == .english ? "Please describe the decision you're considering"
                      : "請寫下你正在考慮的事"
    }
    static func validationOptionARequired(_ l: AppLanguage) -> String {
        l == .english ? "Option A can't be empty" : "選項 A 不能是空白"
    }
    static func validationOptionBRequired(_ l: AppLanguage) -> String {
        l == .english ? "Option B can't be empty" : "選項 B 不能是空白"
    }
    static func validationRelationshipQuestionRequired(_ l: AppLanguage) -> String {
        l == .english ? "Please write what you'd like to understand"
                      : "請先寫下想理解的面向"
    }
}

/// Quiet pressed feedback for suggestion/example rows (not a full
/// magic CTA).
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
