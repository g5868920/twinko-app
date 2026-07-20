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

    /// Low-saturation orb base color (approved direction) — still used
    /// for the selected glow and shadows around the reference artwork.
    var orbColor: Color {
        switch self {
        case .happy: return Color(hex: 0xF4CF6E)      // warm yellow
        case .calm: return Color(hex: 0x9CBBE8)       // soft blue
        case .anxious: return Color(hex: 0xB3A2E0)    // muted lavender
        case .tired: return Color(hex: 0xF0AFA0)      // soft coral/peach
        case .confused: return Color(hex: 0xB6AFC9)   // lavender-gray
        }
    }

    /// Reference-cropped mood face artwork (home_reference_v1, circular
    /// crops in the asset catalog — replaceable with original exports).
    var referenceAsset: String { "home_mood_\(rawValue)_v1" }
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
    /// The check-in recommendation's Tarot CTA — carries a Home entry
    /// context into the recommended setup (Task 3). Explore/journey
    /// tarot entries stay direct.
    case tarotRecommended
    /// Daily Tarot Check-in entry (uncompleted state).
    case dailyTarot
    /// Completed current-day Daily reading (View Today's Guidance).
    case dailyTarotResult
    case horoscope
    case music
    case activities

    var id: String {
        switch self {
        case .chat: return "chat"
        case .meditation(let focus, let duration): return "meditation-\(focus.rawValue)-\(duration.rawValue)"
        case .tarot: return "tarot"
        case .tarotRecommended: return "tarot-recommended"
        case .dailyTarot: return "daily-tarot"
        case .dailyTarotResult: return "daily-tarot-result"
        case .horoscope: return "horoscope"
        case .music: return "music"
        case .activities: return "activities"
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
        case (.tarot, .english), (.tarotRecommended, .english):
            return "Draw a Tarot reading"
        case (.tarot, .traditionalChinese), (.tarotRecommended, .traditionalChinese):
            return "抽一次塔羅"
        case (.dailyTarot, .english): return "Draw Today's Three Cards"
        case (.dailyTarot, .traditionalChinese): return "抽今天的三張牌"
        case (.dailyTarotResult, .english): return "View Today's Guidance"
        case (.dailyTarotResult, .traditionalChinese): return "查看今日指引"
        case (.horoscope, .english): return "Today's Zodiac"
        case (.horoscope, .traditionalChinese): return "看今日星座運勢"
        case (.music, .english): return "Quiet music"
        case (.music, .traditionalChinese): return "聽點安靜的音樂"
        case (.activities, .english): return "Explore activities"
        case (.activities, .traditionalChinese): return "探索附近活動"
        }
    }
}

struct HomeRecommendation: Equatable {
    let message: String
    let primaryAction: HomeAction
    let secondaryAction: HomeAction?
}

/// One step of Today's Companion Journey.
struct HomeJourneyStep: Equatable, Identifiable {
    let index: Int
    let action: HomeAction
    let title: String
    let purpose: String

    var id: Int { index }
}

/// Locally available personal context for the Home message. Only real
/// summaries and metadata that already exist flow in — never full
/// transcripts, never fabricated events, and every field is optional
/// so Home works with nothing but today's check-in (or nothing at
/// all, via the neutral fallback).
struct HomePersonalizationContext {
    var checkIn: DailyCheckIn?
    /// The most recent chat's short auto/user title (existing model).
    var lastChatTitle: String?
    /// The most recent meditation record (existing local store).
    var lastMeditation: MeditationSessionRecord?
    var hour: Int = Calendar.current.component(.hour, from: .now)

    static let empty = HomePersonalizationContext()
}

/// Small provider boundary: deterministic local templates now, an
/// AI-personalized provider later — views never hardwire the mapping.
protocol HomeRecommendationProviding {
    func recommendation(for checkIn: DailyCheckIn, lang: AppLanguage) -> HomeRecommendation
    /// Twinko's short Home message grounded only in real local
    /// context; returns a neutral localized line when nothing exists.
    func twinkoMessage(context: HomePersonalizationContext, lang: AppLanguage) -> String
    /// Today's three-step Companion Journey for a completed check-in.
    func journey(for checkIn: DailyCheckIn, lang: AppLanguage) -> [HomeJourneyStep]
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
            return .tarotRecommended
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

    // MARK: Twinko Home message (real context only)

