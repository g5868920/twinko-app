import Foundation

/// Gender options approved for the active MVP scope. Must not affect
/// Chat, Tarot, Astrology, safety treatment, or product access — it is
/// stored only so the prototype can demonstrate the consolidated
/// profile flow. `rawValue` is the on-disk key (unchanged for existing
/// profiles); use `displayName(for:)` for anything shown on screen.
enum Gender: String, CaseIterable, Identifiable, Equatable {
    case female = "女性"
    case male = "男性"
    case other = "其他"
    case preferNotToSay = "不方便透露"

    var id: String { rawValue }

    func displayName(for lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.female, .traditionalChinese): return "女性"
        case (.female, .english): return "Female"
        case (.male, .traditionalChinese): return "男性"
        case (.male, .english): return "Male"
        case (.other, .traditionalChinese): return "其他"
        case (.other, .english): return "Other"
        case (.preferNotToSay, .traditionalChinese): return "不方便透露"
        case (.preferNotToSay, .english): return "Prefer not to say"
        }
    }
}

extension Gender: Codable {
    /// A previously stored "非二元" (Non-binary — removed from the
    /// active option set) maps safely to `.other` instead of failing to
    /// decode and losing the profile.
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Gender(rawValue: raw) ?? .other
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

/// Local prototype profile. Birthday is used only for local zodiac
/// calculation (D-054).
struct UserProfile: Codable, Equatable {
    var preferredName: String
    var birthday: Date
    var gender: Gender
}
