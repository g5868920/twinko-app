import Foundation
import SwiftUI

// MARK: - Phase A step 10: live Tarot generation with mock fallback
//
// PROVISIONAL implementation prepared for founder review — the safety
// matrix (v0.2 draft) and all user-facing disclosure/consent copy are
// PENDING founder approval and may be revised; nothing here is
// committed until authorized. Pipeline: consent-gated live call →
// grounded prompt → schema decode + validation → app-enforced safety
// action (incl. user-approved reframe) → render, with the
// deterministic mock as the labeled fallback for every failure path.
// The network boundary sits strictly BEHIND the consent decision: no
// provider is resolved, no request is constructed, and nothing is
// sent until the user explicitly continues. Vendor-neutral: an
// explicit provider choice is required when both keys are configured
// (fail closed — no implicit preference while D-043 is open).

// MARK: Consent (first live call — approved disclosure wording)

/// Local record that the founder-approved in-context disclosure was
/// accepted for Tarot. Declining is never persisted — the sheet asks
/// again on the next reading, and the current reading uses the mock.
struct LLMConsentRecord: Codable, Equatable {
    var tarotAcceptedAt: Date?
}

final class LLMConsentStore {
    static let fileName = "llm_consent"

    private let store: JSONStore
    private(set) var record: LLMConsentRecord

    init(store: JSONStore = JSONStore()) {
        self.store = store
        record = store.load(LLMConsentRecord.self, from: Self.fileName)
            ?? LLMConsentRecord()
    }

    var hasTarotConsent: Bool { record.tarotAcceptedAt != nil }

    func acceptTarot(at date: Date = .now) {
        record.tarotAcceptedAt = date
        store.save(record, as: Self.fileName)
    }
}

// MARK: Provider resolution (vendor-neutral, D-043 open)

enum TarotLiveProviderResolver {
    /// Pure resolution so tests need no bundle: which configured
    /// provider serves live Tarot, and with which model. FAIL-CLOSED
    /// rules (no invisible provider preference while the D-043 blind
    /// benchmark is pending):
    /// - OpenAI is unusable without an explicitly configured model id
    ///   (never guessed).
    /// - An explicit `TAROT_LIVE_PROVIDER` is honored strictly — if
    ///   the named provider is not usable, resolution fails (no
    ///   silent substitution).
    /// - Both providers usable with no explicit choice → nil: no live
    ///   request happens and the labeled mock renders.
    static func resolve(anthropicConfigured: Bool,
                        openaiConfigured: Bool,
                        preferred: String?,
                        anthropicModel: String?,
                        openaiModel: String?) -> (provider: LLMProvider, model: String)? {
        let anthropic: (LLMProvider, String)? = anthropicConfigured
            ? (.anthropic, anthropicModel ?? "claude-sonnet-5") : nil
        let openai: (LLMProvider, String)? = (openaiConfigured && openaiModel != nil)
            ? (.openai, openaiModel!) : nil

        switch preferred {
        case "anthropic": return anthropic
        case "openai": return openai
        case .some: return nil   // unknown value: fail closed
        case nil:
            // No explicit choice: only an unambiguous single usable
            // provider resolves.
            switch (anthropic, openai) {
            case (let a?, nil): return a
            case (nil, let o?): return o
            default: return nil
            }
        }
    }

    /// Runtime resolution from the local Phase A config. Emits a
    /// concise development configuration note (never secrets) when
    /// resolution fails while keys exist.
    static func current() -> (service: LLMServing, model: String)? {
        let anthropicConfigured = LLMSecrets.apiKey(for: .anthropic) != nil
        let openaiConfigured = LLMSecrets.apiKey(for: .openai) != nil
        guard let resolved = resolve(
            anthropicConfigured: anthropicConfigured,
            openaiConfigured: openaiConfigured,
            preferred: LLMSecrets.configValue("TAROT_LIVE_PROVIDER"),
            anthropicModel: LLMSecrets.configValue("TAROT_LIVE_ANTHROPIC_MODEL"),
            openaiModel: LLMSecrets.configValue("TAROT_LIVE_OPENAI_MODEL")
                ?? LLMSecrets.configValue("TAROT_BENCHMARK_OPENAI_MODEL"))
        else {
            if anthropicConfigured || openaiConfigured {
                LLMEngine.log.error("tarot live provider unresolved: set TAROT_LIVE_PROVIDER (and an explicit OpenAI model id if using OpenAI); falling back to labeled mock")
            }
            return nil
        }
        switch resolved.provider {
        case .anthropic: return (AnthropicLLMService(), resolved.model)
        case .openai: return (OpenAILLMService(), resolved.model)
        }
    }
}

