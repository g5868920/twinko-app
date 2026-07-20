import SwiftUI

/// Home — the personal starting point (companion-universe redesign
/// 2026-07-17): time-aware greeting → Daily Check-in (glossy mood
/// orbs + need chips, collapsing after completion) → Twinko with a
/// conversational speech bubble grounded in real local context → one
/// primary recommendation (+ one quieter alternative) → Today's
/// Companion Journey (three connected steps) → compact Explore More.
/// One screen on standard iPhones (no normal scrolling); the expanded
/// edit state and accessibility sizes may scroll. No Settings icon —
/// Settings lives in My Planet.
struct HomeView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var prefs: PrefsStore
    @EnvironmentObject private var chatStore: ChatStore
    @EnvironmentObject private var chrome: ShellChrome
    @EnvironmentObject private var dailyTarot: DailyTarotStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @StateObject private var checkInStore = CheckInStore()
    @StateObject private var meditationRecords = MeditationRecordStore()
    private let recommender: HomeRecommendationProviding = LocalHomeRecommendationProvider()

    @State private var floating = false
    @State private var twinkoBounce = false
    @State private var pendingMood: CheckInMood?
    @State private var editingCheckIn = false
    @State private var activeAction: HomeAction?

    private var lang: AppLanguage { prefs.language }
    private var todayCheckIn: DailyCheckIn? { checkInStore.today }

    /// Real, locally available context only (existing summaries and
    /// records — never transcripts, never fabricated events).
    private var personalizationContext: HomePersonalizationContext {
        HomePersonalizationContext(
            checkIn: todayCheckIn,
            lastChatTitle: chatStore.sessions.first.map { $0.displayTitle(for: lang) },
            lastMeditation: meditationRecords.records.last)
    }

    /// Expanded selectors (initial or Edit) may need vertical room;
    /// accessibility sizes always may.
    private var allowsScrolling: Bool {
        editingCheckIn || dynamicTypeSize.isAccessibilitySize
    }

    var body: some View {
        Group {
            if allowsScrolling {
                ScrollView { content }
            } else {
                content
            }
        }
        .background {
            ZStack {
                TwinkoFullScreenBackground(imageName: TwinkoBackgrounds.homeResolved,
                                           topOpacity: 0.10, bottomOpacity: 0.14)
                // Soft mist (readability pass 2026-07-18): gently mutes
                // the artwork's detail behind the reading cards without
                // washing the scene.
                Color.white.opacity(0.10).ignoresSafeArea()
            }
        }
        .dockClearance()
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $activeAction) { action in
            destination(for: action)
        }
        .onAppear { updateFloating(active: chrome.selectedTab == .home) }
        .onChange(of: chrome.selectedTab) { _, tab in
            updateFloating(active: tab == .home)
        }
    }

    private var content: some View {
        VStack(spacing: TwinkoSpacing.s) {
            greetingHeader
            checkInCard
            twinkoAndBubble
            if let checkIn = todayCheckIn, !editingCheckIn {
                journeySection(for: checkIn)
            }
            Spacer(minLength: 0)
            exploreMore
        }
        .padding(.horizontal, 20)
        .padding(.top, TwinkoSpacing.s)
        .padding(.bottom, TwinkoSpacing.s)
    }

    // MARK: A — Greeting (no Settings icon; Settings lives in My Planet)

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(HomeExperienceStrings.greeting(lang,
                                                name: profileStore.profile?.preferredName) + " ✨")
                .font(.system(size: 27, weight: .bold, design: .rounded))
                .foregroundStyle(Color.softWhite)
                .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
            Text(HomeExperienceStrings.greetingSupport(lang))
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(Color.softWhite.opacity(0.85))
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: B — Daily Check-in

    @ViewBuilder
    private var checkInCard: some View {
        if let checkIn = todayCheckIn, !editingCheckIn {
            collapsedCheckIn(checkIn)
        } else {
            activeCheckIn
        }
    }

    private var activeCheckIn: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            // Reference header: ✨ 今日心情 + the state question.
            HStack(spacing: 5) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.twinkoGold)
                Text(HomeExperienceStrings.checkInTitle(lang))
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(Color.deepPlum)
            }
            Text(HomeExperienceStrings.moodQuestion(lang))
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(Color.deepPlum.opacity(0.7))

            HStack(spacing: 4) {
                ForEach(CheckInMood.allCases) { mood in
                    let selected = pendingMood == mood
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                            pendingMood = mood
                        }
                    } label: {
                        VStack(spacing: 3) {
                            MoodOrbView(mood: mood, isSelected: selected, size: 48)
                            Text(mood.label(lang))
                                .font(.system(size: 11, design: .rounded)
                                    .weight(selected ? .bold : .regular))
                                .foregroundStyle(Color.deepPlum)
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .accessibilityIdentifier("mood-\(mood.rawValue)")
                    .accessibilityLabel(Text(selected
                        ? (lang == .english ? "\(mood.label(lang)), selected"
                                            : "\(mood.label(lang))，已選取")
                        : mood.label(lang)))
                    .accessibilityAddTraits(selected ? [.isSelected] : [])
                }
            }

            if let mood = pendingMood {
                Rectangle()
                    .fill(Color.white.opacity(0.25))
                    .frame(height: 1)
                    .padding(.vertical, 1)
                    .accessibilityHidden(true)
                    .transition(.opacity)
                Text(HomeExperienceStrings.needQuestion(lang))
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.deepPlum)
                    .transition(.opacity)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8),
                                    GridItem(.flexible(), spacing: 8)], spacing: 8) {
                    ForEach(CheckInNeed.allCases) { need in
                        Button {
                            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
                                checkInStore.save(mood: mood, need: need)
                                pendingMood = nil
                                editingCheckIn = false
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            // Reference chip: small filled icon square +
                            // leading-aligned label.
                            HStack(spacing: 8) {
                                Image(systemName: need.icon)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.softWhite)
                                    .frame(width: 24, height: 24)
                                    .background(Color.brandPurple.opacity(0.85),
                                                in: RoundedRectangle(cornerRadius: 8))
                                // Fixed size sized to the longest EN
                                // label ("Find Direction") so all four
                                // chips share one type size — the old
                                // per-chip auto-shrink left Rest/Talk
                                // visibly larger.
                                Text(need.label(lang))
                                    .font(.system(size: 13, weight: .medium,
                                                  design: .rounded))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.9)
                                Spacer(minLength: 0)
                            }
                            .foregroundStyle(Color.deepPlum)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .twinkoGlass(cornerRadius: 16, tint: 0.24)
                            .contentShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .accessibilityIdentifier("need-\(need.rawValue)")
                        .accessibilityLabel(Text(need.label(lang)))
                    }
                }
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .twinkoGlass(cornerRadius: 24, tint: 0.34)
        .accessibilityElement(children: .contain)
    }

    private func collapsedCheckIn(_ checkIn: DailyCheckIn) -> some View {
        HStack(spacing: TwinkoSpacing.s) {
            MoodOrbView(mood: checkIn.mood, isSelected: false, size: 30)
            VStack(alignment: .leading, spacing: 1) {
                Text("\(HomeExperienceStrings.summaryMood(lang))：\(checkIn.mood.label(lang))")
                    .font(.system(.footnote, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.deepPlum)
                Text("\(HomeExperienceStrings.summaryNeed(lang))：\(checkIn.need.label(lang))")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.deepPlum.opacity(0.65))
            }
            Spacer()
            Button {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                    pendingMood = checkIn.mood
                    editingCheckIn = true
                }
            } label: {
                Text(HomeExperienceStrings.edit(lang))
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.brandPurpleDeep)
                    .padding(.horizontal, 12)
                    .frame(minHeight: 30)
                    .twinkoGlass(cornerRadius: 15, tint: 0.28)
                    .frame(minHeight: 44)
                    .contentShape(Capsule())
            }
            .buttonStyle(TwinkoHapticPressStyle())
            .accessibilityIdentifier("checkInEditButton")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .twinkoGlass(cornerRadius: 20, tint: 0.30)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("checkInSummary")
    }

    // MARK: C — Twinko + conversational speech bubble

    private var twinkoAndBubble: some View {
        HStack(alignment: .center, spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.97, blue: 0.88))
                    .frame(width: 134, height: 134)
                    .blur(radius: 24)
                    .opacity(0.34)
                if !reduceMotion {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: "sparkle")
                            .font(.system(size: [7.0, 5.0, 6.0][index]))
                            .foregroundStyle(Color.twinkoGold.opacity(0.75))
                            .offset(x: [-46.0, 50.0, -34.0][index],
                                    y: [-34.0, -14.0, 38.0][index])
                    }
                }
                // PERMANENT (founder rule 2026-07-18): the Home Twinko
                // always floats gently — never remove this motion in
                // future passes. The shared twinkoFloat modifier keeps
                // the drift small and scoped to this image only.
                // Tapping Twinko answers with a soft haptic and a
                // jelly bounce (founder request 2026-07-18).
                Image("twinko_default_smile_v1_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 122, height: 122)
                    .scaleEffect(twinkoBounce ? 1.07 : 1.0)
                    .twinkoFloat(active: floating, amplitude: 5, duration: 3.0)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.38)) {
                            twinkoBounce = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                twinkoBounce = false
                            }
                        }
                    }
                    .accessibilityLabel(Text("Twinko"))
                    .accessibilityAddTraits(.isButton)
            }

            VStack(alignment: .leading, spacing: 3) {
                // Small "Twinko Suggests" tag from the reference —
                // one tiny star, never another header card.
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(Color.twinkoGold)
                    Text(HomeExperienceStrings.twinkoSuggests(lang))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.deepPlum.opacity(0.8))
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 3)
                .twinkoGlass(cornerRadius: 10, tint: 0.3)
                // Align the tag with the bubble BODY: the bubble shape
                // reserves 10 pt on its left for the integrated tail.
                .padding(.leading, 10)
                .accessibilityHidden(true)

                // The reference embeds the recommendation inside the
                // speech bubble: Twinko speaks, then offers the best
                // next step and one quieter alternative. Existing
                // provider and routing untouched.
                TwinkoSpeechBubble {
                    VStack(alignment: .leading, spacing: 9) {
                        // The identifier lives on the message Text only:
                        // on the bubble container it broadcasts to every
                        // element inside and masks the action buttons'
                        // own identifiers (found in the Task 3 Daily
                        // walkthrough).
                        Text(recommender.twinkoMessage(context: personalizationContext, lang: lang))
                            .font(.system(.footnote, design: .rounded).weight(.medium))
                            .foregroundStyle(Color.deepPlum)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("homeTwinkoMessage")
                        if let checkIn = todayCheckIn, !editingCheckIn {
                            bubbleActions(for: checkIn)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("homeRecommendationCard")
    }

    // MARK: D — Recommendation actions inside the bubble (reference)

    private func bubbleActions(for checkIn: DailyCheckIn) -> some View {
        let recommendation = recommender.recommendation(for: checkIn, lang: lang)
        return VStack(spacing: 4) {
            Button {
                activeAction = recommendation.primaryAction
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: journeyIcon(recommendation.primaryAction))
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: 0xE9DFFB))
                    Text(recommendation.primaryAction.label(lang))
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    LinearGradient(colors: [.brandPurpleDeep, .brandPurple],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: Capsule()
                )
                .overlay(Capsule().strokeBorder(Color(hex: 0xD9C8FF).opacity(0.6),
                                                lineWidth: 1))
                .overlay(
                    Capsule().fill(LinearGradient(
                        colors: [Color.white.opacity(0.18), .clear],
                        startPoint: .top, endPoint: .center))
                )
                .shadow(color: Color.brandPurpleDeep.opacity(0.35), radius: 6, y: 2)
            }
            .buttonStyle(TwinkoGlassPressStyle())
            .accessibilityIdentifier("homePrimaryAction")

            if let secondary = recommendation.secondaryAction {
                // Quieter in-bubble text link with a chevron.
                Button {
                    activeAction = secondary
                } label: {
                    HStack(spacing: 3) {
                        Text(secondary.label(lang))
                            .font(.system(.footnote, design: .rounded).weight(.semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Color.brandPurpleDeep)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .contentShape(Rectangle())
                }
                .buttonStyle(TwinkoHapticPressStyle())
                .accessibilityIdentifier("homeSecondaryAction")
            }

            // Task 3 — Daily Tarot Check-in on the existing
            // recommendation surface (no new Home section): quiet,
            // optional, and calm. Completed state switches to View
            // Today's Guidance for the rest of the local day.
            dailyTarotRow
        }
    }

    @ViewBuilder
    private var dailyTarotRow: some View {
        let completed = dailyTarot.isTodayCompleted
        VStack(spacing: 2) {
            Text(completed
                 ? HomeExperienceStrings.dailyTarotReady(lang)
                 : HomeExperienceStrings.dailyTarotPrompt(lang))
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Color.deepPlum.opacity(0.75))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                activeAction = completed ? .dailyTarotResult : .dailyTarot
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: completed ? "moon.stars.fill" : "moon.stars")
                        .font(.system(size: 11, weight: .semibold))
                    Text((completed ? HomeAction.dailyTarotResult : .dailyTarot)
                        .label(lang))
                        .font(.system(.footnote, design: .rounded).weight(.semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(Color.brandPurpleDeep)
                .frame(maxWidth: .infinity, minHeight: 40)
                .contentShape(Rectangle())
            }
            .buttonStyle(TwinkoHapticPressStyle())
            .accessibilityIdentifier(completed ? "homeDailyTarotResult" : "homeDailyTarot")
            .accessibilityLabel(Text(completed
                ? (lang == .english ? "Today's guidance is available" : "今天的指引已經可以查看")
                : (lang == .english ? "Today's Tarot check-in has not been completed" : "今天的塔羅檢視還沒完成")))
        }
    }

    // MARK: E — Today's Companion Journey

    /// One glass container per the reference: ✨ title + quiet
    /// "pick freely" caption, then three connected step cards.
    private func journeySection(for checkIn: DailyCheckIn) -> some View {
        let steps = recommender.journey(for: checkIn, lang: lang)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.twinkoGold)
                    Text(HomeExperienceStrings.journeyTitle(lang))
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(Color.deepPlum)
                }
                Spacer()
                HStack(spacing: 3) {
                    Image(systemName: "heart")
                        .font(.system(size: 9))
                    Text(HomeExperienceStrings.journeyFreeChoice(lang))
                        .font(.system(size: 10, design: .rounded))
                }
                .foregroundStyle(Color.deepPlum.opacity(0.55))
            }

            HStack(spacing: 0) {
                ForEach(steps) { step in
                    if step.index > 1 {
                        // Tiny constellation path between steps.
                        Image(systemName: "sparkle")
                            .font(.system(size: 8))
                            .foregroundStyle(Color.twinkoGold.opacity(0.9))
                            .frame(width: 12)
                            .accessibilityHidden(true)
                    }
                    journeyStepCard(step)
                }
            }
        }
        .padding(12)
        .twinkoGlass(cornerRadius: 22, tint: 0.18)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("homeJourney")
    }

    /// Reference card: tinted icon orb (numbered badge on its corner)
    /// beside title + one-line purpose. Equal treatment for all three
    /// steps — no fabricated progress state.
    private func journeyStepCard(_ step: HomeJourneyStep) -> some View {
        let tint = journeyTint(step.action)
        return Button {
            activeAction = step.action
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topLeading) {
                    // Approved icon artwork on the shared floating orb.
                    HomeFeatureOrb(asset: journeyAsset(step.action),
                                   tint: tint, size: 34)
                        .shadow(color: tint.opacity(0.4), radius: 3, y: 1)
                    Text("\(step.index)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.softWhite)
                        .frame(width: 15, height: 15)
                        .background(tint, in: Circle())
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.7),
                                                       lineWidth: 1))
                        .offset(x: -5, y: -5)
                }
                Text(step.title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.deepPlum)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(step.purpose)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(Color.deepPlum.opacity(0.6))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity, minHeight: 72)
            .padding(.vertical, 7)
            .padding(.horizontal, 4)
            .twinkoGlass(cornerRadius: 16, tint: 0.42)
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(TwinkoGlassPressStyle())
        .accessibilityIdentifier("journeyStep-\(step.index)")
        .accessibilityLabel(Text("\(step.index). \(step.title)，\(step.purpose)"))
    }

    /// Reference orb tints per destination family.
    private func journeyTint(_ action: HomeAction) -> Color {
        switch action {
        case .chat: return Color(hex: 0x6B9BE8)
        case .meditation: return Color(hex: 0x8E7AE6)
        case .tarot, .tarotRecommended, .dailyTarot, .dailyTarotResult:
            return Color(hex: 0x9A6FD0)
        case .horoscope: return Color(hex: 0xF0A860)
        case .music: return Color(hex: 0xC77BD0)
        case .activities: return Color(hex: 0x5C6FD8)
        }
    }

    private func journeyIcon(_ action: HomeAction) -> String {
        switch action {
        case .chat: return "bubble.left.fill"
        case .meditation: return "moon.zzz.fill"
        case .tarot, .tarotRecommended, .dailyTarot, .dailyTarotResult:
            return "moon.stars.fill"
        case .horoscope: return "star.circle.fill"
        case .music: return "music.note"
        case .activities: return "location.fill"
        }
    }

    /// Approved icon artwork per destination (home_icon_*_v1).
    private func journeyAsset(_ action: HomeAction) -> String {
        switch action {
        case .chat: return "home_icon_chat_v1"
        case .meditation: return "home_icon_meditate_v1"
        case .horoscope: return "home_icon_zodiac_v1"
        case .tarot, .tarotRecommended, .dailyTarot, .dailyTarotResult:
            return "home_icon_tarot_v1"
        case .music: return "home_icon_music_v1"
        case .activities: return "home_icon_activity_v1"
        }
    }

    // MARK: F — Explore More (five cosmic orbs)

    private var exploreMore: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: "sparkle")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.twinkoGold)
                Text(HomeExperienceStrings.exploreMore(lang))
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(Color.softWhite)
                    .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
            }
            HStack(spacing: 6) {
                exploreEntry(.tarot, asset: "home_icon_tarot_v1",
                             tint: Color(hex: 0x6B4BA8),
                             title: HomeExperienceStrings.entryTarot(lang),
                             desc: HomeExperienceStrings.entryTarotDesc(lang))
                exploreEntry(.horoscope, asset: "home_icon_zodiac_v1",
                             tint: Color(hex: 0x4E5FB8),
                             title: HomeExperienceStrings.entryHoroscope(lang),
                             desc: HomeExperienceStrings.entryHoroscopeDesc(lang))
                exploreEntry(.meditation(focus: .calmDown, duration: .five),
                             asset: "home_icon_meditate_v1", tint: Color(hex: 0x5D7BC8),
                             title: HomeExperienceStrings.entryMeditation(lang),
                             desc: HomeExperienceStrings.entryMeditationDesc(lang))
                exploreEntry(.music, asset: "home_icon_music_v1",
                             tint: Color(hex: 0x9A4FB0),
                             title: HomeExperienceStrings.entryMusic(lang),
                             desc: HomeExperienceStrings.entryMusicDesc(lang))
                exploreEntry(.activities, asset: "home_icon_activity_v1",
                             tint: Color(hex: 0x5C6FD8),
                             title: HomeExperienceStrings.entryActivities(lang),
                             desc: HomeExperienceStrings.entryActivitiesDesc(lang))
            }
        }
        .padding(10)
        .twinkoGlass(cornerRadius: 22, tint: 0.18)
    }

    /// One explore item: approved transparent icon artwork on the
    /// shared soft-3D floating orb.
    private func exploreEntry(_ action: HomeAction, asset: String, tint: Color,
                              title: String, desc: String) -> some View {
        Button {
            activeAction = action
        } label: {
            VStack(spacing: 3) {
                HomeFeatureOrb(asset: asset, tint: tint, size: 44)
                    .shadow(color: tint.opacity(0.45), radius: 4, y: 2)
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.softWhite)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                Text(desc)
                    .font(.system(size: 9, design: .rounded))
                    .foregroundStyle(Color.softWhite.opacity(0.75))
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            // Height must fit the 44 pt orb + title + desc + spacing;
            // an undersized minHeight let the VStack overflow up (into
            // the 探索 header) and down (past the container edge).
            .frame(maxWidth: .infinity, minHeight: 82)
            .contentShape(Rectangle())
        }
        .buttonStyle(TwinkoGlassPressStyle())
        .accessibilityIdentifier("homeEntry-\(action.id)")
        .accessibilityLabel(Text("\(title)，\(desc)"))
    }

    // MARK: Routing

    @ViewBuilder
    private func destination(for action: HomeAction) -> some View {
        switch action {
        case .chat:
            ChatView()
        case .meditation(let focus, let duration):
            MeditationFlowView(sourceContext: checkInMeditationContext(
                focus: focus, duration: duration))
        case .tarot:
            TarotFlowView()
        case .tarotRecommended:
            // Contextual standard Home entry: recommended setup from
            // today's check-in via the shared entry-context boundary.
            if let checkIn = todayCheckIn {
                TarotFlowView(entryContext: LocalHomeRecommendationProvider()
                    .tarotEntryContext(for: checkIn, lang: lang))
            } else {
                TarotFlowView()
            }
        case .dailyTarot:
            TarotFlowView(entryContext: .daily(lang: lang))
        case .dailyTarotResult:
            // Reopen the exact completed current-day reading. If the
            // stored snapshot cannot be restored, fall back safely to
            // the standard Tarot entry (no redraw under the same
            // completion, no crash).
            if let restored = dailyTarot.restoredTodaySession() {
                TarotFlowView(restoredSession: restored)
            } else {
                TarotFlowView()
            }
        case .horoscope:
            HoroscopeTodayView()
        case .music:
            MusicPlaceholderView()
        case .activities:
            ActivitiesComingSoonView()
        }
    }

    /// Check-in → Meditation handoff (existing contract).
    private func checkInMeditationContext(focus: MeditationFocus,
                                          duration: MeditationDuration)
        -> MeditationSourceContext {
        guard let checkIn = todayCheckIn else { return .direct }
        let summary = lang == .english
            ? "Today you're feeling \(checkIn.mood.label(lang).lowercased()) and want to \(checkIn.need.label(lang).lowercased())."
            : "今天感覺\(checkIn.mood.label(lang))，想要\(checkIn.need.label(lang))。"
        return MeditationSourceContext(sourceType: .checkIn,
                                       focusSummary: summary,
                                       recommendedFocus: focus)
    }

    /// Twinko's float runs only while Home is the frontmost tab; the
    /// shared twinkoFloat modifier owns the animation itself.
    private func updateFloating(active: Bool) {
        floating = active
    }
}

