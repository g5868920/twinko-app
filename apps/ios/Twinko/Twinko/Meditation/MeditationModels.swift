import Foundation

// MARK: - Setup options

/// Canonical Quick Start themes (feature spec §5).
enum MeditationFocus: String, Codable, CaseIterable, Identifiable {
    case calmDown = "calm_down"
    case releaseAnxiety = "release_anxiety"
    case sleep
    case selfLove = "self_love"
    case manifest

    var id: String { rawValue }

    func label(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.calmDown, .english): return "Calm Down"
        case (.calmDown, .traditionalChinese): return "平靜下來"
        case (.releaseAnxiety, .english): return "Release Anxiety"
        case (.releaseAnxiety, .traditionalChinese): return "釋放焦慮"
        case (.sleep, .english): return "Sleep"
        case (.sleep, .traditionalChinese): return "準備入睡"
        case (.selfLove, .english): return "Self-Love"
        case (.selfLove, .traditionalChinese): return "照顧自己"
        case (.manifest, .english): return "Manifest"
        case (.manifest, .traditionalChinese): return "顯化意念"
        }
    }

    var icon: String {
        switch self {
        case .calmDown: return "wind"
        case .releaseAnxiety: return "leaf.fill"
        case .sleep: return "moon.zzz.fill"
        case .selfLove: return "heart.fill"
        case .manifest: return "sparkles"
        }
    }
}

/// Approved durations (feature spec §5). Default: 5 minutes.
enum MeditationDuration: Int, Codable, CaseIterable, Identifiable {
    case three = 3
    case five = 5
    case ten = 10

    var id: Int { rawValue }

    func label(_ lang: AppLanguage) -> String {
        lang == .english ? "\(rawValue) min" : "\(rawValue) 分鐘"
    }

    /// Lines per session segment scale gently with duration.
    var linesPerSegment: Int {
        switch self {
        case .three: return 2
        case .five: return 3
        case .ten: return 4
        }
    }
}

// MARK: - Source context

enum MeditationSourceType: String, Codable {
    case direct, chat, tarot
}

/// Minimal cross-feature handoff context. Only short, locally derived
/// summaries travel here — never raw transcripts or full readings.
struct MeditationSourceContext: Equatable {
    let sourceType: MeditationSourceType
    var recentChatSummary: String?
    var tarotQuestion: String?
    var tarotSummary: String?
    var emotionalTone: String?

    static let direct = MeditationSourceContext(sourceType: .direct)
}

// MARK: - Generation request / result

struct MeditationGenerationRequest: Equatable {
    let sourceContext: MeditationSourceContext
    let focusTopic: MeditationFocus
    let duration: MeditationDuration
    let customUserInput: String?
}

enum MeditationSegmentKind: String, Codable, CaseIterable {
    case grounding, breathing, reflection, affirmation, closing

    func label(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.grounding, .english): return "Arriving"
        case (.grounding, .traditionalChinese): return "安頓"
        case (.breathing, .english): return "Breathing"
        case (.breathing, .traditionalChinese): return "呼吸"
        case (.reflection, .english): return "Reflection"
        case (.reflection, .traditionalChinese): return "沉澱"
        case (.affirmation, .english): return "Affirmation"
        case (.affirmation, .traditionalChinese): return "肯定"
        case (.closing, .english): return "Returning"
        case (.closing, .traditionalChinese): return "回來"
        }
    }

    var icon: String {
        switch self {
        case .grounding: return "circle.dotted"
        case .breathing: return "wind"
        case .reflection: return "moon.stars"
        case .affirmation: return "heart"
        case .closing: return "sun.horizon"
        }
    }
}

struct MeditationSegment: Equatable, Identifiable {
    let kind: MeditationSegmentKind
    let lines: [String]

    var id: String { kind.rawValue }
}

/// Structured session content — kept segment-based so a future TTS /
/// audio layer can be added without changing the model.
struct MeditationGenerationResult: Equatable {
    let title: String
    let segments: [MeditationSegment]
    let closingMessage: String
    let duration: MeditationDuration
    let sourceType: MeditationSourceType

    /// Structural validation before a session is shown (never present
    /// malformed content).
    var isValid: Bool {
        !title.isEmpty
            && segments.map(\.kind) == MeditationSegmentKind.allCases
            && segments.allSatisfy { !$0.lines.isEmpty && $0.lines.allSatisfy { !$0.isEmpty } }
            && !closingMessage.isEmpty
    }
}