// MARK: Live provider (validated response → existing UI protocol)

/// Adapts one validated `TarotLLMResponse` to the interpretation
/// protocol the result UI already speaks. The Guidance Card (drawn
/// after the live call) and the closing line stay with the
/// deterministic fallback — a documented Phase A limitation; a live
/// guidance addendum is future work.
struct LiveTarotInterpretationProvider: TarotInterpretationProviding {
    let response: TarotLLMResponse
    let fallback: TarotInterpretationProviding

    func interpretation(for card: TarotDrawnCard,
                        in session: TarotReadingSession,
                        lang: AppLanguage) -> TarotCardInterpretation {
        guard card.role == .basePosition,
              let positionID = card.positionID,
              let position = response.positions.first(where: {
                  $0.positionId == positionID.rawValue && $0.cardId == card.card.id
              }) else {
            return fallback.interpretation(for: card, in: session, lang: lang)
        }
        let upright = card.orientation == .upright
        let keywords = lang == .english
            ? (upright ? card.card.keywordsUprightEn : card.card.keywordsReversedEn)
            : (upright ? card.card.keywordsUprightZh : card.card.keywordsReversedZh)
        return TarotCardInterpretation(keywords: keywords,
                                       core: position.interpretation,
                                       detail: "",
                                       reflectionPrompt: position.reflectionPrompt)
    }

    func synthesis(for session: TarotReadingSession, lang: AppLanguage) -> String {
        response.crossCardPatterns.isEmpty
            ? response.integratedSummary : response.crossCardPatterns
    }

    /// The live integrated summary keeps describing the base reading
    /// after a Guidance Card is drawn (the guidance block itself reads
    /// from the fallback provider).
    func combinedSummary(for session: TarotReadingSession, lang: AppLanguage) -> String {
        response.integratedSummary
    }

    func twinkoMessage(for session: TarotReadingSession, lang: AppLanguage) -> String {
        response.gentleNextStep
    }

    func closingLine(lang: AppLanguage) -> String {
        fallback.closingLine(lang: lang)
    }
}

// MARK: State model

/// Owns one reading's live-generation lifecycle. All content decisions
/// stay deterministic and app-side: the model classifies, the app
/// enforces (safety matrix), every failure path lands on the labeled
/// mock fallback, and logging is category/number only.
@MainActor
final class TarotLiveReadingModel: ObservableObject {
    enum State: Equatable {
        /// Mock-only: build not live-capable.
        case idle
        /// Live-capable and the (provisional) disclosure has not been
        /// accepted yet — the consent sheet is showing. NO provider
        /// has been resolved and NO request exists in this state.
        case awaitingConsent
        case loading
        case live(TarotLLMResponse)
        /// The matrix requires a user-approved safe reframe before any
        /// reading renders. Only the category is kept — the original
        /// prohibited interpretation is discarded, never rendered.
        case awaitingReframe(TarotLLMSafetyCategory)
        /// Live was attempted (or unavailable/declined) — mock renders
        /// with the honest fallback label. Payload is an error/reason
        /// category only, never content.
        case fallback(String)
    }

