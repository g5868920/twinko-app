import Foundation

// MARK: - Task 3: shared Tarot entry context (2026-07-19)
//
// One canonical entry-source + context-kind + entry-context model for
// every way into Tarot (direct, Chat, Home, Daily Check-in), plus the
// single context→draft conversion boundary and the minimal current-day
// Daily completion store. No cards, orientations, or sessions are ever
// created here; the Task 1 setup pipeline and Task 2 engine stay the
// only reading path.

/// Routing context only — never a spread recommendation, never
/// inferred from displayed text.
enum TarotEntrySource: String, Codable {
    case direct
    case chat
    case home
}

enum TarotEntryContextKind: String, Codable {
    case standard
    case dailyCheckIn
}

/// The shared handoff payload from Chat/Home into the Task 1 setup.
/// Carries only deterministic, already-available prototype context —
/// never full Chat history, raw messages, or fabricated fields. All
/// values stay editable in setup.
struct TarotEntryContext: Identifiable, Equatable {
    let id: UUID
    let source: TarotEntrySource
    let kind: TarotEntryContextKind
    let recommendedSpreadID: TarotSpreadID

    let draftQuestion: String?
    let decisionContext: String?
    let optionA: String?
    let optionB: String?
    let relationshipPersonLabel: String?

    /// Brief, optional, non-sensitive explanation of why this spread
    /// is suggested. Display-only — never a memory system.
    let contextSummary: String?

    init(id: UUID = UUID(), source: TarotEntrySource, kind: TarotEntryContextKind,
         recommendedSpreadID: TarotSpreadID, draftQuestion: String? = nil,
         decisionContext: String? = nil, optionA: String? = nil,
         optionB: String? = nil, relationshipPersonLabel: String? = nil,
         contextSummary: String? = nil) {
        self.id = id
        self.source = source
        self.kind = kind
        self.recommendedSpreadID = recommendedSpreadID
        self.draftQuestion = draftQuestion
        self.decisionContext = decisionContext
        self.optionA = optionA
        self.optionB = optionB
        self.relationshipPersonLabel = relationshipPersonLabel
        self.contextSummary = contextSummary
    }

    /// The Home Daily Tarot Check-in entry: canonical spread
    /// `holisticCheckInThree` (never a duplicate Daily ID), an
    /// editable default question, and the body/mind/inner-care
    /// explanation from the usage spec.
    static func daily(lang: AppLanguage) -> TarotEntryContext {
        TarotEntryContext(
            source: .home, kind: .dailyCheckIn,
            recommendedSpreadID: .holisticCheckInThree,
            draftQuestion: lang == .english
                ? "What do my body and mind most need today?"
                : "今天我的身心最需要什麼？",
            contextSummary: lang == .english
                ? "A daily check-in with your body, your thoughts and feelings, and the care you may need today."
                : "每天用三張牌，看看身體、情緒與思緒，以及今天最需要的內在照顧。")
    }
}

// MARK: - Shared context → draft boundary

extension TarotReadingDraft {
    /// The one conversion boundary from a contextual entry into the
    /// canonical Task 1 draft — used identically by Chat, Home, and
    /// Daily. Copies only supported values; fabricates nothing;
    /// creates no cards, no orientation, no session.
    init(context: TarotEntryContext) {
        self.init(intent: .quickReflection, refinement: nil,
                  spreadID: context.recommendedSpreadID)
        source = context.source
        contextKind = context.kind
        contextSummary = context.contextSummary
        if let question = context.draftQuestion { self.question = question }
        if let decision = context.decisionContext { decisionContext = decision }
        if let a = context.optionA { optionA = a }
        if let b = context.optionB { optionB = b }
        if let label = context.relationshipPersonLabel {
            relationshipPersonLabel = label
        }
    }
}

// MARK: - Daily completion record (current day only — no history)

/// Codable snapshot of one completed reading — just enough to reopen
/// the exact same result (identities, orientations, positions, reveal
/// state, optional Guidance Card). Never full Chat history, never a
/// past-readings collection, never image data.
struct TarotReadingSnapshot: Codable, Equatable {
    struct CardSnapshot: Codable, Equatable {
        let cardID: String
        let orientation: TarotOrientation
        let positionID: TarotPositionID?
        let role: TarotDrawRole
    }

    let sessionID: UUID
    let spreadID: TarotSpreadID
    let source: TarotEntrySource
    let kind: TarotEntryContextKind
    let topic: TarotTopicType
    let question: String
    let decisionContext: String?
    let optionA: String?
    let optionB: String?
    let relationshipPersonLabel: String?
    let cards: [CardSnapshot]
    let guidance: CardSnapshot?
    let revealedPositionIDs: [TarotPositionID]
    let createdAt: Date

    init(session: TarotReadingSession) {
        sessionID = session.id
        spreadID = session.spreadID
        source = session.source
        kind = session.contextKind
        topic = session.topic
        question = session.question
        decisionContext = session.decisionContext
        optionA = session.optionA
        optionB = session.optionB
        relationshipPersonLabel = session.relationshipPersonLabel
        cards = session.cards.map {
            CardSnapshot(cardID: $0.card.id, orientation: $0.orientation,
                         positionID: $0.positionID, role: $0.role)
        }
        guidance = session.guidanceCard.map {
            CardSnapshot(cardID: $0.card.id, orientation: $0.orientation,
                         positionID: $0.positionID, role: $0.role)
        }
        revealedPositionIDs = Array(session.revealedPositionIDs)
        createdAt = session.createdAt
    }

