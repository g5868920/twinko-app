import XCTest
@testable import Twinko

/// Phase A step 10 protection: provider resolution, consent
/// persistence, live-response mapping, model state transitions, and
/// the Daily record's stored live reading. No network.
@MainActor
final class TarotLiveReadingTests: XCTestCase {

    // MARK: Helpers

    private func tempStore() -> JSONStore {
        JSONStore(directory: FileManager.default.temporaryDirectory
            .appendingPathComponent("live-tests-\(UUID().uuidString)"))
    }

    private func makeSession(daily: Bool = false) -> TarotReadingSession {
        let goldenCase = daily
            ? TarotGoldenCases.all.first { $0.contextKind == .dailyCheckIn }!
            : TarotGoldenCases.all.first!
        return goldenCase.session()!
    }

    private func validResponse(for session: TarotReadingSession,
                               safety: TarotLLMSafetyCategory = .none) -> TarotLLMResponse {
        TarotLLMResponse(
            positions: session.cards.map {
                .init(positionId: $0.positionID!.rawValue, cardId: $0.card.id,
                      interpretation: "這張牌可能反映一種值得留意的狀態。",
                      reflectionPrompt: "今天有什麼小事呼應了它？")
            },
            crossCardPatterns: "整體能量偏向轉換。",
            integratedSummary: "把牌放在一起看，是一個可以慢慢想的角度。",
            gentleNextStep: "先為自己安排一件小小的事。",
            safetyCategory: safety)
    }

    /// Request-counting stub: proves exactly how many provider
    /// requests were attempted (zero before/without consent). Can
    /// serve a queue of responses for the reframe follow-up.
    private final class CannedService: LLMServing, @unchecked Sendable {
        let provider: LLMProvider = .anthropic
        private(set) var requestCount = 0
        private var queue: [String]
        var error: LLMError?

        init(text: String, error: LLMError? = nil) {
            queue = [text]
            self.error = error
        }

        init(queue: [String]) { self.queue = queue }

        func complete(_ request: LLMRequest) async throws -> LLMResult {
            requestCount += 1
            if let error { throw error }
            let text = queue.count > 1 ? queue.removeFirst() : queue[0]
            return LLMResult(text: text, provider: provider, model: request.model,
                             inputTokens: 1000, outputTokens: 500,
                             latencySeconds: 0.1, finishReason: "end_turn")
        }
    }

    private func settle(_ model: TarotLiveReadingModel) async {
        for _ in 0..<2000 {
            if model.state != .loading { return }
            await Task.yield()
        }
    }

    // MARK: 1 — Resolver (fail-closed, no implicit preference)

    func testResolverFailsClosedWithoutAnExplicitChoice() {
        typealias R = TarotLiveProviderResolver
        // Single usable provider resolves without a preference.
        XCTAssertEqual(R.resolve(anthropicConfigured: true, openaiConfigured: false,
                                 preferred: nil, anthropicModel: nil,
                                 openaiModel: nil)?.provider, .anthropic)
        XCTAssertEqual(R.resolve(anthropicConfigured: true, openaiConfigured: false,
                                 preferred: nil, anthropicModel: nil,
                                 openaiModel: nil)?.model, "claude-sonnet-5")
        let openai = R.resolve(anthropicConfigured: false, openaiConfigured: true,
                               preferred: nil, anthropicModel: nil,
                               openaiModel: "gpt-test")
        XCTAssertEqual(openai?.provider, .openai)
        XCTAssertEqual(openai?.model, "gpt-test")

        // OpenAI without an explicit model id is never usable.
        XCTAssertNil(R.resolve(anthropicConfigured: false, openaiConfigured: true,
                               preferred: nil, anthropicModel: nil, openaiModel: nil))

        // BOTH keys + no explicit provider → FAIL CLOSED (no implicit
        // Anthropic preference while D-043 is open).
        XCTAssertNil(R.resolve(anthropicConfigured: true, openaiConfigured: true,
                               preferred: nil, anthropicModel: nil,
                               openaiModel: "gpt-test"))

        // Explicit preference is honored strictly — never substituted.
        XCTAssertEqual(R.resolve(anthropicConfigured: true, openaiConfigured: true,
                                 preferred: "openai", anthropicModel: nil,
                                 openaiModel: "gpt-test")?.provider, .openai)
        XCTAssertEqual(R.resolve(anthropicConfigured: true, openaiConfigured: true,
                                 preferred: "anthropic", anthropicModel: nil,
                                 openaiModel: "gpt-test")?.provider, .anthropic)
        XCTAssertNil(R.resolve(anthropicConfigured: true, openaiConfigured: false,
                               preferred: "openai", anthropicModel: nil,
                               openaiModel: nil),
                     "preferred provider unusable → fail closed, no substitution")
        XCTAssertNil(R.resolve(anthropicConfigured: true, openaiConfigured: true,
                               preferred: "something-else", anthropicModel: nil,
                               openaiModel: "gpt-test"),
                     "unknown preference value → fail closed")

        // Nothing configured → nil (mock-only build, unchanged).
        XCTAssertNil(R.resolve(anthropicConfigured: false, openaiConfigured: false,
                               preferred: nil, anthropicModel: nil, openaiModel: nil))
    }