    /// Guidance Card must stay unavailable while a reframe is
    /// unresolved and after it was declined/unresolved — requesting a
    /// Guidance Card must never bypass the original restriction.
    var restrictsGuidance: Bool {
        switch state {
        case .awaitingReframe:
            return true
        case .fallback(let reason):
            return reason == "reframeDeclined" || reason == "reframeUnresolved"
        case .live(let response):
            return !TarotSafetyMatrix.action(for: response.safetyCategory)
                .allowGuidanceCardCTA
        case .idle, .awaitingConsent, .loading:
            return false
        }
    }

    @Published private(set) var state: State = .idle

    /// Debug-only provenance for the diagnostic row (e.g.
    /// "OpenAI · gpt-…", "Debug Stub · stub-model", "stored live
    /// reading"). Non-nil only while `state == .live`, so a fallback
    /// can never keep displaying a provider as though the live
    /// request succeeded. Never rendered in Release builds.
    @Published private(set) var liveSourceDescription: String?

    private let consent: LLMConsentStore
    /// Injectable for tests; `nil` falls back to runtime resolution.
    private let serviceOverride: (service: LLMServing, model: String)?
    /// True only for the launch-env UI stub, so the diagnostic row can
    /// never present stub output as a real provider response.
    private let isStubOverride: Bool
    private let liveCapable: () -> Bool
    private var preparedSessionID: UUID?
    private var task: Task<Void, Never>?
    /// Set when the user tapped Not Now on the pre-reading consent
    /// gate: the next prepared reading renders the labeled mock and
    /// the question is asked again on a later attempt.
    private var declinedNextReading = false

    // MARK: Pre-reading consent gate (correction 2: consent precedes
    // the draw, and the network boundary stays behind it)

    var isLiveCapable: Bool { liveCapable() }
    var hasConsent: Bool { consent.hasTarotConsent }

    /// Continue with AI on the pre-reading disclosure.
    func acceptConsent() { consent.acceptTarot() }

    /// Not Now on the pre-reading disclosure: nothing persisted, this
    /// reading uses the labeled mock, zero provider activity.
    func declineConsentOnce() { declinedNextReading = true }

    init(consent: LLMConsentStore = LLMConsentStore(),
         serviceOverride: (service: LLMServing, model: String)? = nil,
         isStubOverride: Bool = false,
         liveCapable: @escaping () -> Bool = { LLMPrivacyDisclosure.isActive }) {
        self.consent = consent
        self.serviceOverride = serviceOverride
        self.isStubOverride = isStubOverride
        self.liveCapable = liveCapable
    }

    /// Called when the result stage appears. Idempotent per session:
    /// navigation back/forward never refetches. A restored reading
    /// (Daily reopen) reuses its stored validated response — no new
    /// call, no cost, no text drift; a restored reading without a
    /// stored response stays on the mock it was completed with.
    func prepare(session: TarotReadingSession, lang: AppLanguage,
                 isRestored: Bool,
                 restoredResponse: TarotLLMResponse?,
                 onLiveResponse: @escaping (TarotLLMResponse) -> Void = { _ in }) {
        guard preparedSessionID != session.id else { return }
        preparedSessionID = session.id
        liveSourceDescription = nil

        if let restoredResponse {
            liveSourceDescription = "stored live reading (today)"
            state = .live(restoredResponse)
            return
        }
        guard !isRestored, liveCapable() else {
            state = .idle
            return
        }
        if declinedNextReading {
            declinedNextReading = false
            state = .fallback("declined")
            return
        }
        guard consent.hasTarotConsent else {
            // Fallback only — the normal path resolves consent at the
            // pre-reading gate before any card is drawn.
            state = .awaitingConsent
            return
        }
        fetch(session: session, lang: lang, onLiveResponse: onLiveResponse)
    }

    /// Continue on the approved disclosure sheet.
    func consentGranted(session: TarotReadingSession, lang: AppLanguage,
                        onLiveResponse: @escaping (TarotLLMResponse) -> Void = { _ in }) {
        consent.acceptTarot()
        fetch(session: session, lang: lang, onLiveResponse: onLiveResponse)
    }

    /// Not Now: this reading stays on the labeled mock; nothing is
    /// persisted, so the next reading asks again (user stays in
    /// control).
    func consentDeclined() {
        state = .fallback("declined")
    }

