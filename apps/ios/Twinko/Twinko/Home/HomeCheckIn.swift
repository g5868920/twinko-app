import SwiftUI

// MARK: - Daily Check-in model

/// Approved check-in moods (Home redesign 2026-07-16).
enum CheckInMood: String, Codable, CaseIterable, Identifiable {
    case happy, calm, anxious, tired, confused

    var id: String { rawValue }

    func label(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.happy, .english): return "Happy"
        case (.happy, .traditionalChinese): return "開心"
        case (.calm, .english): return "Calm"
        case (.calm, .traditionalChinese): return "平靜"
        case (.anxious, .english): return "Anxious"
        case (.anxious, .traditionalChinese): return "焦慮"
        case (.tired, .english): return "Tired"
        case (.tired, .traditionalChinese): return "疲憊"
        case (.confused, .english): return "Confused"
        case (.confused, .traditionalChinese): return "迷惘"
        }
    }

    /// Low-saturation orb base color (approved direction).
    var orbColor: Color {
        switch self {
        case .happy: return Color(hex: 0xF4CF6E)      // warm yellow
        case .calm: return Color(hex: 0x9CBBE8)       // soft blue
        case .anxious: return Color(hex: 0xB3A2E0)    // muted lavender
        case .tired: return Color(hex: 0xF0AFA0)      // soft coral/peach
        case .confused: return Color(hex: 0xB6AFC9)   // lavender-gray
        }
    }
}

/// Approved check-in needs.
enum CheckInNeed: String, Codable, CaseIterable, Identifiable {
    case talk, ground, direction, rest

    var id: String { rawValue }

    func label(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.talk, .english): return "Talk"
        case (.talk, .traditionalChinese): return "聊聊"
        case (.ground, .english): return "Feel Grounded"
        case (.ground, .traditionalChinese): return "安定下來"
        case (.direction, .english): return "Find Direction"
        case (.direction, .traditionalChinese): return "獲得方向"
        case (.rest, .english): return "Rest"
        case (.rest, .traditionalChinese): return "休息"
        }
    }

    var icon: String {
        switch self {
        case .talk: return "bubble.left"
        case .ground: return "leaf"
        case .direction: return "sparkles"
        case .rest: return "moon"
        }
    }
}

/// One local check-in per calendar day, editable during that day.
/// Kept small on purpose — ready for a future Personal Context layer
/// without building it now.
struct DailyCheckIn: Codable, Identifiable, Equatable {
    let id: UUID
    let localDate: String
    var mood: CheckInMood
    var need: CheckInNeed
    let createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), localDate: String, mood: CheckInMood, need: CheckInNeed,
         createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id
        self.localDate = localDate
        self.mood = mood
        self.need = need
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static func dateKey(for date: Date = .now, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }
}

/// Persists the current day's check-in through the existing JSONStore
/// pattern (one small file; older days are replaced).
@MainActor
final class CheckInStore: ObservableObject {
    @Published private(set) var current: DailyCheckIn?

    private let store: JSONStore
    private nonisolated static let fileName = "daily_checkin"

    nonisolated init(store: JSONStore = JSONStore()) {
        self.store = store
        let saved = store.load(DailyCheckIn.self, from: Self.fileName)
        _current = Published(initialValue: saved)
    }

    /// The check-in for today's local date, if one exists.
    var today: DailyCheckIn? {
        guard let current, current.localDate == DailyCheckIn.dateKey() else { return nil }
        return current
    }

    /// Creates or updates today's check-in (one record per local day).
    func save(mood: CheckInMood, need: CheckInNeed) {
        if var existing = today {
            existing.mood = mood
            existing.need = need
            existing.updatedAt = .now
            current = existing
        } else {
            current = DailyCheckIn(localDate: DailyCheckIn.dateKey(), mood: mood, need: need)
        }
        store.save(current, as: Self.fileName)
    }
}

// MARK: - Recommendation provider boundary

/// One Home action routed to an existing feature.
enum HomeAction: Equatable, Identifiable, Hashable {
    case chat
    case meditation(focus: MeditationFocus, duration: MeditationDuration)
    case tarot
    case horoscope
    case music

    var id: String {
        switch self {
        case .chat: return "chat"
        case .meditation(let focus, let duration): return "meditation-\(focus.rawValue)-\(duration.rawValue)"
        case .tarot: return "tarot"
        case .horoscope: return "horoscope"
        case .music: return "music"
        }
    }

    func label(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.chat, .english): return "Talk with Twinko"
        case (.chat, .traditionalChinese): return "跟 Twinko 聊聊"
        case (.meditation(_, let duration), .english):
            return "Start a \(duration.rawValue)-minute meditation"
        case (.meditation(_, let duration), .traditionalChinese):
            return "開始 \(duration.rawValue) 分鐘冥想"
        case (.tarot, .english): return "Draw a Tarot reading"
        case (.tarot, .traditionalChinese): return "抽一次塔羅"
        case (.horoscope, .english): return "Today's Horoscope"
        case (.horoscope, .traditionalChinese): return "看今日星座運勢"
        case (.music, .english): return "Quiet music"
        case (.music, .traditionalChinese): return "聽點安靜的音樂"
        }
    }
}

