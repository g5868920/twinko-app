import Foundation

// MARK: - Provider boundary

/// Clean boundary for daily horoscope generation. The prototype ships
/// `MockHoroscopeProvider`; production later swaps in an LLM-backed
/// provider that generates structured contextual output (sign + date +
/// locale + schema + tone + safety rules) — never one permanent
/// hardcoded paragraph per sign. UI code only talks to this protocol
/// (through the cache).
protocol HoroscopeProviding: Sendable {
    func daily(for sign: ZodiacSign, on date: Date, lang: AppLanguage) async throws -> DailyHoroscope
}

// MARK: - Mock provider

/// Deterministic local fixtures: content is composed from structured,
/// score-coherent pools selected by (local date, sign, locale) — one
/// stable valid result per sign per day per locale, in possibility
/// language only. All copy lives here, never in views.
struct MockHoroscopeProvider: HoroscopeProviding {

    func daily(for sign: ZodiacSign, on date: Date = .now,
               lang: AppLanguage) async throws -> DailyHoroscope {
        let day = HoroscopeDateKey.key(for: date)
        func h(_ field: String) -> UInt64 {
            stableHash("\(sign.canonicalID)|\(day)|\(lang.rawValue)|\(field)")
        }
        func pick<T>(_ pool: [T], _ field: String) -> T {
            pool[Int(h(field) % UInt64(pool.count))]
        }
        func score(_ field: String) -> Int { Int(h(field) % 5) + 1 }

        func dimension(_ kind: HoroscopeDimensionKind) -> HoroscopeDimension {
            let s = score("score-\(kind.rawValue)")
            let band: ContentBand = s <= 2 ? .gentle : (s == 3 ? .steady : .bright)
            let pair = pick(Self.content[kind]![band]![lang]!, "copy-\(kind.rawValue)")
            return HoroscopeDimension(score: s, summary: pair.0, detail: pair.1)
        }

        let luckySignIndex = Int(h("lucky-sign") % UInt64(ZodiacSign.allCases.count))
        let result = DailyHoroscope(
            dateKey: day,
            locale: lang.rawValue,
            zodiacID: sign.canonicalID,
            headline: pick(Self.headlines[lang]!, "headline"),
            overall: dimension(.overall),
            love: dimension(.love),
            career: dimension(.career),
            wealth: dimension(.wealth),
            lucky: LuckyDetails(
                number: Int(h("lucky-number") % 99) + 1,
                color: pick(Self.colors, "lucky-color"),
                zodiacID: ZodiacSign.allCases[luckySignIndex].canonicalID,
                item: pick(Self.items[lang]!, "lucky-item")
            ),
            twinkoMessage: pick(Self.twinkoMessages[lang]!, "twinko")
        )
        return result
    }

    // MARK: Fixture pools

    private enum ContentBand { case gentle, steady, bright }

    private static let headlines: [AppLanguage: [String]] = [
        .traditionalChinese: [
            "今天適合把注意力收回自己身上。",
            "小步前進，也是一種好好生活。",
            "留一點空間給突然出現的好事。",
            "先安頓好心情，事情會跟著順。",
            "今天的重點是誠實面對自己的節奏。",
            "把一件小事做好，就很足夠了。",
        ],
        .english: [
            "Today is a good day to turn your attention inward.",
            "Small steps forward still count as living well.",
            "Leave a little room for unexpected good things.",
            "Settle your heart first and the rest may follow.",
            "Being honest about your own pace matters most today.",
            "Doing one small thing well is more than enough.",
        ],
    ]