    /// User chose not to wait for the live reading.
    func skipWaiting() {
        task?.cancel()
        if case .loading = state { state = .fallback("skipped") }
    }

    /// Cancel/Back on the post-draw reframe offer: no reading for the
    /// original question, labeled mock renders, Guidance stays
    /// restricted. (Approving the offer starts a NEW reading with new
    /// cards at the flow level — committed cards are never
    /// reinterpreted under a changed question.)
    func declineReframe() {
        guard case .awaitingReframe = state else { return }
        state = .fallback("reframeDeclined")
    }

    private func fetch(session: TarotReadingSession, lang: AppLanguage,
                       onLiveResponse: @escaping (TarotLLMResponse) -> Void) {
        guard let resolved = serviceOverride ?? TarotLiveProviderResolver.current() else {
            state = .fallback("notConfigured")
            return
        }
        liveSourceDescription = nil
        state = .loading
        let providerName = resolved.service.provider == .openai ? "OpenAI" : "Anthropic"
        let sourceDescription = isStubOverride
            ? "Debug Stub · \(resolved.model)"
            : "\(providerName) · \(resolved.model)"
        let request = TarotPromptBuilder.request(for: session, lang: lang,
                                                 model: resolved.model)
        task = Task { [weak self] in
            do {
                let result = try await resolved.service.complete(request)
                guard !Task.isCancelled else { return }
                guard let response = TarotLLMResponse.decode(fromModelText: result.text),
                      TarotLLMResponseValidator.validate(response, for: session).isEmpty
                else {
                    // Malformed/unknown safety output fails toward the
                    // safest supported behavior: nothing unvalidated is
                    // ever rendered; technical category only.
                    LLMEngine.log.error("tarot live response failed validation")
                    self?.state = .fallback("invalidResponse")
                    return
                }
                // Category-only safety logging — never the content.
                if response.safetyCategory != .none {
                    LLMEngine.log.info("tarot safety category=\(response.safetyCategory.rawValue, privacy: .public)")
                }
                // App-enforced policy (second layer — the preflight
                // gate already ran before the draw): the model
                // classified; the app decides what renders. A
                // restricted category discovered only now offers a NEW
                // safely reframed reading — never a reinterpretation
                // of the committed cards.
                let action = TarotSafetyMatrix.action(for: response.safetyCategory)
                if action.policy == .requireUserApprovedReframe {
                    self?.state = .awaitingReframe(response.safetyCategory)
                    return
                }
                self?.liveSourceDescription = sourceDescription
                self?.state = .live(response)
                onLiveResponse(response)
            } catch let error as LLMError {
                guard !Task.isCancelled else { return }
                self?.state = .fallback(String(describing: error))
            } catch {
                guard !Task.isCancelled else { return }
                self?.state = .fallback("unknown")
            }
        }
    }
}

// MARK: Strings — ALL copy here is PROVISIONAL, founder review pending

enum TarotLiveStrings {
    // MARK: Reframe surface (requireUserApprovedReframe)

    static func reframeTitle(_ lang: AppLanguage) -> String {
        lang == .english ? "Let's reframe this question" : "換個方式問問看"
    }
    /// Concise explanation that Tarot cannot responsibly answer the
    /// original request as written.
    static func reframeExplanation(_ lang: AppLanguage) -> String {
        lang == .english
        ? "Tarot can't responsibly answer this question as written — it asks for an outcome or certainty the cards can't honestly give. Here is a reflective question the same cards can genuinely help with. You can edit it before continuing."
        : "這個問題照原本的問法，塔羅無法負責任地回答——它要求的是牌卡無法誠實給出的結果或定論。下面是一個同一副牌真的能陪你思考的反思式問題，你可以先修改再繼續。"
    }
    static func reframeFieldLabel(_ lang: AppLanguage) -> String {
        lang == .english ? "Reflective question" : "反思式問題"
    }
    static func reframeContinue(_ lang: AppLanguage) -> String {
        lang == .english ? "Continue with this question" : "用這個問題繼續"
    }
    static func reframeCancel(_ lang: AppLanguage) -> String {
        lang == .english ? "Not now" : "先不要"
    }

