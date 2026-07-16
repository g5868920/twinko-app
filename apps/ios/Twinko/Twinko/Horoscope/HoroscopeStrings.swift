import Foundation

/// Bilingual copy for the Horoscope surface — one language at a time,
/// canonical values stay in code.
enum HoroscopeStrings {
    static func title(_ l: AppLanguage) -> String {
        l == .english ? "Horoscope" : "今日星座運勢"
    }
    static func mySign(_ l: AppLanguage) -> String {
        l == .english ? "My Sign" : "我的星座"
    }
    static func changeSign(_ l: AppLanguage) -> String {
        l == .english ? "Change sign" : "切換星座"
    }
    static func selectorTitle(_ l: AppLanguage) -> String {
        l == .english ? "Choose a Zodiac Sign" : "選擇星座"
    }
    static func selectorHelper(_ l: AppLanguage) -> String {
        l == .english
            ? "You can explore other signs without changing your profile."
            : "你可以看看其他星座，不會改動你的個人資料。"
    }
    static func twinkoSays(_ l: AppLanguage) -> String {
        l == .english ? "Twinko says" : "Twinko 想說"
    }
    static func luckyTitle(_ l: AppLanguage) -> String {
        l == .english ? "Lucky Details" : "今日幸運"
    }
    static func luckyNumber(_ l: AppLanguage) -> String {
        l == .english ? "Lucky Number" : "幸運數字"
    }
    static func luckyColor(_ l: AppLanguage) -> String {
        l == .english ? "Lucky Color" : "幸運顏色"
    }
    static func luckyZodiac(_ l: AppLanguage) -> String {
        l == .english ? "Lucky Zodiac" : "幸運星座"
    }
    static func luckyItem(_ l: AppLanguage) -> String {
        l == .english ? "Lucky Item" : "幸運小物"
    }
    static func saveCard(_ l: AppLanguage) -> String {
        l == .english ? "Save Summary Card" : "儲存運勢小卡"
    }
    static func share(_ l: AppLanguage) -> String {
        l == .english ? "Share" : "分享"
    }
    /// Approved short disclaimer (2026-07-17).
    static func disclaimer(_ l: AppLanguage) -> String {
        l == .english ? "For reflection and entertainment only" : "內容僅供反思與娛樂"
    }

    // Setup / missing profile
    static func setupExplainer(_ l: AppLanguage) -> String {
        l == .english
            ? "We use your birthday to determine your zodiac sign."
            : "我們會用你的生日來判斷你的星座。"
    }
    static func continueLabel(_ l: AppLanguage) -> String {
        l == .english ? "Continue" : "繼續"
    }
    static func chooseManually(_ l: AppLanguage) -> String {
        l == .english ? "Choose Zodiac Sign Manually" : "手動選擇星座"
    }
    static func youAre(_ sign: ZodiacSign, _ l: AppLanguage) -> String {
        l == .english ? "You're a \(sign.displayName(for: l))" : "你是\(sign.displayName(for: l))"
    }

    // Errors / retry
    static func emptyMessage(_ l: AppLanguage) -> String {
        l == .english
            ? "Today's message is still gathering stars. Please try again."
            : "今天的訊息還在收集星光，請再試一次。"
    }
    static func retry(_ l: AppLanguage) -> String {
        l == .english ? "Retry" : "再試一次"
    }

    // Summary card sheet
    static func cardBrandTitle(_ l: AppLanguage) -> String {
        l == .english ? "Daily Horoscope" : "今日星座運勢"
    }
    static func saveToPhotos(_ l: AppLanguage) -> String {
        l == .english ? "Save to Photos" : "儲存到照片"
    }
    static func shareImage(_ l: AppLanguage) -> String {
        l == .english ? "Share" : "分享"
    }
    static func close(_ l: AppLanguage) -> String {
        l == .english ? "Close" : "關閉"
    }
    static func savedToast(_ l: AppLanguage) -> String {
        l == .english ? "Saved to Photos" : "已儲存到照片"
    }
    static func saveDenied(_ l: AppLanguage) -> String {
        l == .english
            ? "Photos permission is needed to save. You can enable it in Settings."
            : "需要照片權限才能儲存，可以到「設定」開啟。"
    }
    static func renderFailed(_ l: AppLanguage) -> String {
        l == .english
            ? "The card couldn't be rendered. You can retry or share as text."
            : "小卡產生失敗，可以再試一次，或改用文字分享。"
    }
    static func shareTextFallback(_ l: AppLanguage) -> String {
        l == .english ? "Share Text" : "文字分享"
    }
}

// MARK: - Share text formatter

/// Formats the daily result for the native share sheet: sign, date,
/// headline, overall summary, Twinko message, light attribution.
/// Never includes birthday, long details, or user context.
enum HoroscopeShareFormatter {
    static func text(for horoscope: DailyHoroscope, sign: ZodiacSign,
                     lang: AppLanguage, date: Date = .now) -> String {
        let dateText = date.formatted(
            Date.FormatStyle(locale: Locale(identifier: lang.rawValue))
                .year().month().day())
        let header = lang == .english
            ? "\(sign.displayName(for: lang)) | Daily Horoscope"
            : "\(sign.displayName(for: lang))｜今日運勢"
        return [
            header,
            dateText,
            "",
            horoscope.headline,
            horoscope.overall.summary,
            "",
            (lang == .english ? "Twinko says:" : "Twinko 想說："),
            horoscope.twinkoMessage,
            "",
            "TwinkoTalk",
        ].joined(separator: "\n")
    }
}
