import Foundation

// MARK: - Topics

enum TarotTopic: String, CaseIterable, Identifiable, Codable {
    case love = "愛情與關係"
    case career = "工作與財務"
    case growth = "自我成長"
    case general = "生活方向"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .love: return "heart.fill"
        case .career: return "briefcase.fill"
        case .growth: return "leaf.fill"
        case .general: return "signpost.right.fill"
        }
    }

    /// Perspective-first suggested questions (Content Spec §6): they
    /// invite understanding and agency, never certainty about others.
    var suggestedQuestions: [String] {
        switch self {
        case .love:
            return ["關於這段關係，我可以多理解什麼？",
                    "在人與人的相處裡，我最近可以留意什麼？"]
        case .career:
            return ["目前的工作狀態，我該把心力放在哪裡？",
                    "面對金錢的安排，哪種角度可能幫助我？"]
        case .growth:
            return ["最近的我，最需要被看見的是什麼？",
                    "有什麼視角可以幫助我往前走一步？"]
        case .general:
            return ["接下來的日子，我可以怎麼安排自己的步調？",
                    "現在的生活裡，有什麼值得我多留意？"]
        }
    }
}

enum TarotSpread: String, CaseIterable, Identifiable, Codable {
    case single = "單張牌"
    case three = "三張牌"

    var id: String { rawValue }
    var cardCount: Int { self == .single ? 1 : 3 }

    var subtitle: String {
        switch self {
        case .single: return "一個此刻最需要的提醒"
        case .three: return "情境・洞察・建議"
        }
    }
}

/// Approved three-card position labels (D-054).
enum TarotPosition: String, CaseIterable {
    case situation = "情境"
    case insight = "洞察"
    case advice = "建議"

    var frame: String {
        switch self {
        case .situation: return "「情境」看的是你現在身處的位置"
        case .insight: return "「洞察」想輕輕點亮的是"
        case .advice: return "「建議」給你的小方向是"
        }
    }
}

// MARK: - Cards

/// Original Twinko "star-language" deck — no reproduction of any
/// existing tarot art or text. Meanings are reflective and open, per
/// the safety framing rules (reflection / entertainment only).
struct TarotCard: Identifiable, Equatable {
    let id: Int
    let name: String
    let icon: String
    let coreMeaning: String
    let reflections: [TarotTopic: String]
    let gentleAction: String
}