    // MARK: 2 — Consent store

    func testConsentPersistsAcrossInstancesButDeclineDoesNot() {
        let store = tempStore()
        let first = LLMConsentStore(store: store)
        XCTAssertFalse(first.hasTarotConsent)
        first.acceptTarot()
        XCTAssertTrue(LLMConsentStore(store: store).hasTarotConsent,
                      "acceptance persists")

        // Declining is model state only — nothing written, and the
        // provider was NEVER contacted: zero requests, zero retries,
        // zero tokens.
        let declineStore = tempStore()
        let counting = CannedService(text: "should never be requested")
        let model = TarotLiveReadingModel(consent: LLMConsentStore(store: declineStore),
                                          serviceOverride: (counting, "test-model"),
                                          liveCapable: { true })
        model.prepare(session: makeSession(), lang: .traditionalChinese,
                      isRestored: false, restoredResponse: nil)
        XCTAssertEqual(model.state, .awaitingConsent)
        XCTAssertEqual(counting.requestCount, 0,
                       "no request may exist before the consent decision")
        model.consentDeclined()
        XCTAssertEqual(model.state, .fallback("declined"))
        XCTAssertEqual(counting.requestCount, 0,
                       "declined consent → zero provider requests")
        XCTAssertFalse(LLMConsentStore(store: declineStore).hasTarotConsent)
    }

    // MARK: 3 — Live provider mapping

    func testLiveProviderMapsFieldsAndFallsBackForGuidance() {
        let session = makeSession()
        let response = validResponse(for: session)
        let mock = MockTarotInterpretationProvider()
        let live = LiveTarotInterpretationProvider(response: response, fallback: mock)

        let drawn = session.cards[0]
        let interp = live.interpretation(for: drawn, in: session, lang: .traditionalChinese)
        XCTAssertEqual(interp.core, "這張牌可能反映一種值得留意的狀態。")
        XCTAssertEqual(interp.reflectionPrompt, "今天有什麼小事呼應了它？")
        XCTAssertTrue(interp.detail.isEmpty)
        let expectedKeywords = drawn.orientation == .upright
            ? drawn.card.keywordsUprightZh : drawn.card.keywordsReversedZh
        XCTAssertEqual(interp.keywords, expectedKeywords)

        XCTAssertEqual(live.synthesis(for: session, lang: .traditionalChinese),
                       "整體能量偏向轉換。")
        XCTAssertEqual(live.combinedSummary(for: session, lang: .traditionalChinese),
                       response.integratedSummary)
        XCTAssertEqual(live.twinkoMessage(for: session, lang: .traditionalChinese),
                       response.gentleNextStep)

        // A guidance card has no live position — deterministic fallback.
        var engine = TarotDrawEngine()
        var withGuidance = session
        withGuidance.guidanceCard = engine.drawGuidance(excluding: session.cards)
        let guidance = withGuidance.guidanceCard!
        XCTAssertEqual(live.interpretation(for: guidance, in: withGuidance,
                                           lang: .traditionalChinese),
                       mock.interpretation(for: guidance, in: withGuidance,
                                           lang: .traditionalChinese))
    }

    // MARK: 4 — Model state transitions

