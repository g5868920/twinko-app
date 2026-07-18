import Foundation

// MARK: - Core reading types

enum TarotOrientation: String, Codable, CaseIterable {
    case upright, reversed

    func label(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.upright, .english): return "Upright"
        case (.upright, .traditionalChinese): return "正位"
        case (.reversed, .english): return "Reversed"
        case (.reversed, .traditionalChinese): return "逆位"
        }
    }
}

/// Whether a drawn card fills a numbered spread position or is the one
/// optional Guidance Card (which is never a numbered position).
enum TarotDrawRole: String, Codable {
    case basePosition
    case guidance
}

/// One drawn card: identity, orientation, and its canonical position
/// assignment — all fixed at draw time and never re-derived from
/// rendering or animation state (Task 2 §8/§11).
struct TarotDrawnCard: Identifiable, Equatable {
    let card: TarotCardInfo
    let orientation: TarotOrientation
    let positionID: TarotPositionID?
    let role: TarotDrawRole

    var id: String { card.id }
}

// MARK: - Draw engine

/// Unbiased draw over the full 78-card registry: no weighting, no
/// topic filtering, no duplicates within a reading, orientation
/// randomized independently at 50/50 and assigned exactly once. Card
/// identity comes only from this engine — never from choreography or
/// animation timing. The generic RNG parameter exists only so tests
/// can inject a seeded generator; production paths use the system RNG.
struct TarotDrawEngine<G: RandomNumberGenerator> {
    private var rng: G
    let deck: [TarotCardInfo]

    init(rng: G, deck: [TarotCardInfo] = TarotRegistry.cards) {
        self.rng = rng
        self.deck = deck
    }

    /// Draws the base reading for any canonical MVP spread: exactly
    /// one unique card per canonical position, assigned in canonical
    /// position order (Task 2 §12).
    mutating func draw(spreadID: TarotSpreadID) -> [TarotDrawnCard] {
        let definition = TarotSpreadLibrary.definition(for: spreadID)
        let picked = deck.shuffled(using: &rng).prefix(definition.cardCount)
        return zip(picked, definition.positionIDs).map { card, position in
            TarotDrawnCard(card: card,
                           orientation: Bool.random(using: &rng) ? .upright : .reversed,
                           positionID: position,
                           role: .basePosition)
        }
    }

    /// One extra Guidance Card from the cards not already in the
    /// reading — never a duplicate, never a numbered position.
    mutating func drawGuidance(excluding drawn: [TarotDrawnCard]) -> TarotDrawnCard? {
        let used = Set(drawn.map(\.card.id))
        let remaining = deck.filter { !used.contains($0.id) }
        guard let card = remaining.shuffled(using: &rng).first else { return nil }
        return TarotDrawnCard(card: card,
                              orientation: Bool.random(using: &rng) ? .upright : .reversed,
                              positionID: nil,
                              role: .guidance)
    }
}

extension TarotDrawEngine where G == SystemRandomNumberGenerator {
    init() { self.init(rng: SystemRandomNumberGenerator()) }
}

// MARK: - Reading session

/// The one active reading source of truth (Task 2 §8): identity,
/// validated pre-reading inputs, drawn cards, per-position reveal
/// state, and the optional Guidance Card all live here — never in
/// stage-local view `@State`. A new reading is a new session value
/// (new `id`); ordinary view recreation and Back navigation reuse the
/// same value and therefore can never redraw, reorient, or re-hide a
/// reading. Kept in-memory only, matching the app's current
/// live-session ownership pattern (no reading history).
struct TarotReadingSession: Equatable, Identifiable {
    let id: UUID
    let spreadID: TarotSpreadID
    /// Interpretation flavor only (deterministically derived from the
    /// validated intent — never free-text classification).
    var topic: TarotTopicType
    var intent: TarotIntent?
    var question: String
    var decisionContext: String?
    var optionA: String?
    var optionB: String?
    var relationshipPersonLabel: String?

    var cards: [TarotDrawnCard] = []
    var guidanceCard: TarotDrawnCard?
    /// Per-position reveal state, keyed by stable canonical position
    /// IDs — session-owned so navigation, view recreation, and
    /// language switches never re-hide a revealed card (§15).
    var revealedPositionIDs: Set<TarotPositionID> = []
    /// Whether this reading's base cards were all revealed once
    /// (drives the completed-return reveal presentation).
    var revealSeen = false
    var createdAt: Date = .now

