import Foundation

/// Gender options approved in D-054. Must not affect Chat, Tarot,
/// Astrology, safety treatment, or product access — it is stored only
/// so the prototype can demonstrate the consolidated profile flow.
enum Gender: String, Codable, CaseIterable, Identifiable {
    case female = "女性"
    case male = "男性"
    case nonBinary = "非二元"
    case other = "其他"
    case preferNotToSay = "不方便透露"

    var id: String { rawValue }
}

/// Local prototype profile. Birthday is used only for local zodiac
/// calculation (D-054).
struct UserProfile: Codable, Equatable {
    var preferredName: String
    var birthday: Date
    var gender: Gender
}
