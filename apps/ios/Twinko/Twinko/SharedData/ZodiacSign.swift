import Foundation

/// Western zodiac signs with Traditional Chinese names. Sun-sign level
/// only (D-054); calculated locally from the stored birthday.
enum ZodiacSign: String, CaseIterable, Codable {
    case aries = "牡羊座"
    case taurus = "金牛座"
    case gemini = "雙子座"
    case cancer = "巨蟹座"
    case leo = "獅子座"
    case virgo = "處女座"
    case libra = "天秤座"
    case scorpio = "天蠍座"
    case sagittarius = "射手座"
    case capricorn = "摩羯座"
    case aquarius = "水瓶座"
    case pisces = "雙魚座"

    var symbol: String {
        switch self {
        case .aries: return "♈"
        case .taurus: return "♉"
        case .gemini: return "♊"
        case .cancer: return "♋"
        case .leo: return "♌"
        case .virgo: return "♍"
        case .libra: return "♎"
        case .scorpio: return "♏"
        case .sagittarius: return "♐"
        case .capricorn: return "♑"
        case .aquarius: return "♒"
        case .pisces: return "♓"
        }
    }

    /// Sign for a month/day pair (inclusive boundary dates follow the
    /// common Western convention).
    static func from(month: Int, day: Int) -> ZodiacSign {
        switch (month, day) {
        case (3, 21...), (4, ...19): return .aries
        case (4, 20...), (5, ...20): return .taurus
        case (5, 21...), (6, ...21): return .gemini
        case (6, 22...), (7, ...22): return .cancer
        case (7, 23...), (8, ...22): return .leo
        case (8, 23...), (9, ...22): return .virgo
        case (9, 23...), (10, ...23): return .libra
        case (10, 24...), (11, ...22): return .scorpio
        case (11, 23...), (12, ...21): return .sagittarius
        case (12, 22...), (1, ...19): return .capricorn
        case (1, 20...), (2, ...18): return .aquarius
        default: return .pisces
        }
    }

    static func from(date: Date, calendar: Calendar = .current) -> ZodiacSign {
        let parts = calendar.dateComponents([.month, .day], from: date)
        return from(month: parts.month ?? 1, day: parts.day ?? 1)
    }
}
