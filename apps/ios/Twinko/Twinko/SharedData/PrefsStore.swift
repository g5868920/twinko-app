import Foundation

/// UI language for the D-055 bilingual Home experience. English and
/// Traditional Chinese Home UI are developed and tested in parallel;
/// inner feature flows remain Traditional-Chinese-first per D-054.
enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case traditionalChinese = "zh-Hant"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .traditionalChinese: return "繁體中文"
        case .english: return "English"
        }
    }
}

/// Minimal prototype preferences (D-054 allows "minimal prototype
/// preferences" in the local JSON store): UI language, plus the
/// manually chosen Horoscope sign (canonical English lowercase ID) for
/// users without a profile birthday. Optional — decodes as nil from
/// older prefs files.
struct PrototypePrefs: Codable, Equatable {
    var language: AppLanguage = .traditionalChinese
    var horoscopeManualSignID: String?
}

@MainActor
final class PrefsStore: ObservableObject {
    @Published var prefs: PrototypePrefs {
        didSet { store.save(prefs, as: Self.fileName) }
    }

    private let store: JSONStore
    private nonisolated static let fileName = "prefs"

    nonisolated init(store: JSONStore = JSONStore()) {
        self.store = store
        _prefs = Published(initialValue: store.load(PrototypePrefs.self, from: Self.fileName) ?? PrototypePrefs())
    }

    var language: AppLanguage {
        get { prefs.language }
        set { prefs.language = newValue }
    }

    var locale: Locale { Locale(identifier: prefs.language.rawValue) }
}

/// Bilingual copy for the Home surface (labels, profile sheet,
/// placeholders). Kept as a plain switch table — no localization
/// infrastructure needed at prototype scale.
enum HomeStrings {
    static func modeLabel(_ mode: HomeMode, _ lang: AppLanguage) -> String {
        switch (mode, lang) {
        case (.chat, .traditionalChinese): return "聊天"
        case (.chat, .english): return "Chat"
        case (.tarot, .traditionalChinese): return "塔羅"
        case (.tarot, .english): return "Tarot"
        case (.zodiac, .traditionalChinese): return "星座"
        case (.zodiac, .english): return "Zodiac"
        case (.meditate, .traditionalChinese): return "冥想"
        case (.meditate, .english): return "Meditate"
        case (.music, .traditionalChinese): return "音樂"
        case (.music, .english): return "Music"
        }
    }

    static func modeAccessibilityLabel(_ mode: HomeMode, _ lang: AppLanguage) -> String {
        switch lang {
        case .traditionalChinese: return "開啟\(modeLabel(mode, lang))"
        case .english: return "Open \(modeLabel(mode, lang))"
        }
    }

    static func profile(_ lang: AppLanguage) -> String {
        lang == .english ? "Profile" : "個人資料"
    }
    static func settings(_ lang: AppLanguage) -> String {
        lang == .english ? "Settings" : "設定"
    }
    static func privacy(_ lang: AppLanguage) -> String {
        lang == .english ? "Privacy" : "隱私"
    }
    static func language(_ lang: AppLanguage) -> String {
        lang == .english ? "Language" : "語言"
    }
    static func openProfile(_ lang: AppLanguage) -> String {
        lang == .english ? "Open Profile" : "開啟個人資料"
    }
}