    /// Rebuilds the exact same completed session from the registry.
    /// Returns `nil` (fail-safe, no replacement cards) if any stored
    /// card is unavailable.
    func restoredSession() -> TarotReadingSession? {
        let registry = Dictionary(uniqueKeysWithValues: TarotRegistry.cards.map { ($0.id, $0) })
        var restored: [TarotDrawnCard] = []
        for snapshot in cards {
            guard let info = registry[snapshot.cardID] else { return nil }
            restored.append(TarotDrawnCard(card: info, orientation: snapshot.orientation,
                                           positionID: snapshot.positionID,
                                           role: snapshot.role))
        }
        guard restored.count == TarotSpreadLibrary.definition(for: spreadID).cardCount
        else { return nil }
        var session = TarotReadingSession(id: sessionID, spreadID: spreadID,
                                          topic: topic, question: question,
                                          decisionContext: decisionContext,
                                          optionA: optionA, optionB: optionB,
                                          relationshipPersonLabel: relationshipPersonLabel)
        session.source = source
        session.contextKind = kind
        session.cards = restored
        if let guidance, let info = registry[guidance.cardID] {
            session.guidanceCard = TarotDrawnCard(card: info,
                                                  orientation: guidance.orientation,
                                                  positionID: guidance.positionID,
                                                  role: guidance.role)
        }
        session.revealedPositionIDs = Set(revealedPositionIDs)
        session.revealSeen = true
        return session
    }
}

struct DailyTarotCompletionRecord: Codable, Equatable {
    let localDayKey: String
    let completedAt: Date
    var readingSnapshot: TarotReadingSnapshot
    /// Phase A step 10: the validated live reading, stored locally so
    /// reopening today's guidance shows the same text with no new
    /// call, no cost, no drift. Optional — records written before this
    /// field (or mock-only completions) keep decoding unchanged.
    var liveReading: TarotLLMResponse?
}

/// Current-day Daily Tarot completion state, persisted through the
/// existing JSONStore pattern (restart-safe, local only). Holds at
/// most one record — the current or most recent Daily completion —
/// never a history collection. The day key is re-evaluated on every
/// read, so a new local day naturally returns to the uncompleted
/// state with no timers or polling.
final class DailyTarotStore: ObservableObject {
    static let fileName = "daily_tarot"

    @Published private(set) var record: DailyTarotCompletionRecord?

    private let store: JSONStore
    private let calendar: Calendar
    private let now: () -> Date

    init(store: JSONStore = JSONStore(),
         calendar: Calendar = .autoupdatingCurrent,
         now: @escaping () -> Date = { .now }) {
        self.store = store
        self.calendar = calendar
        self.now = now
        record = store.load(DailyTarotCompletionRecord.self, from: Self.fileName)
    }

    /// Stable local-day identity from local calendar components (not a
    /// UTC string comparison).
    func localDayKey(for date: Date) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d",
                      parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    /// Today's completed Daily reading, if any (re-evaluated per read).
    var todayRecord: DailyTarotCompletionRecord? {
        guard let record, record.localDayKey == localDayKey(for: now()) else {
            return nil
        }
        return record
    }

    var isTodayCompleted: Bool { todayRecord != nil }

    /// Records the completed Daily base reading. Only `dailyCheckIn`
    /// sessions count, and a second same-day completion is ignored —
    /// never silently replaced.
    func recordCompletion(of session: TarotReadingSession) {
        guard session.contextKind == .dailyCheckIn,
              session.cards.count == session.definition.cardCount,
              !session.cards.isEmpty,
              todayRecord == nil else { return }
        let newRecord = DailyTarotCompletionRecord(
            localDayKey: localDayKey(for: now()),
            completedAt: now(),
            readingSnapshot: TarotReadingSnapshot(session: session))
        record = newRecord
        store.save(newRecord, as: Self.fileName)
    }

    /// A later Guidance Card updates the same current-day record — it
    /// never creates a second completion.
    func attachGuidance(from session: TarotReadingSession) {
        guard session.contextKind == .dailyCheckIn,
              var current = todayRecord,
              current.readingSnapshot.sessionID == session.id else { return }
        current.readingSnapshot = TarotReadingSnapshot(session: session)
        record = current
        store.save(current, as: Self.fileName)
    }

    /// Stores the validated live reading on the same current-day
    /// record (local only), so today's reopen renders identical text
    /// without a new provider call.
    func attachLiveReading(_ response: TarotLLMResponse,
                           for session: TarotReadingSession) {
        guard session.contextKind == .dailyCheckIn,
              var current = todayRecord,
              current.readingSnapshot.sessionID == session.id else { return }
        current.liveReading = response
        record = current
        store.save(current, as: Self.fileName)
    }

    /// The restored completed session for `View Today's Guidance`, or
    /// `nil` when no valid current-day record exists (fail-safe — no
    /// redraw, no replacement cards).
    func restoredTodaySession() -> TarotReadingSession? {
        todayRecord?.readingSnapshot.restoredSession()
    }
}