struct HomeRecommendation: Equatable {
    let message: String
    let primaryAction: HomeAction
    let secondaryAction: HomeAction?
}

/// Small provider boundary: deterministic local templates now, an
/// AI-personalized provider later — views never hardwire the mapping.
protocol HomeRecommendationProviding {
    func recommendation(for checkIn: DailyCheckIn, lang: AppLanguage) -> HomeRecommendation
}

/// Prototype provider: the primary action follows the selected need;
/// mood shapes the message tone and meditation parameters. Copy is
/// natural and supportive — never "because you selected X".
struct LocalHomeRecommendationProvider: HomeRecommendationProviding {

    func recommendation(for checkIn: DailyCheckIn, lang: AppLanguage) -> HomeRecommendation {
        HomeRecommendation(
            message: message(for: checkIn, lang: lang),
            primaryAction: primaryAction(for: checkIn),
            secondaryAction: secondaryAction(for: checkIn, lang: lang))
    }

    private func primaryAction(for checkIn: DailyCheckIn) -> HomeAction {
        switch checkIn.need {
        case .talk:
            return .chat
        case .ground:
            return .meditation(focus: checkIn.mood == .anxious ? .releaseAnxiety : .calmDown,
                               duration: .three)
        case .direction:
            return .tarot
        case .rest:
            // Music remains a placeholder — Meditation is the primary
            // available action (approved MVP rule).
            return .meditation(focus: .sleep, duration: .five)
        }
    }

    private func secondaryAction(for checkIn: DailyCheckIn, lang: AppLanguage) -> HomeAction? {
        switch checkIn.need {
        case .talk:
            return .meditation(focus: .calmDown, duration: .three)
        case .ground:
            return .chat
        case .direction:
            return checkIn.mood == .confused ? .chat : .horoscope
        case .rest:
            return .music
        }
    }

    private func message(for checkIn: DailyCheckIn, lang: AppLanguage) -> String {
        let zh: [CheckInMood: String] = [
            .happy: "今天的你帶著一點光。",
            .calm: "今天的你蠻安穩的。",
            .anxious: "今天心裡好像有點緊緊的。",
            .tired: "你今天好像有點累。",
            .confused: "今天的方向好像有點模糊。",
        ]
        let en: [CheckInMood: String] = [
            .happy: "There's a little light in you today.",
            .calm: "You feel fairly steady today.",
            .anxious: "Something feels a bit tight inside today.",
            .tired: "You seem a little tired today.",
            .confused: "The way forward feels a bit blurry today.",
        ]
        let zhNeed: [CheckInNeed: String] = [
            .talk: "把心裡的話說給我聽，不用整理好也沒關係。",
            .ground: "先陪自己安靜 3 分鐘，讓心慢慢放鬆下來吧。",
            .direction: "讓牌卡給你一個溫柔的角度，不急著找答案。",
            .rest: "今晚就先好好休息，其他的明天再說。",
        ]
        let enNeed: [CheckInNeed: String] = [
            .talk: "Tell me what's on your mind — it doesn't need to be tidy.",
            .ground: "Take three quiet minutes with yourself and let your heart soften.",
            .direction: "Let the cards offer a gentle angle — no rush for answers.",
            .rest: "Rest well tonight; the rest can wait for tomorrow.",
        ]
        return lang == .english
            ? "\(en[checkIn.mood]!) \(enNeed[checkIn.need]!)"
            : "\(zh[checkIn.mood]!)\n\(zhNeed[checkIn.need]!)"
    }
}

// MARK: - Mood Orb (code-rendered, Twinko DNA but not Twinko)

