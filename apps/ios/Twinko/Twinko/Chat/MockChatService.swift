import Foundation

/// Deterministic, local-only response selection. No network access and
/// no live model call of any kind (D-054). Responses follow the content
/// pattern: acknowledge → reflect the stated feeling without inventing
/// facts → one gentle question or two options → optional small action →
/// close without pressure. No diagnosis, no certainty, no dependency or
/// guilt language.
///
/// Locale rule (2026-07-17): newly produced responses match the app
/// locale at the moment they are created. Stored history is never
/// retroactively translated.
enum MockChatResult: Equatable {
    case success(String)
    case fallback(String)
}

protocol MockChatServicing: Sendable {
    func response(for input: String, lang: AppLanguage) -> MockChatResult
}

extension MockChatServicing {
    /// Legacy convenience for older call sites/tests.
    func response(for input: String) -> MockChatResult {
        response(for: input, lang: .traditionalChinese)
    }
}

struct MockChatService: MockChatServicing {
    /// Local, development-only phrases that deterministically trigger
    /// the fallback/error state for testing.
    static let errorTriggers = ["error test", "測試錯誤"]

    /// Scenario table: shared keyword sets (zh + en) with one localized
    /// response per language.
    private static let scenarios: [(keywords: [String], zh: String, en: String)] = [
        // 1. 感到低落 / feeling down
        (["難過", "低落", "傷心", "不開心", "想哭", "心情不好",
          "sad", "down", "unhappy", "cry", "feeling low", "heavy"],
         "聽起來你現在心裡有點重重的。難過的時候，願意說出來已經很不容易了。你想多說一點發生了什麼嗎？還是想先安靜地待一下也可以。",
         "It sounds like your heart feels a little heavy right now. When you're sad, even saying it out loud takes courage. Would you like to tell me more about what happened? Or we can just sit quietly for a moment too."),
        // 2. 擔心與焦慮 / worry and anxiety
        (["擔心", "焦慮", "緊張", "不安", "煩惱", "害怕",
          "worried", "anxious", "anxiety", "nervous", "uneasy", "scared", "afraid"],
         "嗯，我聽到了，這件事讓你有些不安。會這樣想很自然。你比較想聊聊最讓你掛心的部分，還是先做三次慢慢的深呼吸，讓自己緩一緩？",
         "Mm, I hear you — this has been making you uneasy, and it's natural to feel that way. Would you rather talk about the part that worries you most, or take three slow breaths first and let yourself settle a little?"),
        // 3. 工作壓力 / work pressure
        (["工作", "加班", "上班", "老闆", "壓力", "報告",
          "work", "overtime", "boss", "pressure", "deadline", "report"],
         "工作的事情累積起來，真的會讓人喘不過氣。辛苦你了。今天最消耗你的是哪一部分呢？如果願意，也可以先倒杯水、離開座位一下下再回來。",
         "When work piles up, it really can feel suffocating. You've been carrying a lot. Which part drained you most today? If you like, pour yourself some water and step away for a moment first — I'll be here."),
        // 4. 感情與關係 / relationships
        (["感情", "關係", "喜歡", "曖昧", "吵架", "朋友",
          "relationship", "crush", "argument", "fight", "friend", "partner"],
         "人和人之間的心情，常常沒有標準答案。你願意跟我說說，這段關係裡最讓你在意的是什麼嗎？我會好好聽。",
         "Feelings between people rarely have one right answer. Would you tell me what matters to you most in this relationship? I'm listening, properly."),
        // 5. 自信與鼓勵 / confidence
        (["沒自信", "做不到", "失敗", "搞砸", "我不行", "沒用",
          "can't do", "cant do", "failed", "failure", "messed up", "useless", "not good enough"],
         "謝謝你願意把這種感覺說出來。一件事不順利，不代表你這個人不好。你想聊聊當時發生了什麼嗎？或者，先想一件你今天有好好完成的小事，再小都算數。",
         "Thank you for saying this out loud. One thing going badly doesn't make you a bad person. Want to tell me what happened? Or first, think of one small thing you did complete today — however small, it counts."),
        // 6. 夢與好奇 / dreams
        (["夢到", "做夢", "夢見", "dreamt", "dreamed", "had a dream"],
         "夢有時候像心裡的小劇場，把白天沒說完的感覺演出來。這個夢醒來之後，留給你的感覺是什麼呢？想聊聊的話我在。",
         "Dreams can be like a little theater of the heart, acting out feelings the day didn't finish. What feeling did this dream leave you with after waking? I'm here if you'd like to talk it through."),
        // 7. 打招呼與日常 / greetings and daily life
        (["嗨", "你好", "哈囉", "hi", "hello", "hey", "안녕", "早安", "午安", "晚安",
          "my day", "today", "good morning", "good evening"],
         "嗨，很高興你來找我。今天過得怎麼樣？不管是開心的還是悶悶的，都可以跟我說說。",
         "Hi, I'm glad you came to me. How has your day been? Happy or heavy or somewhere in between — you can tell me any of it."),
        // 8. 想要陪伴 / wanting company
        (["陪我", "陪伴", "有人陪", "company", "lonely", "alone"],
         "我在喔。不用特別說什麼也沒關係，我就在這裡陪你。想到什麼、或忽然想說話的時候，隨時開口就好。",
         "I'm here. You don't have to say anything in particular — I'll just keep you company. Whenever something comes to mind, or you suddenly feel like talking, just say the word."),
        // 9. 不知道說什麼 / not sure what to say
        (["不知道", "沒話", "說什麼", "不想說",
          "don't know what to say", "dont know what to say", "nothing to say"],
         "沒關係，不知道從哪裡開始說，也是一種心情。我們可以慢慢來。要不要先選一個字形容今天？像是「累」、「還好」或「亂亂的」都可以。",
         "That's okay — not knowing where to start is a feeling too. We can take it slowly. Want to pick one word for today first? Something like \"tired\", \"okay\", or \"scrambled\" all count.")
    ]

    private static let fallbackZh =
        "嗯……我可能沒有完全聽懂你的意思，抱歉。你願意換個方式說說看嗎？或者用一個簡單的詞告訴我你現在的感覺，我會慢慢陪你把它說清楚。"
    private static let fallbackEn =
        "Hmm… I may not have fully understood what you mean — sorry. Would you try saying it another way? Or give me one simple word for how you feel right now, and we'll put it into words together, slowly."

    func response(for input: String, lang: AppLanguage) -> MockChatResult {
        let normalized = input.lowercased()
        let fallback = lang == .english ? Self.fallbackEn : Self.fallbackZh

        if Self.errorTriggers.contains(where: { normalized.contains($0) }) {
            return .fallback(fallback)
        }

        for entry in Self.scenarios
        where entry.keywords.contains(where: { normalized.contains($0.lowercased()) }) {
            return .success(lang == .english ? entry.en : entry.zh)
        }

        return .fallback(fallback)
    }
}
