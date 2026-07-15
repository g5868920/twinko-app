import Foundation

// MARK: - Zodiac identity (extends the shared ZodiacSign)

/// Canonical Horoscope identity layer over the shared `ZodiacSign`.
/// Internal identifiers are lowercase English IDs; the enum's
/// Traditional Chinese `rawValue` remains untouched for existing
/// profile surfaces.
extension ZodiacSign {
    /// Canonical lowercase English ID — the only internal identifier
    /// used for cache keys, persistence, and asset resolution.
    var canonicalID: String {
        switch self {
        case .aries: return "aries"
        case .taurus: return "taurus"
        case .gemini: return "gemini"
        case .cancer: return "cancer"
        case .leo: return "leo"
        case .virgo: return "virgo"
        case .libra: return "libra"
        case .scorpio: return "scorpio"
        case .sagittarius: return "sagittarius"
        case .capricorn: return "capricorn"
        case .aquarius: return "aquarius"
        case .pisces: return "pisces"
        }
    }

    init?(canonicalID: String) {
        guard let match = ZodiacSign.allCases.first(where: { $0.canonicalID == canonicalID }) else {
            return nil
        }
        self = match
    }

    /// Canonical zodiac symbol imageset name.
    var symbolAssetName: String { "zodiac_\(canonicalID)_v1" }

    /// Localized date range, e.g. "7/23 – 8/22".
    func dateRangeText(_ lang: AppLanguage) -> String {
        let ranges: [ZodiacSign: String] = [
            .aries: "3/21 – 4/19", .taurus: "4/20 – 5/20", .gemini: "5/21 – 6/21",
            .cancer: "6/22 – 7/22", .leo: "7/23 – 8/22", .virgo: "8/23 – 9/22",
            .libra: "9/23 – 10/23", .scorpio: "10/24 – 11/22",
            .sagittarius: "11/23 – 12/21", .capricorn: "12/22 – 1/19",
            .aquarius: "1/20 – 2/18", .pisces: "2/19 – 3/20",
        ]
        return ranges[self] ?? ""
    }

    func horoscopeAccessibilityLabel(_ lang: AppLanguage, isMySign: Bool, isSelected: Bool) -> String {
        var parts = [displayName(for: lang)]
        if isSelected { parts.append(lang == .english ? "selected" : "已選取") }
        if isMySign { parts.append(lang == .english ? "my sign" : "我的星座") }
        return parts.joined(separator: lang == .english ? ", " : "，")
    }
}

// MARK: - Daily horoscope content model

enum HoroscopeDimensionKind: String, Codable, CaseIterable {
    case overall, love, career, wealth

    func title(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.overall, .english): return "Overall"
        case (.overall, .traditionalChinese): return "整體運勢"
        case (.love, .english): return "Love"
        case (.love, .traditionalChinese): return "愛情"
        case (.career, .english): return "Career"
        case (.career, .traditionalChinese): return "事業"
        case (.wealth, .english): return "Wealth"
        case (.wealth, .traditionalChinese): return "財運"
        }
    }

    var icon: String {
        switch self {
        case .overall: return "sun.max.fill"
        case .love: return "heart.fill"
        case .career: return "briefcase.fill"
        case .wealth: return "dollarsign.circle.fill"
        }
    }
}

struct HoroscopeDimension: Codable, Equatable {
    let score: Int
    let summary: String
    let detail: String
}

struct HoroscopeColor: Codable, Equatable {
    let name: String          // English name
    let localizedName: String // zh-Hant name
    let hex: String?

    func displayName(_ lang: AppLanguage) -> String {
        lang == .english ? name : localizedName
    }
}

struct LuckyDetails: Codable, Equatable {
    let number: Int
    let color: HoroscopeColor
    let zodiacID: String
    let item: String

    var luckySign: ZodiacSign? { ZodiacSign(canonicalID: zodiacID) }
}

/// One cached daily result for one sign, date, and locale. Content
/// strings are single-locale (the cache key includes locale).
struct DailyHoroscope: Codable, Equatable {
    let dateKey: String       // local calendar date, e.g. "2026-07-16"
    let locale: String        // AppLanguage rawValue
    let zodiacID: String      // canonical lowercase English ID
    let headline: String
    let overall: HoroscopeDimension
    let love: HoroscopeDimension
    let career: HoroscopeDimension
    let wealth: HoroscopeDimension
    let lucky: LuckyDetails
    let twinkoMessage: String

    var zodiacSign: ZodiacSign? { ZodiacSign(canonicalID: zodiacID) }

    func dimension(_ kind: HoroscopeDimensionKind) -> HoroscopeDimension {
        switch kind {
        case .overall: return overall
        case .love: return love
        case .career: return career
        case .wealth: return wealth
        }
    }

    /// Structural validation for provider responses (spec §19).
    var isValid: Bool {
        let dims = HoroscopeDimensionKind.allCases.map(dimension)
        return ZodiacSign(canonicalID: zodiacID) != nil
            && !headline.isEmpty
            && dims.allSatisfy { (1...5).contains($0.score) && !$0.summary.isEmpty && !$0.detail.isEmpty }
            && (1...99).contains(lucky.number)
            && ZodiacSign(canonicalID: lucky.zodiacID) != nil
            && !lucky.item.isEmpty
            && !twinkoMessage.isEmpty
    }
}

// MARK: - Score labels

enum HoroscopeScoreLabel {
    /// Semantic 1–5 labels — guidance, never judgment (spec §8).
    static func text(_ score: Int, _ lang: AppLanguage) -> String {
        switch (score, lang) {
        case (1, .traditionalChinese): return "放慢腳步"
        case (2, .traditionalChinese): return "多一點留意"
        case (3, .traditionalChinese): return "平穩"
        case (4, .traditionalChinese): return "順勢前進"
        case (_, .traditionalChinese): return "能量充足"
        case (1, .english): return "Move gently"
        case (2, .english): return "Extra care"
        case (3, .english): return "Steady"
        case (4, .english): return "Flowing"
        case (_, .english): return "Full of energy"
        }
    }

    static func accessibilityText(_ score: Int, _ lang: AppLanguage) -> String {
        lang == .english
            ? "score \(score) out of 5, \(text(score, lang))"
            : "分數 5 分裡的 \(score) 分，\(text(score, lang))"
    }
}

// MARK: - Date key

enum HoroscopeDateKey {
    static func key(for date: Date = .now, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }
}