// MARK: - Feature orb

/// Approved feature icon rendered as delivered: the 2026-07-21 batch
/// bakes the circular orb background into the artwork itself, so the
/// component draws no circle, highlight, or rim of its own — only the
/// asset (tint kept for the caller's floating shadow).
struct HomeFeatureOrb: View {
    let asset: String
    let tint: Color
    var size: CGFloat = 44

    var body: some View {
        Image(asset)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

// MARK: - Speech bubble

/// Warm translucent conversational bubble — one continuous shape with
/// the tail integrated into the outline (founder request 2026-07-18),
/// carrying the exact same warm speech-glass material as the other
/// containers: gradient fill, inner top highlight, luminous rim,
/// floating shadow.
struct TwinkoSpeechBubble<Content: View>: View {
    @ViewBuilder var content: () -> Content

    private var shape: TwinkoSpeechBubbleShape { TwinkoSpeechBubbleShape() }

    var body: some View {
        content()
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .padding(.leading, 10)   // room for the integrated tail
            .background {
                shape
                    .fill(LinearGradient(
                        colors: [Color(hex: 0xFFF3E6).opacity(0.59),
                                 Color(hex: 0xEFD9EE).opacity(0.44)],
                        startPoint: .top, endPoint: .bottom))
                    .overlay(
                        shape.fill(LinearGradient(stops: [
                            .init(color: Color.white.opacity(0.24), location: 0),
                            .init(color: Color.white.opacity(0), location: 0.30),
                        ], startPoint: .top, endPoint: .bottom))
                    )
            }
            .overlay(
                shape.stroke(
                    LinearGradient(stops: [
                        .init(color: Color.white.opacity(0.75), location: 0),
                        .init(color: Color.white.opacity(0.35), location: 0.3),
                        .init(color: Color(hex: 0xD1C4FF).opacity(0.30), location: 1),
                    ], startPoint: .top, endPoint: .bottom),
                    lineWidth: 1)
            )
            .shadow(color: Color.deepSpace.opacity(0.12), radius: 16, y: 7)
    }
}

/// Rounded-rectangle speech bubble with a smooth tail on the left
/// edge, drawn as one continuous outline (no seam between tail and
/// body).
struct TwinkoSpeechBubbleShape: Shape {
    var cornerRadius: CGFloat = 18
    var tailWidth: CGFloat = 10
    var tailHeight: CGFloat = 18

    func path(in rect: CGRect) -> Path {
        let r = min(cornerRadius, rect.height / 2)
        let left = rect.minX + tailWidth
        let midY = rect.midY
        var p = Path()
        p.move(to: CGPoint(x: left + r, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        p.addArc(center: CGPoint(x: rect.maxX - r, y: rect.minY + r), radius: r,
                 startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        p.addArc(center: CGPoint(x: rect.maxX - r, y: rect.maxY - r), radius: r,
                 startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        p.addLine(to: CGPoint(x: left + r, y: rect.maxY))
        p.addArc(center: CGPoint(x: left + r, y: rect.maxY - r), radius: r,
                 startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        p.addLine(to: CGPoint(x: left, y: midY + tailHeight / 2))
        p.addQuadCurve(to: CGPoint(x: rect.minX, y: midY),
                       control: CGPoint(x: left - tailWidth * 0.75,
                                        y: midY + tailHeight * 0.16))
        p.addQuadCurve(to: CGPoint(x: left, y: midY - tailHeight / 2),
                       control: CGPoint(x: left - tailWidth * 0.75,
                                        y: midY - tailHeight * 0.16))
        p.addLine(to: CGPoint(x: left, y: rect.minY + r))
        p.addArc(center: CGPoint(x: left + r, y: rect.minY + r), radius: r,
                 startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        p.closeSubpath()
        return p
    }
}

#Preview {
    AppShellView()
        .environmentObject(ProfileStore())
        .environmentObject(PrefsStore())
        .environmentObject(ChatStore())
}