    // (summary, detail) pairs per dimension per score band per language.
    private static let content: [HoroscopeDimensionKind: [ContentBand: [AppLanguage: [(String, String)]]]] = [
        .overall: [
            .gentle: [
                .traditionalChinese: [
                    ("節奏偏慢，給自己多一點餘裕。",
                     "今天的能量比較適合收，不適合衝。把待辦清單砍一半，留下真正重要的，其他的允許自己晚一點再說。"),
                    ("有些事急不來，先照顧好自己。",
                     "當事情推不動的時候，也許不是你的問題，而是時機還沒到。先把自己的狀態顧好，等風向轉過來。"),
                ],
                .english: [
                    ("A slower rhythm — give yourself extra room today.",
                     "Today's energy favors gathering in rather than pushing forward. Cut your to-do list in half, keep what truly matters, and let the rest wait without guilt."),
                    ("Some things can't be rushed; care for yourself first.",
                     "When things won't move, it may be timing rather than you. Tend to your own state first and let the wind change on its own."),
                ],
            ],
            .steady: [
                .traditionalChinese: [
                    ("整體平穩，適合按部就班。",
                     "沒有特別的大起伏，反而是把日常過好的好日子。照著原本的計畫走，穩穩地完成幾件小事。"),
                    ("平常心就是今天最好的策略。",
                     "今天不需要特別用力，維持自己熟悉的節奏就好。把注意力放在眼前的事，累積本身就是收穫。"),
                ],
                .english: [
                    ("A steady day — one step at a time works well.",
                     "No big waves today, which makes it a good day for ordinary life. Follow your existing plan and quietly finish a few small things."),
                    ("An even, unhurried mind is today's best strategy.",
                     "There is no need to push hard today. Keep your familiar rhythm, focus on what is in front of you, and let steady effort accumulate."),
                ],
            ],
            .bright: [
                .traditionalChinese: [
                    ("整體節奏穩定，適合處理重要事項。",
                     "今天的能量有助於你整理優先順序。先完成最重要的一件事，再處理次要選項，會比同時推進所有事情更輕鬆。"),
                    ("能量充足，想做的事可以往前推一步。",
                     "狀態不錯的日子，適合處理平常會拖延的事。趁著這股順勢，把想開始的事情往前推進一小步。"),
                ],
                .english: [
                    ("A stable rhythm — good for handling what matters.",
                     "Today's energy helps you sort priorities. Finish the most important thing first, then the rest — easier than pushing everything at once."),
                    ("Plenty of energy — nudge your plans one step ahead.",
                     "On a day when you feel this steady, tackle something you usually postpone. Ride the momentum and move one small step forward."),
                ],
            ],
        ],
        .love: [
            .gentle: [
                .traditionalChinese: [
                    ("感情裡先聽，再說。",
                     "今天的對話容易有小誤會。先讓對方把話說完，確認你聽懂了，再表達自己，很多摩擦就能繞過去。"),
                    ("給彼此一點安靜的空間。",
                     "不是每個沉默都需要填滿。今天允許關係喘口氣，有時候安靜地待在一起，比說很多話更靠近。"),
                ],
                .english: [
                    ("In love, listen first and speak second today.",
                     "Small misunderstandings come easily today. Let the other person finish, confirm you understood, then share your side — much friction can be avoided."),
                    ("Give each other a little quiet space.",
                     "Not every silence needs filling. Let the relationship breathe today; sometimes sitting quietly together brings you closer than many words."),
                ],
            ],
            .steady: [
                .traditionalChinese: [
                    ("坦白但溫柔的溝通更有幫助。",
                     "不要急著猜測對方的想法。清楚表達自己的感受，也留一點空間聽對方說完。"),
                    ("關係平穩，適合累積小小的好感。",
                     "今天適合做些平常的小事：一句問候、一杯飲料、一段一起走的路。感情常常就是這樣慢慢變厚的。"),
                ],
                .english: [
                    ("Honest but gentle communication helps most today.",
                     "Don't rush to guess what the other person is thinking. Say clearly how you feel, and leave space to hear them out fully."),
                    ("A calm day — good for small gestures of warmth.",
                     "Ordinary kindness goes far today: a greeting, a shared drink, a walk together. Affection often thickens through exactly these small things."),
                ],
            ],
            .bright: [
                .traditionalChinese: [
                    ("心意容易被接住，適合表達。",
                     "今天說出口的溫柔比較容易被聽見。想感謝的、想在意的、想約的，都可以自然地說出來看看。"),
                    ("關係裡有暖流，值得好好收下。",
                     "留意身邊人釋出的小小善意，別急著客氣地擋回去。大方接受，也是一種給對方的溫柔。"),
                ],
                .english: [
                    ("Feelings land softly today — a good day to express them.",
                     "Tenderness spoken today is more likely to be heard. Gratitude, care, an invitation — let them out naturally and see what happens."),
                    ("A warm current runs through your connections today.",
                     "Notice the small kindnesses people offer and don't wave them away politely. Receiving warmly is its own kind of tenderness."),
                ],
            ],
        ],
        .career: [
            .gentle: [
                .traditionalChinese: [
                    ("工作求穩，先把手上的事收尾。",
                     "今天不太適合開新戰場。把進行中的任務收個乾淨的尾，比多接一件事更能帶來踏實感。"),
                    ("溝通放慢半拍，避免會錯意。",
                     "訊息和信件今天容易被讀歪。重要的內容多看一次再送出，當面能講清楚的就別只用文字。"),
                ],
                .english: [
                    ("Aim for steadiness — wrap up what's in your hands.",
                     "Today isn't ideal for opening new fronts. Bringing a current task to a clean finish will feel more solid than taking on one more thing."),
                    ("Slow your communication half a beat to avoid crossed wires.",
                     "Messages are easily misread today. Reread anything important before sending, and speak in person when clarity really matters."),
                ],
            ],
            .steady: [
                .traditionalChinese: [
                    ("適合整理與規劃的一天。",
                     "把模糊的問題整理成具體步驟，先確認目標，再分配時間與資源，之後的路會好走很多。"),
                    ("按原定計畫走，就是好表現。",
                     "今天不需要驚人的成果，把答應過的事準時做到，本身就是專業。穩定會被看見。"),
                ],
                .english: [
                    ("A good day for sorting and planning.",
                     "Turn vague problems into concrete steps: confirm the goal first, then assign time and resources. The road ahead gets much smoother."),
                    ("Following the plan you already made is good work.",
                     "No dazzling results are needed today. Delivering what you promised, on time, is itself professionalism — steadiness gets noticed."),
                ],
            ],
            .bright: [
                .traditionalChinese: [
                    ("適合推進需要判斷與協調的工作。",
                     "今天的思路清楚，適合處理需要拿主意的事。需要跨部門或跨角色的協調，也比平常容易談得順。"),
                    ("表現容易被看見，把握發揮的機會。",
                     "如果有需要報告、提案或表達想法的場合，今天值得主動一點。準備好的東西，就大方讓它被看見。"),
                ],
                .english: [
                    ("Good momentum for work needing judgment and coordination.",
                     "Your thinking is clear today — a good time for decisions. Cross-team coordination also flows more easily than usual."),
                    ("Your work is easily seen today — step forward.",
                     "If there's a report, a pitch, or an idea to voice, today rewards initiative. Let what you've prepared be seen, generously."),
                ],
            ],
        ],
        .wealth: [
            .gentle: [
                .traditionalChinese: [
                    ("購買前多停一下，避免情緒性消費。",
                     "今天不適合因為焦慮或衝動做大額決定。先把需求和想要分開，再決定是否行動。"),
                    ("財務保守一點，讓自己安心。",
                     "跟錢有關的選擇，今天以「不後悔」為原則。可以先記下想買的東西，過兩天再回頭看還想不想要。"),
                ],
                .english: [
                    ("Pause before purchases — avoid emotional spending today.",
                     "Today isn't the day for big decisions driven by anxiety or impulse. Separate needs from wants first, then decide whether to act."),
                    ("A conservative money day keeps your mind at ease.",
                     "For money choices today, 'no regrets' is the rule. Note down what you want to buy and check in two days whether you still want it."),
                ],
            ],
            .steady: [
                .traditionalChinese: [
                    ("財務平穩，適合檢視固定支出。",
                     "沒有大進大出的一天，正好回頭看看訂閱、帳單這些固定支出，小小的調整累積起來很可觀。"),
                    ("記帳或盤點，會帶來安全感。",
                     "花十分鐘看看這個月的收支，不是為了焦慮，而是為了心裡有數。清楚，就是一種底氣。"),
                ],
                .english: [
                    ("Money is calm — a good day to review fixed expenses.",
                     "With nothing big moving, look back at subscriptions and recurring bills. Small adjustments add up more than you'd think."),
                    ("A quick money check-in brings a sense of safety.",
                     "Spend ten minutes reviewing this month's flow — not to worry, but to know. Clarity itself is a kind of confidence."),
                ],
            ],
            .bright: [
                .traditionalChinese: [
                    ("金錢直覺不錯，適合理性規劃。",
                     "今天適合冷靜地看長期的財務安排：儲蓄的比例、想存的目標。做一個小而具體的決定就好。"),
                    ("小小的進帳或好消息可能出現。",
                     "留意生活裡跟錢有關的小機會：折扣、回饋、被歸還的東西。收下的同時，也記得不因此鬆開原則。"),
                ],
                .english: [
                    ("Good money instincts — a fine day for calm planning.",
                     "Look calmly at longer-term arrangements today: savings ratio, a goal worth saving toward. One small, concrete decision is enough."),
                    ("A small gain or bit of good news may appear.",
                     "Watch for little money moments — a discount, a refund, something returned. Enjoy them without loosening your principles."),
                ],
            ],
        ],
    ]