    static func loadingTitle(_ lang: AppLanguage) -> String {
        lang == .english ? "Twinko is reading your cards…" : "Twinko 正在為你解讀…"
    }
    static func loadingBody(_ lang: AppLanguage) -> String {
        lang == .english
        ? "Your question and the cards drawn are being interpreted for you. This usually takes a few seconds."
        : "正在根據你的提問與抽到的牌為你解讀，通常只需要幾秒鐘。"
    }
    static func skipWaiting(_ lang: AppLanguage) -> String {
        lang == .english ? "Show sample reading instead" : "先看示意解讀"
    }
    /// Small badge on live readings.
    static func liveBadge(_ lang: AppLanguage) -> String {
        lang == .english ? "AI-generated reflection" : "AI 生成的反思內容"
    }
    /// FD-09 DRAFT: honest mock label shown only in live-capable
    /// builds when the mock substitutes for a live reading.
    static func fallbackLabel(_ lang: AppLanguage) -> String {
        lang == .english
        ? "Sample reading (not AI-personalized this time)"
        : "示意解讀（這次不是 AI 個人化生成）"
    }
    static func consentTitle(_ lang: AppLanguage) -> String {
        lang == .english ? "Use AI for this reading?" : "這次解讀要使用 AI 嗎？"
    }
    static func consentContinue(_ lang: AppLanguage) -> String {
        lang == .english ? "Continue with AI" : "繼續，使用 AI 解讀"
    }
    static func consentNotNow(_ lang: AppLanguage) -> String {
        lang == .english ? "Not now" : "暫時不要"
    }
    /// Stronger disclaimer variant (safety matrix draft, founder
    /// review pending).
    static func strongerDisclaimer(_ lang: AppLanguage) -> String {
        lang == .english
        ? "This topic touches a professional domain. Tarot can keep you company while you sort out how you feel, but it can never replace medical, legal, financial, or other professional advice — please bring important decisions to a qualified professional."
        : "這個主題涉及專業領域。塔羅可以陪你整理心情，但無法取代醫療、法律、財務等專業協助；重要決定請諮詢合格的專業人士。"
    }
}

// MARK: - Shared reframe surface (pre-reading gate + post-draw offer)

/// The one requireUserApprovedReframe surface, used both at the
/// pre-reading safety gate (before any card is drawn) and as the
/// post-draw new-reading offer. Explanation + editable reflective
/// question + explicit Continue / Not Now. Never auto-submits, never
/// silently rewrites, never draws before approval.
///
/// Accessibility (correction 4): the editor is a `TextEditor` with a
/// stable identifier and a localized label — reliably exposed to
/// VoiceOver and UI automation as a text view, with real multiline
/// editing.
struct TarotReframeCard: View {
    let category: TarotLLMSafetyCategory
    let lang: AppLanguage
    let onContinue: (String) -> Void
    let onCancel: () -> Void

    @State private var text = ""