    func testModelStaysIdleWhenNotLiveCapable() {
        let model = TarotLiveReadingModel(consent: LLMConsentStore(store: tempStore()),
                                          liveCapable: { false })
        model.prepare(session: makeSession(), lang: .traditionalChinese,
                      isRestored: false, restoredResponse: nil)
        XCTAssertEqual(model.state, .idle, "mock-only builds behave exactly as before")
    }

    func testConsentGrantFetchesValidatesAndReportsLiveResponse() async {
        let session = makeSession()
        let response = validResponse(for: session)
        let json = String(data: try! JSONEncoder().encode(response), encoding: .utf8)!
        let consentStore = tempStore()
        let counting = CannedService(text: json)
        let model = TarotLiveReadingModel(
            consent: LLMConsentStore(store: consentStore),
            serviceOverride: (counting, "test-model"),
            liveCapable: { true })

        model.prepare(session: session, lang: .traditionalChinese,
                      isRestored: false, restoredResponse: nil)
        XCTAssertEqual(model.state, .awaitingConsent)
        XCTAssertEqual(counting.requestCount, 0,
                       "the network boundary sits behind the consent decision")

        var reported: TarotLLMResponse?
        model.consentGranted(session: session, lang: .traditionalChinese,
                             onLiveResponse: { reported = $0 })
        await settle(model)

        XCTAssertEqual(model.state, .live(response))
        XCTAssertEqual(reported, response)
        XCTAssertEqual(counting.requestCount, 1,
                       "accepted consent → exactly one initial request attempt")
        XCTAssertTrue(LLMConsentStore(store: consentStore).hasTarotConsent)
    }

    // MARK: 4b — post-draw discovery (second safety layer)

    func testPostDrawRestrictedCategoryOffersReframeAndNeverRenders() async {
        let session = makeSession()
        let consent = LLMConsentStore(store: tempStore())
        consent.acceptTarot()

        let restricted = validResponse(for: session, safety: .legalDecision)
        let json = String(data: try! JSONEncoder().encode(restricted), encoding: .utf8)!
        let service = CannedService(text: json)
        let model = TarotLiveReadingModel(consent: consent,
                                          serviceOverride: (service, "m"),
                                          liveCapable: { true })
        model.prepare(session: session, lang: .traditionalChinese,
                      isRestored: false, restoredResponse: nil)
        await settle(model)

        // No interpretation rendered, Guidance restricted, original
        // prohibited content discarded (only the category is kept).
        // Approving the offer starts a NEW reading at the flow level —
        // this model never refetches for the committed cards.
        XCTAssertEqual(model.state, .awaitingReframe(.legalDecision))
        XCTAssertTrue(model.restrictsGuidance)
        XCTAssertEqual(service.requestCount, 1)
        XCTAssertNotNil(TarotSafetyMatrix.reframeSuggestion(for: .legalDecision,
                                                            lang: .traditionalChinese))

        // Decline: labeled mock, zero further requests, no Guidance
        // bypass.
        model.declineReframe()
        XCTAssertEqual(model.state, .fallback("reframeDeclined"))
        XCTAssertTrue(model.restrictsGuidance,
                      "Guidance Card cannot bypass a declined reframe")
        XCTAssertEqual(service.requestCount, 1)
    }

    // MARK: 4c — pre-reading consent gate (correction 2)

    func testPreDrawConsentDeclineRendersLabeledMockWithZeroRequests() async {
        let session = makeSession()
        let counting = CannedService(text: "never requested")
        let model = TarotLiveReadingModel(consent: LLMConsentStore(store: tempStore()),
                                          serviceOverride: (counting, "m"),
                                          liveCapable: { true })
        XCTAssertTrue(model.isLiveCapable)
        XCTAssertFalse(model.hasConsent)

        // Not Now at the pre-reading gate → this reading is mock with
        // the fallback label and zero provider activity; the next
        // reading asks again.
        model.declineConsentOnce()
        model.prepare(session: session, lang: .traditionalChinese,
                      isRestored: false, restoredResponse: nil)
        XCTAssertEqual(model.state, .fallback("declined"))
        XCTAssertEqual(counting.requestCount, 0)
        XCTAssertFalse(model.hasConsent, "decline is never persisted as consent")

        // Continue with AI at the gate → consent persists; the next
        // prepared reading fetches directly (one request).
        let valid = validResponse(for: session)
        let json = String(data: try! JSONEncoder().encode(valid), encoding: .utf8)!
        let granted = CannedService(text: json)
        let store = tempStore()
        let model2 = TarotLiveReadingModel(consent: LLMConsentStore(store: store),
                                           serviceOverride: (granted, "m"),
                                           liveCapable: { true })
        model2.acceptConsent()
        XCTAssertTrue(LLMConsentStore(store: store).hasTarotConsent)
        model2.prepare(session: session, lang: .traditionalChinese,
                       isRestored: false, restoredResponse: nil)
        await settle(model2)
        XCTAssertEqual(model2.state, .live(valid))
        XCTAssertEqual(granted.requestCount, 1)
    }