    init(id: UUID = UUID(), spreadID: TarotSpreadID = .singleCard,
         topic: TarotTopicType = .other, intent: TarotIntent? = nil,
         question: String = "", decisionContext: String? = nil,
         optionA: String? = nil, optionB: String? = nil,
         relationshipPersonLabel: String? = nil) {
        self.id = id
        self.spreadID = spreadID
        self.topic = topic
        self.intent = intent
        self.question = question
        self.decisionContext = decisionContext
        self.optionA = optionA
        self.optionB = optionB
        self.relationshipPersonLabel = relationshipPersonLabel
    }

    /// Creates the active session from a validated Task 1 launch
    /// request — inputs are copied verbatim (never re-derived, never
    /// re-recommended), and the manually selected spread wins.
    init(request: TarotReadingLaunchRequest) {
        let draft = request.draft
        self.init(spreadID: draft.selectedSpreadID,
                  topic: Self.topicFlavor(for: draft),
                  intent: draft.intent,
                  question: draft.trimmedQuestion,
                  decisionContext: draft.trimmedDecisionContext.isEmpty
                      ? nil : draft.trimmedDecisionContext,
                  optionA: draft.trimmedOptionA.isEmpty ? nil : draft.trimmedOptionA,
                  optionB: draft.trimmedOptionB.isEmpty ? nil : draft.trimmedOptionB,
                  relationshipPersonLabel: draft.trimmedPersonLabel.isEmpty
                      ? nil : draft.trimmedPersonLabel)
    }

    /// Deterministic intent→topic mapping used only to keep the
    /// existing interpretation/meditation flavor copy meaningful. No
    /// question-text classification (Task 2 §5).
    static func topicFlavor(for draft: TarotReadingDraft) -> TarotTopicType {
        switch draft.intent {
        case .romanticRelationship: return .relationships
        case .understandMyself: return .growth
        case .nextStepOrDirection: return .lifePath
        default: return .other
        }
    }

    var definition: TarotSpreadDefinition {
        TarotSpreadLibrary.definition(for: spreadID)
    }

    var allCards: [TarotDrawnCard] {
        guidanceCard.map { cards + [$0] } ?? cards
    }

    var trimmedQuestion: String {
        question.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// One optional Guidance Card per reading — never a repeated
    /// "draw until satisfied" loop.
    var canDrawGuidance: Bool {
        guidanceCard == nil && !cards.isEmpty
    }

    /// Marks a base position revealed (idempotent — repeated flips or
    /// rapid taps can never overdraw or reset state).
    mutating func markRevealed(_ positionID: TarotPositionID?) {
        guard let positionID else { return }
        revealedPositionIDs.insert(positionID)
    }
}

// MARK: - Topics

/// The six approved topics (redesign 2026-07-16). Since the Task 2
/// intent-first flow replaced topic selection, the topic now only
/// flavors interpretation/meditation copy (derived deterministically
/// from the validated intent). Identifiers are stable and
/// language-independent.
enum TarotTopicType: String, Codable, CaseIterable, Identifiable {
    case relationships, career, finance, growth, lifePath, other

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .relationships: return "heart.fill"
        case .career: return "briefcase.fill"
        case .finance: return "dollarsign.circle.fill"
        case .growth: return "leaf.fill"
        case .lifePath: return "signpost.right.fill"
        case .other: return "sparkles"
        }
    }

    func label(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.relationships, .english): return "Relationships"
        case (.relationships, .traditionalChinese): return "愛情與關係"
        case (.career, .english): return "Career"
        case (.career, .traditionalChinese): return "工作與事業"
        case (.finance, .english): return "Finance"
        case (.finance, .traditionalChinese): return "財務與投資"
        case (.growth, .english): return "Growth"
        case (.growth, .traditionalChinese): return "自我成長"
        case (.lifePath, .english): return "Life Path"
        case (.lifePath, .traditionalChinese): return "生活方向"
        case (.other, .english): return "Other"
        case (.other, .traditionalChinese): return "其他"
        }
    }
}