    func twinkoMessage(context: HomePersonalizationContext, lang: AppLanguage) -> String {
        // 1. Today's check-in speaks first — it is the freshest state.
        if let checkIn = context.checkIn {
            return message(for: checkIn, lang: lang)
        }
        // 2. A real recent meditation reflection.
        if let record = context.lastMeditation, record.completed {
            if record.finalFeeling == MeditationMood.calmer.rawValue {
                return lang == .english
                    ? "Last time we sat together you said you felt calmer. Shall we keep a few quiet minutes for you today?"
                    : "上次靜下來之後，你說有比較平靜。今天也想留幾分鐘給自己嗎？"
            }
            return lang == .english
                ? "You made some quiet space for yourself recently. How is your heart today?"
                : "你最近有為自己留過一段安靜的時間，今天心裡還好嗎？"
        }
        // 3. A real recent chat topic (short existing title only).
        if let title = context.lastChatTitle, !title.isEmpty {
            return lang == .english
                ? "We talked about \u{201C}\(title)\u{201D} recently. I'm here whenever you want to pick it up again."
                : "我們之前聊過「\(title)」，想繼續說說的時候，我都在。"
        }
        // 4. Neutral time-of-day fallback — never fabricated context.
        switch (context.hour, lang) {
        case (5..<12, .traditionalChinese): return "新的一天，先跟我說說你現在的感覺吧。"
        case (12..<18, .traditionalChinese): return "午後了，要不要停一下，看看自己現在的狀態？"
        case (_, .traditionalChinese): return "晚上了，今天辛苦了。想跟我說說今天過得怎麼樣嗎？"
        case (5..<12, .english): return "A new day — tell me how you're feeling right now."
        case (12..<18, .english): return "It's the afternoon. Want to pause and check in with yourself?"
        case (_, .english): return "It's evening — you've carried today this far. How was it?"
        }
    }

    // MARK: Today's Companion Journey (three connected steps)