    func testInvalidAndFailingResponsesFallBackToLabeledMock() async {
        let session = makeSession()
        let consent = LLMConsentStore(store: tempStore())
        consent.acceptTarot()

        let garbage = TarotLiveReadingModel(
            consent: consent,
            serviceOverride: (CannedService(text: "You will definitely win!"), "m"),
            liveCapable: { true })
        garbage.prepare(session: session, lang: .traditionalChinese,
                        isRestored: false, restoredResponse: nil)
        await settle(garbage)
        XCTAssertEqual(garbage.state, .fallback("invalidResponse"))

        let failing = TarotLiveReadingModel(
            consent: consent,
            serviceOverride: (CannedService(text: "", error: .timeout), "m"),
            liveCapable: { true })
        failing.prepare(session: session, lang: .traditionalChinese,
                        isRestored: false, restoredResponse: nil)
        await settle(failing)
        XCTAssertEqual(failing.state, .fallback("timeout"))
    }

    func testRestoredResponseIsReusedWithoutAnyFetch() {
        let session = makeSession(daily: true)
        let response = validResponse(for: session)
        let model = TarotLiveReadingModel(
            consent: LLMConsentStore(store: tempStore()),
            serviceOverride: (CannedService(text: "", error: .network), "m"),
            liveCapable: { true })
        model.prepare(session: session, lang: .traditionalChinese,
                      isRestored: true, restoredResponse: response)
        XCTAssertEqual(model.state, .live(response),
                       "stored reading renders with no new call")

        // Restored without a stored response stays on the plain mock.
        let plain = TarotLiveReadingModel(
            consent: LLMConsentStore(store: tempStore()),
            liveCapable: { true })
        plain.prepare(session: session, lang: .traditionalChinese,
                      isRestored: true, restoredResponse: nil)
        XCTAssertEqual(plain.state, .idle)
    }

    // MARK: 5 — Daily record stores the live reading

    func testDailyRecordAttachesLiveReadingAndDecodesLegacyRecords() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("daily-live-\(UUID().uuidString)")
        let store = JSONStore(directory: directory)
        let fixedNow = Date(timeIntervalSince1970: 1_790_000_000)
        let daily = DailyTarotStore(store: store, now: { fixedNow })

        let session = makeSession(daily: true)
        daily.recordCompletion(of: session)
        XCTAssertNotNil(daily.todayRecord)
        XCTAssertNil(daily.todayRecord?.liveReading)

        let response = validResponse(for: session)
        daily.attachLiveReading(response, for: session)
        XCTAssertEqual(daily.todayRecord?.liveReading, response)

        // Persisted and reloaded.
        let reloaded = DailyTarotStore(store: store, now: { fixedNow })
        XCTAssertEqual(reloaded.todayRecord?.liveReading, response)

        // Wrong session never attaches.
        let other = makeSession(daily: true)
        daily.attachLiveReading(validResponse(for: other), for: other)
        XCTAssertEqual(daily.todayRecord?.liveReading, response)

        // Legacy record JSON (no live_reading key) still decodes.
        var legacy = try JSONSerialization.jsonObject(
            with: Data(contentsOf: directory
                .appendingPathComponent("daily_tarot.json"))) as! [String: Any]
        legacy.removeValue(forKey: "liveReading")
        try JSONSerialization.data(withJSONObject: legacy)
            .write(to: directory.appendingPathComponent("daily_tarot.json"))
        let legacyStore = DailyTarotStore(store: store, now: { fixedNow })
        XCTAssertNotNil(legacyStore.todayRecord)
        XCTAssertNil(legacyStore.todayRecord?.liveReading)
    }
}