    private static let colors: [HoroscopeColor] = [
        HoroscopeColor(name: "Lavender", localizedName: "薰衣草紫", hex: "#B8A2E8"),
        HoroscopeColor(name: "Warm Gold", localizedName: "暖金色", hex: "#E3B75C"),
        HoroscopeColor(name: "Cream White", localizedName: "奶油白", hex: "#F6EFDD"),
        HoroscopeColor(name: "Lake Green", localizedName: "湖水綠", hex: "#7FC6B4"),
        HoroscopeColor(name: "Rose Pink", localizedName: "玫瑰粉", hex: "#E8A2B8"),
        HoroscopeColor(name: "Sky Blue", localizedName: "天空藍", hex: "#8FBBE8"),
        HoroscopeColor(name: "Apricot", localizedName: "杏桃橘", hex: "#F0B583"),
        HoroscopeColor(name: "Moonlight Silver", localizedName: "月光銀", hex: "#C9CDD8"),
        HoroscopeColor(name: "Forest Green", localizedName: "森林綠", hex: "#6E9B7B"),
        HoroscopeColor(name: "Berry Red", localizedName: "莓果紅", hex: "#C96A79"),
    ]

    private static let items: [AppLanguage: [String]] = [
        .traditionalChinese: [
            "一杯溫熱的飲料", "小星星飾品", "喜歡的筆", "柔軟的圍巾",
            "一首熟悉的歌", "便條紙", "護手霜", "隨身小書", "耳機", "小點心",
        ],
        .english: [
            "A warm drink", "A little star charm", "A favorite pen", "A soft scarf",
            "A familiar song", "Sticky notes", "Hand cream", "A pocket book",
            "Headphones", "A small snack",
        ],
    ]

    private static let twinkoMessages: [AppLanguage: [String]] = [
        .traditionalChinese: [
            "不用一次解決全部，先把今天最重要的一步走好。",
            "累的時候記得，休息也是往前走的一部分。",
            "今天的你，已經比自己以為的做得更好了。",
            "把心放軟一點，世界也會跟著柔軟一些。",
            "慢慢來沒關係，我會在這裡陪著你。",
        ],
        .english: [
            "You don't have to solve everything at once — just take today's most important step well.",
            "When you're tired, remember: resting is part of moving forward too.",
            "You're already doing better today than you think you are.",
            "Soften your heart a little, and the world softens with you.",
            "It's okay to go slowly. I'll be right here with you.",
        ],
    ]
}
