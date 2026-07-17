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
                recommendationActions(for: checkIn)
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
        VStack(spacing: TwinkoSpacing.s) {
            Text(HomeExperienceStrings.moodQuestion(lang))
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.deepPlum)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                ForEach(CheckInMood.allCases) { mood in
                    let selected = pendingMood == mood
                    Button {
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                            pendingMood = mood
                        }
                    } label: {
                        VStack(spacing: 3) {
                            MoodOrbView(mood: mood, isSelected: selected, size: 44)
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
                Text(HomeExperienceStrings.needQuestion(lang))
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.deepPlum)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                            HStack(spacing: 7) {
                                Image(systemName: need.icon)
                                    .font(.system(size: 13, weight: .medium))
                                Text(need.label(lang))
                                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                            }
                            .foregroundStyle(Color.deepPlum)
                            .frame(maxWidth: .infinity, minHeight: 42)
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
        .padding(14)
        .twinkoGlass(cornerRadius: 22, tint: 0.5)
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
                    .frame(width: 104, height: 104)
                    .blur(radius: 20)
                    .opacity(0.30)
                if !reduceMotion {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: "sparkle")
                            .font(.system(size: [7.0, 5.0, 6.0][index]))
                            .foregroundStyle(Color.twinkoGold.opacity(0.75))
                            .offset(x: [-40.0, 44.0, -30.0][index],
                                    y: [-30.0, -12.0, 34.0][index])
                    }
                }
                Image("twinko_default_smile_v1_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .offset(y: reduceMotion ? 0 : (floating ? -5 : 5))
                    .accessibilityLabel(Text("Twinko"))
            }

            TwinkoSpeechBubble {
                Text(recommender.twinkoMessage(context: personalizationContext, lang: lang))
                    .font(.system(.footnote, design: .rounded).weight(.medium))
                    .foregroundStyle(Color.deepPlum)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityIdentifier("homeTwinkoMessage")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: D — Primary recommendation (+ one quiet alternative)

    private func recommendationActions(for checkIn: DailyCheckIn) -> some View {
        let recommendation = recommender.recommendation(for: checkIn, lang: lang)
        return VStack(spacing: 4) {
            Button {
                activeAction = recommendation.primaryAction
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.twinkoGold)
                    Text(recommendation.primaryAction.label(lang))
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(
                    LinearGradient(colors: [.brandPurpleDeep, .brandPurple],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 24)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Color(hex: 0xD9C8FF).opacity(0.6), lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient(colors: [Color.white.opacity(0.18), .clear],
                                             startPoint: .top, endPoint: .center))
                )
                .shadow(color: Color.brandPurpleDeep.opacity(0.4), radius: 8, y: 3)
            }
            .buttonStyle(TwinkoGlassPressStyle())
            .accessibilityIdentifier("homePrimaryAction")

            if let secondary = recommendation.secondaryAction {
                Button {
                    activeAction = secondary
                } label: {
                    Text(secondary.label(lang))
                        .font(.system(.footnote, design: .rounded).weight(.medium))
                        .foregroundStyle(Color.softWhite.opacity(0.85))
                        .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
                        .frame(minHeight: 32)
                }
                .accessibilityIdentifier("homeSecondaryAction")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("homeRecommendationCard")
    }

    // MARK: E — Today's Companion Journey

    private func journeySection(for checkIn: DailyCheckIn) -> some View {
        let steps = recommender.journey(for: checkIn, lang: lang)
        return VStack(alignment: .leading, spacing: 6) {
            Text(HomeExperienceStrings.journeyTitle(lang))
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.softWhite)
                .shadow(color: .black.opacity(0.25), radius: 2, y: 1)

            HStack(spacing: 0) {
                ForEach(steps) { step in
                    if step.index > 1 {
                        // Tiny constellation path between steps.
                        VStack(spacing: 1) {
                            Image(systemName: "sparkle")
                                .font(.system(size: 7))
                                .foregroundStyle(Color.twinkoGold.opacity(0.9))
                            Rectangle()
                                .fill(Color.twinkoGold.opacity(0.4))
                                .frame(width: 12, height: 1)
                        }
                        .frame(width: 14)
                        .accessibilityHidden(true)
                    }
                    journeyStepCard(step)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("homeJourney")
    }

    private func journeyStepCard(_ step: HomeJourneyStep) -> some View {
        Button {
            activeAction = step.action
        } label: {
            VStack(spacing: 3) {
                HStack(spacing: 4) {
                    Text("\(step.index)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.inkNavy)
                        .frame(width: 15, height: 15)
                        .background(Color.twinkoGold, in: Circle())
                    Image(systemName: journeyIcon(step.action))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.brandPurpleDeep)
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
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 64)
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .twinkoGlass(cornerRadius: 18, tint: 0.42, selected: step.index == 1)
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(TwinkoGlassPressStyle())
        .accessibilityIdentifier("journeyStep-\(step.index)")
        .accessibilityLabel(Text("\(step.index). \(step.title)，\(step.purpose)"))
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
        VStack(alignment: .leading, spacing: 6) {
            Text(HomeExperienceStrings.exploreMore(lang))
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.softWhite.opacity(0.85))
                .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
            HStack(spacing: 6) {
                exploreEntry(.tarot, glyph: "moon.stars.fill", tint: Color(hex: 0x6B4BA8),
                             title: HomeExperienceStrings.entryTarot(lang),
                             desc: HomeExperienceStrings.entryTarotDesc(lang))
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
                exploreEntry(.activities, glyph: "location.fill", tint: Color(hex: 0xC77B4E),
                             title: HomeExperienceStrings.entryActivities(lang),
                             desc: HomeExperienceStrings.entryActivitiesDesc(lang))
            }
        }
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