enum TarotDeck {
    static let cards: [TarotCard] = [
        TarotCard(
            id: 1, name: "晨光", icon: "sunrise.fill",
            coreMeaning: "有些事情正在慢慢開始，就算現在還看不清楚形狀。",
            reflections: [
                .love: "一段關係裡，也許正有新的理解在萌芽。",
                .career: "工作上或許有個還很小的開端，值得你溫柔對待。",
                .growth: "你心裡可能有個剛醒來的念頭，別急著評價它。",
                .general: "生活裡有些微小的新開始，正等你注意到。"
            ],
            gentleAction: "今天可以為那個「剛開始的小事」做一件很小的事。"
        ),
        TarotCard(
            id: 2, name: "小星", icon: "star.fill",
            coreMeaning: "你本來就有自己的光，即使最近它看起來暗暗的。",
            reflections: [
                .love: "在關係裡，你的感受和需要一樣重要。",
                .career: "你的努力也許比你自己以為的更有份量。",
                .growth: "自我懷疑的時候，也別忘了曾經做到的事。",
                .general: "此刻的你，已經帶著足夠出發的東西。"
            ],
            gentleAction: "想一件你今年做過、讓自己有點驕傲的小事。"
        ),
        TarotCard(
            id: 3, name: "月亮湖", icon: "moon.stars.fill",
            coreMeaning: "情緒像湖面，會起波紋，也會自己慢慢靜下來。",
            reflections: [
                .love: "有些感覺還說不清楚，先允許它存在就好。",
                .career: "決定之前，也聽聽直覺想說什麼。",
                .growth: "情緒不是敵人，它在告訴你在乎什麼。",
                .general: "最近的心情起伏，也許值得被溫柔地看一看。"
            ],
            gentleAction: "睡前留三分鐘，問問自己：今天心裡最大的感覺是什麼？"
        ),
        TarotCard(
            id: 4, name: "雲朵", icon: "cloud.fill",
            coreMeaning: "不確定不代表壞事，雲後面常常還有天空。",
            reflections: [
                .love: "關係裡的模糊地帶，不一定要今天就有答案。",
                .career: "計畫還不明朗的時候，先照顧好眼前這一步。",
                .growth: "「還不知道」也是一種誠實的狀態。",
                .general: "有些事情需要時間變清楚，你可以慢慢來。"
            ],
            gentleAction: "把一件懸而未決的事寫下來，然後允許自己先放著。"
        ),
        TarotCard(
            id: 5, name: "燈塔", icon: "light.beacon.max.fill",
            coreMeaning: "你比想像中更知道自己的方向，只是需要安靜一點才聽得見。",
            reflections: [
                .love: "在關係裡，你真正想要的是什麼？答案可能已經在心裡。",
                .career: "回到最初的動機看看，它常常就是燈塔。",
                .growth: "別人的地圖不一定適合你的海。",
                .general: "喧鬧的時候，記得回頭找自己的光。"
            ],
            gentleAction: "找個安靜的五分鐘，問自己：我現在最想往哪裡去？"
        ),
        TarotCard(
            id: 6, name: "種子", icon: "leaf.fill",
            coreMeaning: "有些成長還在土裡，看不到不代表沒有發生。",
            reflections: [
                .love: "信任和理解需要時間慢慢長。",
                .career: "現在累積的東西，會在之後某個時刻冒出芽。",
                .growth: "改變常常是安靜的，急不來也不用急。",
                .general: "耐心一點，你已經種下的不會白費。"
            ],
            gentleAction: "為一件長期的事，做一個五分鐘就能完成的小步驟。"
        ),
        TarotCard(
            id: 7, name: "小橋", icon: "point.topleft.down.to.point.bottomright.curvepath.fill",
            coreMeaning: "你正在兩個階段之間，橋上的風景也值得看看。",
            reflections: [
                .love: "關係可能正在換一種相處的方式，過渡期是正常的。",
                .career: "轉換的路上，不需要急著證明什麼。",
                .growth: "離開熟悉的岸邊，本來就會有點不安。",
                .general: "過渡的日子，也是生活的一部分。"
            ],
            gentleAction: "跟自己說一句：「還在路上，沒關係。」"
        ),
        TarotCard(
            id: 8, name: "風箏", icon: "wind",
            coreMeaning: "有些事抓得太緊會飛不起來，鬆一點反而更穩。",
            reflections: [
                .love: "給彼此一點空間，關係會呼吸得更好。",
                .career: "不是每件事都需要你一個人扛著。",
                .growth: "放下不是放棄，是換一種力氣。",
                .general: "試著把其中一件事，交給時間看看。"
            ],
            gentleAction: "選一件最近抓得很緊的事，今天先鬆手一點點。"
        ),
        TarotCard(
            id: 9, name: "爐火", icon: "flame.fill",
            coreMeaning: "休息不是偷懶，是讓自己能繼續走的方式。",
            reflections: [
                .love: "累的時候，先照顧好自己，才有力氣照顧關係。",
                .career: "效率不會來自燃燒殆盡的自己。",
                .growth: "溫柔對待自己，也是一種練習。",
                .general: "今天的你，也許最需要的是好好休息。"
            ],
            gentleAction: "今晚提早十五分鐘放下手機，讓自己暖暖地休息。"
        ),
        TarotCard(
            id: 10, name: "山徑", icon: "mountain.2.fill",
            coreMeaning: "路看起來很長，但你只需要走好眼前這一段。",
            reflections: [
                .love: "關係的功課不用一次做完，一步一步來。",
                .career: "大目標拆小一點，今天只做今天的部分。",
                .growth: "進步常常藏在很小的重複裡。",
                .general: "與其擔心整條路，不如先把今天走穩。"
            ],
            gentleAction: "把最近的大煩惱，拆出一個今天做得到的小步驟。"
        ),
        TarotCard(
            id: 11, name: "鏡湖", icon: "circle.hexagongrid.fill",
            coreMeaning: "有時候答案不在外面，而在你怎麼看自己。",
            reflections: [
                .love: "對方像一面鏡子，照見的常常也是自己的期待。",
                .career: "先弄清楚自己在意什麼，選擇會容易一些。",
                .growth: "誠實地看自己，不帶批評，只是看見。",
                .general: "安靜下來的時候，聽聽自己心裡的聲音。"
            ],
            gentleAction: "問自己一個問題：這件事裡，我真正在意的是什麼？"
        ),
        TarotCard(
            id: 12, name: "星圖", icon: "sparkles",
            coreMeaning: "拉遠一點看，散落的點會連成你自己的星座。",
            reflections: [
                .love: "把時間拉長看，這段關係教會了你什麼？",
                .career: "每段經歷都是星圖上的一顆星，包括繞路的那些。",
                .growth: "你走過的路，正在慢慢連成屬於你的形狀。",
                .general: "偶爾抬頭看看全貌，再回來走今天的路。"
            ],
            gentleAction: "回想這一年，找出三個對你有意義的小時刻。"
        )
    ]
}

