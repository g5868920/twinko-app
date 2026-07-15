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
        case (.single, .english): return "One reminder for this moment"
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
    var topic: TarotTopicType = .general
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
}

// MARK: - Topics

enum TarotTopicType: String, Codable, CaseIterable, Identifiable {
    case love, career, growth, general

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .love: return "heart.fill"
        case .career: return "briefcase.fill"
        case .growth: return "leaf.fill"
        case .general: return "signpost.right.fill"
        }
    }

    func label(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.love, .english): return "Love & Relationships"
        case (.love, .traditionalChinese): return "愛情與關係"
        case (.career, .english): return "Career & Finance"
        case (.career, .traditionalChinese): return "工作與財務"
        case (.growth, .english): return "Personal Growth"
        case (.growth, .traditionalChinese): return "自我成長"
        case (.general, .english): return "Life Path"
        case (.general, .traditionalChinese): return "生活方向"
        }
    }

    func suggestedQuestions(_ lang: AppLanguage) -> [String] {
        switch (self, lang) {
        case (.love, .english):
            return ["What can I understand better about this relationship?",
                    "What is worth noticing in how I connect with others?"]
        case (.love, .traditionalChinese):
            return ["關於這段關係，我可以多理解什麼？",
                    "在人與人的相處裡，我最近可以留意什麼？"]
        case (.career, .english):
            return ["Where should I focus my energy at work right now?",
                    "What perspective could help with my financial choices?"]
        case (.career, .traditionalChinese):
            return ["目前的工作狀態，我該把心力放在哪裡？",
                    "面對金錢的安排，哪種角度可能幫助我？"]
        case (.growth, .english):
            return ["What part of me most needs to be seen right now?",
                    "What perspective could help me take one step forward?"]
        case (.growth, .traditionalChinese):
            return ["最近的我，最需要被看見的是什麼？",
                    "有什麼視角可以幫助我往前走一步？"]
        case (.general, .english):
            return ["How can I pace myself in the days ahead?",
                    "What in my life deserves a little more attention?"]
        case (.general, .traditionalChinese):
            return ["接下來的日子，我可以怎麼安排自己的步調？",
                    "現在的生活裡，有什麼值得我多留意？"]
        }
    }
}