    func journey(for checkIn: DailyCheckIn, lang: AppLanguage) -> [HomeJourneyStep] {
        let en = lang == .english
        func step(_ index: Int, _ action: HomeAction, _ zhT: String, _ enT: String,
                  _ zhP: String, _ enP: String) -> HomeJourneyStep {
            HomeJourneyStep(index: index, action: action,
                            title: en ? enT : zhT, purpose: en ? enP : zhP)
        }
        let meditationFocus: MeditationFocus =
            checkIn.mood == .anxious ? .releaseAnxiety
            : (checkIn.need == .rest ? .sleep : .calmDown)
        let meditate = HomeAction.meditation(focus: meditationFocus, duration: .three)

        switch checkIn.need {
        case .talk:
            return [step(1, .chat, "聊聊天", "A little talk", "把心裡的話說出來", "Say what's on your mind"),
                    step(2, meditate, "3 分鐘冥想", "Meditate 3 min", "讓心慢慢沉澱", "Let it settle gently"),
                    step(3, .horoscope, "今日星座", "Today's stars", "帶一點光收尾", "Close with a little light")]
        case .ground:
            return [step(1, .chat, "聊聊天", "A little talk", "先說說現在的感覺", "Name the feeling first"),
                    step(2, meditate, "3 分鐘冥想", "Meditate 3 min", "安定呼吸與身體", "Steady your breath"),
                    step(3, .horoscope, "今日星座", "Today's stars", "溫柔地看看今天", "A gentle look at today")]
        case .direction:
            return [step(1, .chat, "聊聊天", "A little talk", "整理心裡的問題", "Sort the question out"),
                    step(2, .tarot, "塔羅指引", "Tarot guidance", "換個角度看看", "See another angle"),
                    step(3, meditate, "冥想收尾", "Meditate to close", "把指引放進心裡", "Let it sink in")]
        case .rest:
            return [step(1, meditate, "冥想", "Meditation", "先放下今天的重量", "Set today down first"),
                    step(2, .music, "音樂", "Music", "讓聲音陪著你", "Let sound keep you company"),
                    step(3, .horoscope, "今日星座", "Today's stars", "輕輕看一眼就好", "Just a soft glance")]
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
/// state: soft warm-gold halo behind the orb, ~5% scale, refined thin
/// highlight, and a small warm-white check — "gently illuminated",
/// never a thick validation ring (never color alone: the check is the
/// non-color signal).
struct MoodOrbView: View {
    let mood: CheckInMood
    let isSelected: Bool
    var size: CGFloat = 52

    var body: some View {
        ZStack {
            if isSelected {
                // Soft warm bloom behind the chosen mood.
                Circle()
                    .fill(Color.twinkoGold)
                    .frame(width: size * 1.20, height: size * 1.20)
                    .blur(radius: size * 0.14)
                    .opacity(0.40)
            }
            // Approved mood artwork used as delivered — no crop, no
            // recolor; glow and shadow stay code-rendered.
            Image(mood.referenceAsset)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .shadow(color: mood.orbColor.opacity(0.45), radius: isSelected ? 8 : 4, y: 2)

            if isSelected {
                // Glowing selection ring hugging the mood ball
                // (approved reference: no gap between ring and face).
                Circle()
                    .strokeBorder(
                        LinearGradient(colors: [Color(hex: 0xFFE9B8).opacity(0.95),
                                                Color(hex: 0xD9C8FF).opacity(0.75)],
                                       startPoint: .top, endPoint: .bottom),
                        lineWidth: 2)
                    .frame(width: size * 1.06, height: size * 1.06)
                    .shadow(color: Color.twinkoGold.opacity(0.55), radius: 4)

                // Check badge rides the lower-right edge, as in the
                // approved reference.
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.17, weight: .bold))
                    .foregroundStyle(Color(hex: 0xFFF8E8))
                    .frame(width: size * 0.30, height: size * 0.30)
                    .background(Color.twinkoGold.opacity(0.95), in: Circle())
                    .offset(x: size * 0.34, y: size * 0.34)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
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
    /// Section title + question copy per home_reference_v2.
    static func checkInTitle(_ l: AppLanguage) -> String {
        l == .english ? "Today's Mood" : "今日心情"
    }
    static func moodQuestion(_ l: AppLanguage) -> String {
        l == .english ? "Which state feels most like you right now?" : "現在的你比較像哪一種狀態？"
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

    // Journey
    /// Small tag above Twinko's speech bubble (reference label).
    static func twinkoSuggests(_ l: AppLanguage) -> String {
        l == .english ? "Twinko Suggests" : "Twinko 建議"
    }
    static func journeyTitle(_ l: AppLanguage) -> String {
        l == .english ? "Today's Companion Journey" : "今天的陪伴旅程"
    }
    /// Quiet right-side caption on the Journey header (reference).
    static func journeyFreeChoice(_ l: AppLanguage) -> String {
        l == .english ? "Pick freely, start anytime" : "自由選擇，隨時開始"
    }

    // Explore More (Home)
    static func exploreMore(_ l: AppLanguage) -> String {
        l == .english ? "Explore" : "探索"
    }
    static func entryTarot(_ l: AppLanguage) -> String { l == .english ? "Tarot" : "塔羅" }
    static func entryTarotDesc(_ l: AppLanguage) -> String {
        l == .english ? "Find guidance" : "尋找指引"
    }
    static func entryHoroscope(_ l: AppLanguage) -> String { l == .english ? "Zodiac" : "星座" }
    static func entryHoroscopeDesc(_ l: AppLanguage) -> String {
        l == .english ? "Today’s energy" : "今日能量"
    }
    static func entryMeditation(_ l: AppLanguage) -> String { l == .english ? "Meditate" : "冥想" }
    static func entryMeditationDesc(_ l: AppLanguage) -> String {
        l == .english ? "Calm your mind" : "平靜身心"
    }
    static func entryMusic(_ l: AppLanguage) -> String { l == .english ? "Music" : "音樂" }
    static func entryMusicDesc(_ l: AppLanguage) -> String {
        l == .english ? "Healing rhythms" : "療癒旋律"
    }
    static func entryActivities(_ l: AppLanguage) -> String { l == .english ? "Activity" : "活動" }
    static func entryActivitiesDesc(_ l: AppLanguage) -> String {
        l == .english ? "Explore nearby" : "探索附近"
    }

    // Explore cosmic map
    static func exploreMapTitle(_ l: AppLanguage) -> String {
        l == .english ? "Explore the Cosmos" : "探索宇宙"
    }

    // Activities placeholder
    static func activitiesComingSoon(_ l: AppLanguage) -> String {
        l == .english
            ? "Local wellbeing experiences will arrive here soon."
            : "附近的療癒活動，很快會在這裡與你見面。"
    }
    static func backLabel(_ l: AppLanguage) -> String {
        l == .english ? "Back" : "返回"
    }

    // My Planet
    static func planetOf(_ name: String, _ l: AppLanguage) -> String {
        l == .english ? "\(name)'s Planet" : "\(name) 的星球"
    }
    static func planetSubtitle(_ l: AppLanguage) -> String {
        l == .english ? "Your quiet corner of the cosmos" : "宇宙裡屬於你的安靜角落"
    }
    static func hubJournal(_ l: AppLanguage) -> String {
        l == .english ? "Reflection Journal" : "覺察紀錄"
    }
    static func hubJournalDesc(_ l: AppLanguage) -> String {
        l == .english ? "Moments you noticed" : "你留意過的心情"
    }
    static func hubMeditation(_ l: AppLanguage) -> String {
        l == .english ? "Meditation History" : "冥想紀錄"
    }
    static func hubMeditationDesc(_ l: AppLanguage) -> String {
        l == .english ? "Quiet time you kept" : "你留下的安靜時光"
    }
    static func hubTarot(_ l: AppLanguage) -> String {
        l == .english ? "Tarot History" : "塔羅紀錄"
    }
    static func hubTarotDesc(_ l: AppLanguage) -> String {
        l == .english ? "Readings you drew" : "你抽過的指引"
    }
    static func hubCards(_ l: AppLanguage) -> String {
        l == .english ? "Saved Guidance Cards" : "收藏小卡"
    }
    static func hubCardsDesc(_ l: AppLanguage) -> String {
        l == .english ? "Cards kept close" : "留在身邊的小卡"
    }
    static func hubProfile(_ l: AppLanguage) -> String {
        l == .english ? "Profile" : "個人資料"
    }
    static func hubProfileDesc(_ l: AppLanguage) -> String {
        l == .english ? "Who you are here" : "在這顆星球上的你"
    }
    static func hubSettings(_ l: AppLanguage) -> String {
        l == .english ? "Settings" : "設定"
    }
    static func hubSettingsDesc(_ l: AppLanguage) -> String {
        l == .english ? "Language and controls" : "語言與偏好"
    }
    static func hubComingSoon(_ l: AppLanguage) -> String {
        l == .english
            ? "This little station is still being built — your records will live here soon."
            : "這個小站還在建造中，你的紀錄很快會住進來。"
    }

    // Tabs
    static func tabHome(_ l: AppLanguage) -> String { l == .english ? "Home" : "首頁" }
    static func tabChat(_ l: AppLanguage) -> String { l == .english ? "Chat" : "聊天" }
    static func tabExplore(_ l: AppLanguage) -> String { l == .english ? "Explore" : "探索" }
    static func tabMyPlanet(_ l: AppLanguage) -> String { l == .english ? "My Planet" : "我的星球" }
    static func settings(_ l: AppLanguage) -> String { l == .english ? "Settings" : "設定" }
}

// MARK: - Task 3: Home → Tarot contextual mappings

extension LocalHomeRecommendationProvider {
    /// Deterministic Home→Tarot mapping from today's check-in only —
    /// no fabricated questions, options, or relationships (§30).
    /// Feeling lost/confused → Core Clarity (feeling stuck); other
    /// direction-seeking states → Situation, Action & Possible
    /// Direction (practical next step). Fields stay empty and
    /// editable in setup.
    func tarotEntryContext(for checkIn: DailyCheckIn,
                           lang: AppLanguage) -> TarotEntryContext {
        let spreadID: TarotSpreadID = checkIn.mood == .confused
            ? .coreClarityFour : .actionDirectionThree
        let summary = lang == .english
            ? "From today's check-in, you're looking for some direction — the cards can help you reflect on it."
            : "從今天的紀錄裡，你想獲得一些方向——牌可以陪你一起想想。"
        return TarotEntryContext(source: .home, kind: .standard,
                                 recommendedSpreadID: spreadID,
                                 contextSummary: summary)
    }
}

extension HomeExperienceStrings {
    /// Daily Tarot recommendation copy on the existing recommendation
    /// surface (Task 3 §15) — calm and optional; no streak or guilt.
    static func dailyTarotPrompt(_ l: AppLanguage) -> String {
        l == .english
            ? "Would you like to look more deeply at what your body, mind, and inner self may need today?"
            : "想再深入看看今天的身、心與內在需要嗎？"
    }
    static func dailyTarotReady(_ l: AppLanguage) -> String {
        l == .english
            ? "Today's guidance is ready whenever you'd like to revisit it."
            : "今天的指引已經準備好，想回顧時隨時可以看看。"
    }
}