// MARK: - Deterministic draw

/// SplitMix64 — a tiny deterministic generator so the same question on
/// the same day always draws the same cards (D-054 determinism rule).
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

/// Stable across launches (unlike `hashValue`, which is seeded per
/// process).
func stableHash(_ text: String) -> UInt64 {
    var hash: UInt64 = 5381
    for byte in text.utf8 {
        hash = (hash &* 33) ^ UInt64(byte)
    }
    return hash
}

struct TarotDraw: Equatable {
    let topic: TarotTopic
    let question: String
    let spread: TarotSpread
    let cards: [TarotCard]
}

enum TarotDrawer {
    /// Draws `spread.cardCount` distinct cards, seeded by topic +
    /// question + spread + day so the ritual is deterministic.
    static func draw(topic: TarotTopic, question: String, spread: TarotSpread,
                     on date: Date = .now) -> TarotDraw {
        let day = ISO8601DateFormatter.dayKey(from: date)
        let seed = stableHash("\(topic.rawValue)|\(question)|\(spread.rawValue)|\(day)")
        var generator = SeededGenerator(seed: seed)
        let shuffled = TarotDeck.cards.shuffled(using: &generator)
        return TarotDraw(topic: topic, question: question, spread: spread,
                         cards: Array(shuffled.prefix(spread.cardCount)))
    }
}

private extension ISO8601DateFormatter {
    static func dayKey(from date: Date) -> String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
    }
}

// MARK: - Interpretation

enum TarotInterpreter {
    /// Copy blocks for the result screen. All framing is reflective —
    /// no certainty, no prediction, no advice in regulated domains.
    static func interpretation(for card: TarotCard, topic: TarotTopic,
                               position: TarotPosition?) -> String {
        var lines: [String] = []
        if let position {
            lines.append("\(position.frame)：")
        }
        lines.append(card.coreMeaning)
        if let reflection = card.reflections[topic] {
            lines.append(reflection)
        }
        return lines.joined(separator: "\n")
    }

    static func integratedSummary(for draw: TarotDraw) -> String? {
        guard draw.spread == .three, draw.cards.count == 3 else { return nil }
        let names = draw.cards.map(\.name)
        return "把三張牌放在一起看：「\(names[0])」說的是你此刻的位置，「\(names[1])」提醒你留意心裡的聲音，「\(names[2])」則給了一個溫柔的方向。它們不是答案，而是三個幫你想事情的角度——最後怎麼走，你自己的感覺永遠最重要。"
    }

    static let disclaimer = "塔羅內容僅供反思與娛樂，不代表確定的未來，也不是醫療、法律或財務建議。"
}