    var body: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            HStack(spacing: 7) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(Color.accentGold)
                Text(TarotLiveStrings.reframeTitle(lang))
                    .foregroundStyle(Color.deepPlum)
            }
            .font(.system(.headline, design: .rounded))

            Text(TarotLiveStrings.reframeExplanation(lang))
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Color.textSecondaryToken)
                .lineSpacing(4)

            Text(TarotLiveStrings.reframeFieldLabel(lang))
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Color.textSecondaryToken)
            TextEditor(text: $text)
                // Identifier + label directly on the editor, before
                // any styling, so the element (not a styled wrapper)
                // carries them for VoiceOver and automation.
                .accessibilityIdentifier("tarotReframeField")
                .accessibilityLabel(Text(TarotLiveStrings.reframeFieldLabel(lang)))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textPrimaryToken)
                .scrollContentBackground(.hidden)
                .padding(6)
                .frame(minHeight: 72, maxHeight: 128)
                .background(Color.white.opacity(0.65),
                            in: RoundedRectangle(cornerRadius: 12))

            Button {
                onContinue(text)
            } label: {
                Text(TarotLiveStrings.reframeContinue(lang))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.tarotMagicPrimary)
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityIdentifier("tarotReframeContinue")

            Button {
                onCancel()
            } label: {
                Text(TarotLiveStrings.reframeCancel(lang))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.tarotMagicSecondary)
            .accessibilityIdentifier("tarotReframeCancel")
        }
        .tarotReadingCard()
        .accessibilityIdentifier("tarotReframeSection")
        .onAppear {
            if text.isEmpty {
                text = TarotSafetyMatrix.reframeSuggestion(for: category,
                                                           lang: lang) ?? ""
            }
        }
    }
}

#if DEBUG
// MARK: - UI-verification stub (Debug builds only, launch-env gated)
//
// Lets the focused Simulator check reach the consent gate, the
// stubbed live path, and the reframe state WITHOUT any key and
// WITHOUT any network. Activated only when the process was launched
// with TWINKO_LLM_UITEST_STUB=valid|reframe (UI tests); inert
// otherwise. Consent is stored in a per-launch temp directory so the
// gate always appears fresh.

private struct UITestStubLLMService: LLMServing {
    let provider: LLMProvider = .anthropic
    let mode: String

    func complete(_ request: LLMRequest) async throws -> LLMResult {
        func matches(_ pattern: String) -> [String] {
            let regex = try! NSRegularExpression(pattern: pattern)
            let range = NSRange(request.userContent.startIndex...,
                                in: request.userContent)
            return regex.matches(in: request.userContent, range: range).map {
                String(request.userContent[Range($0.range(at: 1),
                                                 in: request.userContent)!])
            }
        }
        let entries = zip(matches("position_id: (\\w+)"), matches("card_id: (\\w+)"))
            .map { position, card in
                """
                {"position_id": "\(position)", "card_id": "\(card)",
                 "interpretation": "這張牌可能反映一種值得留意的內在狀態，慢慢看就好。",
                 "reflection_prompt": "今天有什麼小事呼應了它？"}
                """
            }
        // In reframe mode the FIRST request classifies as a
        // mind-reading question; the follow-up after user approval
        // returns a normal reflective reading.
        let category = mode == "reframe"
            && !request.userContent.contains("目前實際觀察到的互動")
            ? "relationship_mind_reading" : "none"
        let json = """
        {"positions": [\(entries.joined(separator: ","))],
         "cross_card_patterns": "整體能量偏向轉換，值得留意平衡。",
         "integrated_summary": "把牌放在一起看，是一個可以慢慢想的角度。",
         "gentle_next_step": "先為自己安排一件小小的事。",
         "safety_category": "\(category)"}
        """
        return LLMResult(text: json, provider: provider, model: request.model,
                         inputTokens: 1000, outputTokens: 500,
                         latencySeconds: 0.05, finishReason: "end_turn")
    }
}
#endif

extension TarotLiveReadingModel {
    /// Default model for the app. In Debug builds a UI-test launch
    /// environment can substitute the no-network stub; every other
    /// launch behaves exactly per the real configuration.
    static func makeDefault() -> TarotLiveReadingModel {
        #if DEBUG
        if let mode = ProcessInfo.processInfo.environment["TWINKO_LLM_UITEST_STUB"],
           ["valid", "reframe"].contains(mode) {
            let freshConsent = LLMConsentStore(store: JSONStore(
                directory: FileManager.default.temporaryDirectory
                    .appendingPathComponent("uitest-consent-\(UUID().uuidString)")))
            return TarotLiveReadingModel(
                consent: freshConsent,
                serviceOverride: (UITestStubLLMService(mode: mode), "stub-model"),
                isStubOverride: true,
                liveCapable: { true })
        }
        #endif
        return TarotLiveReadingModel()
    }
}
