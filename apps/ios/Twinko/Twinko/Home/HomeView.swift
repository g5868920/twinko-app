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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @StateObject private var checkInStore = CheckInStore()
    @StateObject private var meditationRecords = MeditationRecordStore()
    private let recommender: HomeRecommendationProviding = LocalHomeRecommendationProvider()

    @State private var floating = false
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
            TwinkoFullScreenBackground(imageName: TwinkoBackgrounds.homeResolved,
                                       topOpacity: 0.20, bottomOpacity: 0.30)
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
                                Text(need.label(lang))
                                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Spacer(minLength: 0)
                            }
                            .foregroundStyle(Color.deepPlum)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .twinkoGlass(cornerRadius: 16, tint: 0.3)
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
        .twinkoGlass(cornerRadius: 24, tint: 0.5)
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
                    .twinkoGlass(cornerRadius: 15, tint: 0.35)
                    .frame(minHeight: 44)
                    .contentShape(Capsule())
            }
            .accessibilityIdentifier("checkInEditButton")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .twinkoGlass(cornerRadius: 20, tint: 0.45)
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
                Image("twinko_default_smile_v1_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 122, height: 122)
                    .offset(y: reduceMotion ? 0 : (floating ? -5 : 5))
                    .accessibilityLabel(Text("Twinko"))
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
                .twinkoGlass(cornerRadius: 10, tint: 0.4)
                .accessibilityHidden(true)

                // The reference embeds the recommendation inside the
                // speech bubble: Twinko speaks, then offers the best
                // next step and one quieter alternative. Existing
                // provider and routing untouched.
                TwinkoSpeechBubble {
                    VStack(alignment: .leading, spacing: 9) {
                        Text(recommender.twinkoMessage(context: personalizationContext, lang: lang))
                            .font(.system(.footnote, design: .rounded).weight(.medium))
                            .foregroundStyle(Color.deepPlum)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                        if let checkIn = todayCheckIn, !editingCheckIn {
                            bubbleActions(for: checkIn)
                        }
                    }
                }
                .accessibilityIdentifier("homeTwinkoMessage")
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
                .accessibilityIdentifier("homeSecondaryAction")
            }
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
        .twinkoGlass(cornerRadius: 22, tint: 0.4)
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
                    Circle()
                        .fill(
                            RadialGradient(colors: [tint.opacity(0.95), tint.opacity(0.7)],
                                           center: .init(x: 0.35, y: 0.3),
                                           startRadius: 2, endRadius: 22)
                        )
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.4),
                                                       lineWidth: 1))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: journeyIcon(step.action))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.softWhite)
                        )
                    Text("\(step.index)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.inkNavy)
                        .frame(width: 14, height: 14)
                        .background(Color.twinkoGold, in: Circle())
                        .offset(x: -4, y: -4)
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
            .twinkoGlass(cornerRadius: 16, tint: 0.35)
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
        case .tarot: return Color(hex: 0x9A6FD0)
        case .horoscope: return Color(hex: 0xF0A860)
        case .music: return Color(hex: 0xC77BD0)
        case .activities: return Color(hex: 0x5C6FD8)
        }
    }

    private func journeyIcon(_ action: HomeAction) -> String {
        switch action {
        case .chat: return "bubble.left.fill"
        case .meditation: return "moon.zzz.fill"
        case .tarot: return "moon.stars.fill"
        case .horoscope: return "star.circle.fill"
        case .music: return "music.note"
        case .activities: return "location.fill"
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
                // Tarot uses the same mini-card-with-star identity as
                // its Explore-map planet (spec icon concept).
                Button {
                    activeAction = .tarot
                } label: {
                    VStack(spacing: 3) {
                        TwinkoCosmicOrb(diameter: 42, tint: Color(hex: 0x6B4BA8)) {
                            RoundedRectangle(cornerRadius: 2.5)
                                .strokeBorder(Color(hex: 0xF6F0FF), lineWidth: 1.3)
                                .frame(width: 13, height: 18)
                                .overlay(Image(systemName: "star.fill").font(.system(size: 6)))
                                .rotationEffect(.degrees(-8))
                        }
                        Text(HomeExperienceStrings.entryTarot(lang))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.softWhite)
                            .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                        Text(HomeExperienceStrings.entryTarotDesc(lang))
                            .font(.system(size: 9, design: .rounded))
                            .foregroundStyle(Color.softWhite.opacity(0.75))
                            .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(TwinkoGlassPressStyle())
                .accessibilityIdentifier("homeEntry-\(HomeAction.tarot.id)")
                .accessibilityLabel(Text("\(HomeExperienceStrings.entryTarot(lang))，\(HomeExperienceStrings.entryTarotDesc(lang))"))
                exploreEntry(.horoscope, glyph: "star.circle.fill", tint: Color(hex: 0x4E5FB8),
                             title: HomeExperienceStrings.entryHoroscope(lang),
                             desc: HomeExperienceStrings.entryHoroscopeDesc(lang))
                exploreEntry(.meditation(focus: .calmDown, duration: .five),
                             glyph: "moon.zzz.fill", tint: Color(hex: 0x5D7BC8),
                             title: HomeExperienceStrings.entryMeditation(lang),
                             desc: HomeExperienceStrings.entryMeditationDesc(lang))
                exploreEntry(.music, glyph: "music.note", tint: Color(hex: 0x9A4FB0),
                             title: HomeExperienceStrings.entryMusic(lang),
                             desc: HomeExperienceStrings.entryMusicDesc(lang))
                exploreEntry(.activities, glyph: "location.fill", tint: Color(hex: 0x5C6FD8),
                             title: HomeExperienceStrings.entryActivities(lang),
                             desc: HomeExperienceStrings.entryActivitiesDesc(lang))
            }
        }
        .padding(10)
        .twinkoGlass(cornerRadius: 22, tint: 0.28)
    }

    private func exploreEntry(_ action: HomeAction, glyph: String, tint: Color,
                              title: String, desc: String) -> some View {
        Button {
            activeAction = action
        } label: {
            VStack(spacing: 3) {
                TwinkoCosmicOrb(diameter: 42, tint: tint) {
                    Image(systemName: glyph).font(.system(size: 15, weight: .medium))
                }
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
            .frame(maxWidth: .infinity, minHeight: 44)
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

    /// Twinko's float runs only while Home is the frontmost tab.
    private func updateFloating(active: Bool) {
        if active && !reduceMotion {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                floating = true
            }
        } else {
            withAnimation(.linear(duration: 0.05)) { floating = false }
        }
    }
}

// MARK: - Speech bubble

/// Warm translucent conversational bubble with a tail pointing toward
/// Twinko — never a generic rectangular card.
struct TwinkoSpeechBubble<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .twinkoGlass(cornerRadius: 18, tint: 0.5)
            .overlay(alignment: .leading) {
                SpeechBubbleTail()
                    .fill(Color(hex: 0xF3ECFA).opacity(0.85))
                    .frame(width: 10, height: 14)
                    .offset(x: -8)
                    .accessibilityHidden(true)
            }
    }
}

private struct SpeechBubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY),
                          control: CGPoint(x: rect.midX, y: rect.midY * 0.6))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                          control: CGPoint(x: rect.midX, y: rect.midY * 1.4))
        path.closeSubpath()
        return path
    }
}

#Preview {
    AppShellView()
        .environmentObject(ProfileStore())
        .environmentObject(PrefsStore())
        .environmentObject(ChatStore())
}
