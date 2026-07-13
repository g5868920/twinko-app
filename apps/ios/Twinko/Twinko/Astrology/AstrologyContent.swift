import Foundation

/// One day of 每日星座 content for one sign. Everything is selected
/// deterministically from local template pools — the same sign on the
/// same day always reads the same (D-054); there is no live astrological
/// calculation and no remote content.
struct DailyAstrology: Equatable {
    let sign: ZodiacSign
    let date: Date
    let overall: String
    let love: String
    let career: String
    let finance: String
    let luckyNumber: Int
    let luckyColor: String
    let luckySign: ZodiacSign
    let luckyItem: String
}

enum AstrologyContent {
    // Possibility language only — no guaranteed gains, no absolute
    // relationship outcomes, no health or fear framing (safety §5, §11).

    private static let overallPool = [
        "今天的節奏可能比較適合慢慢來，把一件事做完就很好。",
        "或許會遇到一些小小的變化，保持彈性會讓你自在一些。",
        "今天也許適合整理：整理桌面、整理想法，或整理心情。",
        "你可能會比平常更敏銳，聽聽直覺，也記得查證。",
        "適合把注意力放回自己身上的一天，先照顧好自己的步調。",
        "今天的能量也許適合完成，而不是開始太多新的事情。",
        "可能會有一個溫暖的小片刻，記得留意並好好收下。"
    ]

    private static let lovePool = [
        "關係裡的小誤會，也許用一句直接卻溫柔的話就能化開。",
        "今天可能適合傾聽多於表達，對方想說的比你以為的多。",
        "單身的你，或許會在熟悉的場合注意到不一樣的細節。",
        "把感謝說出口，可能比默默放在心裡更有力量。",
        "相處中留一點空間，感情反而可能流動得更自然。",
        "一段訊息、一通電話，也許就能讓某段關係暖起來。"
    ]

    private static let careerPool = [
        "工作上可能適合把大任務拆小，一步一步反而更快。",
        "今天的會議或討論，先聽完再回應，可能對你更有利。",
        "有些進度需要等別人，不妨先把自己能做的部分做好。",
        "或許是整理待辦清單的好時機，把腦袋清出空間。",
        "同事的一句話可能帶來靈感，保持開放的耳朵。",
        "別急著證明什麼，把品質顧好，自然會被看見。"
    ]

    private static let financePool = [
        "今天也許適合檢視一下最近的花費，小小的調整就夠了。",
        "衝動購物的念頭出現時，先放進購物車冷靜一天看看。",
        "財務上求穩不求快，今天可能不適合倉促的決定。",
        "或許可以為自己留一筆小小的「安心錢」，慢慢累積。",
        "跟錢有關的資訊，記得多看一眼來源再判斷。",
        "把固定支出看清楚，可能會發現可以鬆一口氣的空間。"
    ]

    private static let colorPool = [
        "暖金色", "薰衣草紫", "奶油白", "湖水綠", "玫瑰粉",
        "天空藍", "杏桃橘", "月光銀", "森林綠", "莓果紅"
    ]

    private static let itemPool = [
        "一杯溫熱的飲料", "小星星飾品", "喜歡的筆", "柔軟的圍巾或外套",
        "一首熟悉的歌", "便條紙", "香香的護手霜", "一本隨身小書",
        "耳機", "口袋裡的小點心"
    ]

    /// Deterministic daily content for a sign.
    static func daily(for sign: ZodiacSign, on date: Date = .now) -> DailyAstrology {
        let day = dayKey(for: date)
        func pick(_ pool: [String], _ field: String) -> String {
            let index = Int(stableHash("\(sign.rawValue)|\(day)|\(field)") % UInt64(pool.count))
            return pool[index]
        }
        let luckyNumber = Int(stableHash("\(sign.rawValue)|\(day)|number") % 99) + 1
        let signIndex = Int(stableHash("\(sign.rawValue)|\(day)|sign") % UInt64(ZodiacSign.allCases.count))

        return DailyAstrology(
            sign: sign,
            date: date,
            overall: pick(overallPool, "overall"),
            love: pick(lovePool, "love"),
            career: pick(careerPool, "career"),
            finance: pick(financePool, "finance"),
            luckyNumber: luckyNumber,
            luckyColor: pick(colorPool, "color"),
            luckySign: ZodiacSign.allCases[signIndex],
            luckyItem: pick(itemPool, "item")
        )
    }

    static let disclaimer = "每日星座內容僅供反思與娛樂，不代表保證的結果，也不是醫療、法律或財務建議。"

    private static func dayKey(for date: Date) -> String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
    }
}