/// Reusable code-rendered Mood Orb: rounded dimensional orb, glossy
/// eyes, gentle cheeks, simple mouth per mood — no body, costume, or
/// accessories, so it never competes with the Twinko hero. Selected
/// state adds a ring and checkmark (never color alone).
struct MoodOrbView: View {
    let mood: CheckInMood
    let isSelected: Bool
    var size: CGFloat = 52

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(colors: [mood.orbColor.opacity(0.95),
                                            mood.orbColor],
                                   center: .init(x: 0.38, y: 0.3),
                                   startRadius: 2, endRadius: size * 0.72)
                )
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: size * 0.26, height: size * 0.16)
                        .blur(radius: 2)
                        .offset(x: -size * 0.18, y: -size * 0.26)
                )
                .shadow(color: mood.orbColor.opacity(0.45), radius: isSelected ? 8 : 4, y: 2)

            face
                .offset(y: size * 0.02)

            if isSelected {
                Circle()
                    .strokeBorder(Color.twinkoGold, lineWidth: 2.5)
                    .frame(width: size + 8, height: size + 8)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: size * 0.30))
                    .foregroundStyle(Color.twinkoGold)
                    .background(Circle().fill(.white).padding(2))
                    .offset(x: size * 0.36, y: -size * 0.36)
            }
        }
        .frame(width: size + 10, height: size + 10)
        .accessibilityHidden(true)
    }

    /// Simple expression per mood: glossy eyes + mouth variation.
    private var face: some View {
        VStack(spacing: size * 0.10) {
            HStack(spacing: size * 0.22) {
                eye
                eye
            }
            mouth
        }
    }

    private var eye: some View {
        ZStack {
            Circle()
                .fill(Color(hex: 0x2B2438))
                .frame(width: size * 0.13, height: mood == .tired ? size * 0.07 : size * 0.13)
            Circle()
                .fill(.white.opacity(0.9))
                .frame(width: size * 0.045, height: size * 0.045)
                .offset(x: -size * 0.02, y: -size * 0.02)
        }
    }

    @ViewBuilder
    private var mouth: some View {
        let stroke = StrokeStyle(lineWidth: size * 0.045, lineCap: .round)
        switch mood {
        case .happy:
            SmileArc(upward: true)
                .stroke(Color(hex: 0x2B2438), style: stroke)
                .frame(width: size * 0.26, height: size * 0.10)
        case .calm:
            Capsule()
                .fill(Color(hex: 0x2B2438))
                .frame(width: size * 0.16, height: size * 0.045)
        case .anxious:
            SmileArc(upward: false)
                .stroke(Color(hex: 0x2B2438), style: stroke)
                .frame(width: size * 0.22, height: size * 0.08)
        case .tired:
            Capsule()
                .fill(Color(hex: 0x2B2438))
                .frame(width: size * 0.12, height: size * 0.045)
        case .confused:
            WavyMouth()
                .stroke(Color(hex: 0x2B2438), style: stroke)
                .frame(width: size * 0.24, height: size * 0.07)
        }
    }
}

private struct SmileArc: Shape {
    let upward: Bool
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: upward ? rect.minY : rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: upward ? rect.minY : rect.maxY),
            control: CGPoint(x: rect.midX, y: upward ? rect.maxY : rect.minY))
        return path
    }
}

private struct WavyMouth: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.midY),
                          control: CGPoint(x: rect.width * 0.25, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                          control: CGPoint(x: rect.width * 0.75, y: rect.maxY))
        return path
    }
}

// MARK: - Home strings

enum HomeExperienceStrings {
    static func greeting(_ lang: AppLanguage, hour: Int = Calendar.current.component(.hour, from: .now),
                         name: String?) -> String {
        let base: String
        switch (hour, lang) {
        case (5..<12, .traditionalChinese): base = "早安"
        case (12..<18, .traditionalChinese): base = "午安"
        case (_, .traditionalChinese): base = "晚安"
        case (5..<12, .english): base = "Good morning"
        case (12..<18, .english): base = "Good afternoon"
        case (_, .english): base = "Good evening"
        }
        guard let name, !name.isEmpty else { return base }
        return lang == .english ? "\(base), \(name)" : "\(base)，\(name)"
    }

    static func greetingSupport(_ l: AppLanguage) -> String {
        l == .english ? "Which part of you needs care today?" : "今天想先照顧哪一部分的自己？"
    }
    static func moodQuestion(_ l: AppLanguage) -> String {
        l == .english ? "How are you feeling right now?" : "你現在感覺如何？"
    }
    static func needQuestion(_ l: AppLanguage) -> String {
        l == .english ? "What do you need most right now?" : "現在最需要什麼？"
    }
    static func summaryMood(_ l: AppLanguage) -> String {
        l == .english ? "Feeling today" : "今天感覺"
    }
    static func summaryNeed(_ l: AppLanguage) -> String {
        l == .english ? "Need right now" : "現在需要"
    }
    static func edit(_ l: AppLanguage) -> String {
        l == .english ? "Edit" : "修改"
    }
    static func continuationTitle(_ l: AppLanguage) -> String {
        l == .english ? "Continue your companionship" : "繼續你的陪伴"
    }
    static func continueChat(_ l: AppLanguage) -> String {
        l == .english ? "Return to your recent conversation" : "回到剛剛的對話"
    }
    static func exploreTitle(_ l: AppLanguage) -> String {
        l == .english ? "Explore more" : "探索更多"
    }
    static func viewAll(_ l: AppLanguage) -> String {
        l == .english ? "View all" : "看全部"
    }

    // Tabs
    static func tabHome(_ l: AppLanguage) -> String { l == .english ? "Home" : "首頁" }
    static func tabChat(_ l: AppLanguage) -> String { l == .english ? "Chat" : "聊天" }
    static func tabExplore(_ l: AppLanguage) -> String { l == .english ? "Explore" : "探索" }
    static func tabMyPlanet(_ l: AppLanguage) -> String { l == .english ? "My Planet" : "我的星球" }
    static func settings(_ l: AppLanguage) -> String { l == .english ? "Settings" : "設定" }
}
