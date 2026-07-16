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

enum TarotSpreadType: String, Codable, CaseIterable, Identifiable {
    case single, three

    var id: String { rawValue }
    var cardCount: Int { self == .single ? 1 : 3 }

    func title(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.single, .english): return "Single Card"
        case (.single, .traditionalChinese): return "單張牌"
        case (.three, .english): return "Three Cards"
        case (.three, .traditionalChinese): return "三張牌"
        }
    }

    func subtitle(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.single, .english): return "A message for this moment"
        case (.single, .traditionalChinese): return "一個此刻最需要的提醒"
        case (.three, .english): return "Past · Present · Future"
        case (.three, .traditionalChinese): return "過去・現在・未來"
        }
    }
}

/// Three-card positions (spec: Past / Present / Future) plus the
/// optional Guidance position for the 3+1 add-on card.
enum TarotPositionType: String, Codable, CaseIterable {
    case past, present, future, guidance

    func label(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.past, .english): return "Past"
        case (.past, .traditionalChinese): return "過去"
        case (.present, .english): return "Present"
        case (.present, .traditionalChinese): return "現在"
        case (.future, .english): return "Future"
        case (.future, .traditionalChinese): return "未來"
        case (.guidance, .english): return "Guidance"
        case (.guidance, .traditionalChinese): return "指引"
        }
    }

    static let threeCard: [TarotPositionType] = [.past, .present, .future]
}

struct TarotDrawnCard: Identifiable, Equatable {
    let card: TarotCardInfo
    let orientation: TarotOrientation
    let position: TarotPositionType?

    var id: String { card.id }
}

// MARK: - Draw engine

/// Unbiased draw over the full 78-card registry: no weighting, no
/// topic filtering, no duplicates within a reading, orientation
/// randomized independently at 50/50. The generic RNG parameter exists
/// only so tests can inject a seeded generator; production paths use
/// the system RNG.
struct TarotDrawEngine<G: RandomNumberGenerator> {
    private var rng: G
    let deck: [TarotCardInfo]

    init(rng: G, deck: [TarotCardInfo] = TarotRegistry.cards) {
        self.rng = rng
        self.deck = deck
    }

    mutating func draw(spread: TarotSpreadType) -> [TarotDrawnCard] {
        let positions: [TarotPositionType?] = spread == .three
            ? TarotPositionType.threeCard
            : [nil]
        let picked = deck.shuffled(using: &rng).prefix(spread.cardCount)
        return zip(picked, positions).map { card, position in
            TarotDrawnCard(card: card,
                           orientation: Bool.random(using: &rng) ? .upright : .reversed,
                           position: position)
        }
    }

    /// One extra Guidance Card from the cards not already in the
    /// reading — never a duplicate.
    mutating func drawGuidance(excluding drawn: [TarotDrawnCard]) -> TarotDrawnCard? {
        let used = Set(drawn.map(\.card.id))
        let remaining = deck.filter { !used.contains($0.id) }
        guard let card = remaining.shuffled(using: &rng).first else { return nil }
        return TarotDrawnCard(card: card,
                              orientation: Bool.random(using: &rng) ? .upright : .reversed,
                              position: .guidance)
    }
}

extension TarotDrawEngine where G == SystemRandomNumberGenerator {
    init() { self.init(rng: SystemRandomNumberGenerator()) }
}

// MARK: - Reading session

/// State for one reading, kept separate from presentation so a future
/// LLM interpretation provider receives the full context (question,
/// spread, cards, orientations, positions) defined in the spec.
struct TarotReadingSession: Equatable {
    var topic: TarotTopicType = .relationships
    var question: String = ""
    var spread: TarotSpreadType = .single
    var cards: [TarotDrawnCard] = []
    var guidanceCard: TarotDrawnCard?
    var createdAt: Date = .now

    var allCards: [TarotDrawnCard] {
        guidanceCard.map { cards + [$0] } ?? cards
    }

    var trimmedQuestion: String {
        question.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// One optional Guidance Card per reading — never a repeated
    /// "draw until satisfied" loop (redesign 2026-07-16).
    var canDrawGuidance: Bool {
        guidanceCard == nil && !cards.isEmpty
    }
}

// MARK: - Topics

/// The six approved topics (redesign 2026-07-16). Identifiers are
/// stable and language-independent; exact English labels are approved
/// copy — do not shorten or merge them.
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

    /// Topic-specific reflective suggestions. Finance prompts are
    /// reflective only — never investment advice or outcome promises.
    func suggestedQuestions(_ lang: AppLanguage) -> [String] {
        switch (self, lang) {
        case (.relationships, .english):
            return ["What deserves my attention in this relationship?",
                    "What direction could this relationship be moving toward?"]
        case (.relationships, .traditionalChinese):
            return ["我現在的關係，最需要我留意的是什麼？",
                    "這段關係接下來可能朝什麼方向發展？"]
        case (.career, .english):
            return ["Where should I focus my energy at work?",
                    "What deserves my attention in my career right now?"]
        case (.career, .traditionalChinese):
            return ["我接下來在工作上應該把重心放在哪裡？",
                    "現在的職涯狀態，最值得我注意的是什麼？"]
        case (.finance, .english):
            return ["What should I be mindful of in my financial decisions?",
                    "Should I take a more cautious or active approach financially?"]
        case (.finance, .traditionalChinese):
            return ["我現在在金錢決策上，最需要留意的是什麼？",
                    "接下來的財務方向，我應該更保守還是更積極？"]
        case (.growth, .english):
            return ["What inner lesson needs my attention right now?",
                    "What strength would be most valuable for me to develop?"]
        case (.growth, .traditionalChinese):
            return ["我最近最需要面對的內在課題是什麼？",
                    "現在的我，最值得培養的是什麼力量？"]
        case (.lifePath, .english):
            return ["How can I find the right pace for the days ahead?",
                    "What deserves more attention in my life right now?"]
        case (.lifePath, .traditionalChinese):
            return ["接下來的日子，我可以怎麼安排自己的步調？",
                    "現在的生活裡，有什麼值得我多留意？"]
        case (.other, .english):
            return ["What reminder do I need most right now?",
                    "What might the cards help me notice about this situation?"]
        case (.other, .traditionalChinese):
            return ["我現在最需要被提醒的是什麼？",
                    "對我正在思考的這件事，牌想讓我看見什麼？"]
        }
    }
}
