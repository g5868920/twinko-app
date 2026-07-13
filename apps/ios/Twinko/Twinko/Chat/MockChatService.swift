import Foundation

/// Deterministic, local-only response selection. No network access and
/// no live model call of any kind (D-054). Responses follow the content
/// pattern: acknowledge → reflect the stated feeling without inventing
/// facts → one gentle question or two options → optional small action →
/// close without pressure. No diagnosis, no certainty, no dependency or
/// guilt language.
enum MockChatResult: Equatable {
    case success(String)
    case fallback(String)
}

protocol MockChatServicing: Sendable {
    func response(for input: String) -> MockChatResult
}

struct MockChatService: MockChatServicing {
    /// Local, development-only phrases that deterministically trigger
    /// the fallback/error state for testing.
    static let errorTriggers = ["error test", "測試錯誤"]

    private static let scenarios: [(keywords: [String], response: String)] = [
        // 1. 感到低落
        (["難過", "低落", "傷心", "不開心", "想哭", "心情不好"],
         "聽起來你現在心裡有點重重的。難過的時候，願意說出來已經很不容易了。你想多說一點發生了什麼嗎？還是想先安靜地待一下也可以。"),
        // 2. 擔心與焦慮
        (["擔心", "焦慮", "緊張", "不安", "煩惱", "害怕"],
         "嗯，我聽到了，這件事讓你有些不安。會這樣想很自然。你比較想聊聊最讓你掛心的部分，還是先做三次慢慢的深呼吸，讓自己緩一緩？"),
        // 3. 工作壓力
        (["工作", "加班", "上班", "老闆", "壓力", "報告"],
         "工作的事情累積起來，真的會讓人喘不過氣。辛苦你了。今天最消耗你的是哪一部分呢？如果願意，也可以先倒杯水、離開座位一下下再回來。"),
        // 4. 感情與關係
        (["感情", "關係", "喜歡", "曖昧", "吵架", "朋友"],
         "人和人之間的心情，常常沒有標準答案。你願意跟我說說，這段關係裡最讓你在意的是什麼嗎？我會好好聽。"),
        // 5. 自信與鼓勵
        (["沒自信", "做不到", "失敗", "搞砸", "我不行", "沒用"],
         "謝謝你願意把這種感覺說出來。一件事不順利，不代表你這個人不好。你想聊聊當時發生了什麼嗎？或者，先想一件你今天有好好完成的小事，再小都算數。"),
        // 6. 夢與好奇
        (["夢到", "做夢", "夢見"],
         "夢有時候像心裡的小劇場，把白天沒說完的感覺演出來。這個夢醒來之後，留給你的感覺是什麼呢？想聊聊的話我在。"),
        // 7. 打招呼與日常
        (["嗨", "你好", "哈囉", "hi", "hello", "안녕", "早安", "午安", "晚安"],
         "嗨，很高興你來找我。今天過得怎麼樣？不管是開心的還是悶悶的，都可以跟我說說。"),
        // 8. 不知道說什麼
        (["不知道", "沒話", "說什麼", "不想說"],
         "沒關係，不知道從哪裡開始說，也是一種心情。我們可以慢慢來。要不要先選一個字形容今天？像是「累」、「還好」或「亂亂的」都可以。")
    ]

    private static let fallbackResponse =
        "嗯……我可能沒有完全聽懂你的意思，抱歉。你願意換個方式說說看嗎？或者用一個簡單的詞告訴我你現在的感覺，我會慢慢陪你把它說清楚。"

    func response(for input: String) -> MockChatResult {
        let normalized = input.lowercased()

        if Self.errorTriggers.contains(where: { normalized.contains($0) }) {
            return .fallback(Self.fallbackResponse)
        }

        for entry in Self.scenarios where entry.keywords.contains(where: { normalized.contains($0.lowercased()) }) {
            return .success(entry.response)
        }

        return .fallback(Self.fallbackResponse)
    }
}
