import SwiftUI

/// The daily-companion Home (redesign 2026-07-16): greeting header
/// with a direct Settings gear, progressive Daily Check-in (mood →
/// need), the floating Twinko hero, one personalized recommendation
/// with a quieter alternative, a conditional continuation card, and
/// compact Explore shortcuts — all over the approved home_screen_v1
/// background with a readability overlay. Bottom navigation lives in
/// AppShellView.
struct HomeView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var prefs: PrefsStore
    @EnvironmentObject private var chatStore: ChatStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @EnvironmentObject private var chrome: ShellChrome
    @StateObject private var checkInStore = CheckInStore()
    private let recommender: HomeRecommendationProviding = LocalHomeRecommendationProvider()

    @State private var floating = false
    @State private var showingSettings = false
    @State private var pendingMood: CheckInMood?
    @State private var editingCheckIn = false
    @State private var activeAction: HomeAction?

    private var lang: AppLanguage { prefs.language }
    private var todayCheckIn: DailyCheckIn? { checkInStore.today }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: TwinkoSpacing.m) {
                    greetingHeader
                    checkInCard
                    hero
                    if let checkIn = todayCheckIn, !editingCheckIn {
                        recommendationCard(for: checkIn)
                    }
                    continuationCard
                    exploreShortcuts
                }
                .padding(.horizontal, TwinkoSpacing.m)
                .padding(.bottom, TwinkoSpacing.l)
            }
        }
        .background {
            GeometryReader { geo in
                ZStack {
                    Image("home_screen_v1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    // Readability treatment: content areas dim gently,
                    // the world stays warm around Twinko.
                    LinearGradient(
                        stops: [
                            .init(color: Color.deepSpace.opacity(0.24), location: 0),
                            .init(color: Color.deepSpace.opacity(0.10), location: 0.45),
                            .init(color: Color.deepSpace.opacity(0.30), location: 1),
                        ],
                        startPoint: .top, endPoint: .bottom)
                }
                .accessibilityHidden(true)
            }
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingSettings) {
            SettingsSheetView()
        }
        .navigationDestination(item: $activeAction) { action in
            destination(for: action)
        }
        .onAppear {
            startFloating()
            // Returning to the tab root ends any immersive flow.
            chrome.tabBarHidden = false
        }
    }

    // MARK: Greeting header (+ direct Settings gear)

    private var greetingHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(HomeExperienceStrings.greeting(lang,
                                                    name: profileStore.profile?.preferredName))
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(Color.softWhite)
                    .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
                Text(HomeExperienceStrings.greetingSupport(lang))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.softWhite.opacity(0.85))
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
            }
            Spacer()
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.softWhite)
                    .frame(width: 38, height: 38)
                    .background(Color.deepSpace.opacity(0.30), in: Circle())
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .accessibilityLabel(Text(HomeExperienceStrings.settings(lang)))
            .accessibilityIdentifier("homeSettingsButton")
        }
        .padding(.top, TwinkoSpacing.s)
    }

    // MARK: Daily Check-in (progressive disclosure)

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
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.deepPlum)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                ForEach(CheckInMood.allCases) { mood in
                    let selected = pendingMood == mood
                    Button {
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                            pendingMood = mood
                        }
                    } label: {
                        VStack(spacing: 4) {
                            MoodOrbView(mood: mood, isSelected: selected, size: 46)
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

            // Need choices appear only after a mood is chosen.
            if let mood = pendingMood {
                Text(HomeExperienceStrings.needQuestion(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.deepPlum)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
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
                        } label: {
                            HStack(spacing: 7) {
                                Image(systemName: need.icon)
                                    .font(.system(size: 13, weight: .medium))
                                Text(need.label(lang))
                                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                            }
                            .foregroundStyle(Color.deepPlum)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.brandPurple.opacity(0.15),
                                        in: RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(Color.brandPurple.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .accessibilityIdentifier("need-\(need.rawValue)")
                        .accessibilityLabel(Text(need.label(lang)))
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(TwinkoSpacing.m)
        .background(Color.surfacePrimary.opacity(0.92),
                    in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20)
            .strokeBorder(Color.borderSoft, lineWidth: 1))
        .accessibilityElement(children: .contain)
    }

    private func collapsedCheckIn(_ checkIn: DailyCheckIn) -> some View {
        HStack(spacing: TwinkoSpacing.m) {
            MoodOrbView(mood: checkIn.mood, isSelected: false, size: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(HomeExperienceStrings.summaryMood(lang))：\(checkIn.mood.label(lang))")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.deepPlum)
                Text("\(HomeExperienceStrings.summaryNeed(lang))：\(checkIn.need.label(lang))")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.textSecondaryToken)
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
                    .foregroundStyle(Color.linkPurple)
                    .padding(.horizontal, 12)
                    .frame(minHeight: 32)
                    .background(Color.brandPurple.opacity(0.12), in: Capsule())
                    .frame(minHeight: 44)
                    .contentShape(Capsule())
            }
            .accessibilityIdentifier("checkInEditButton")
        }
        .padding(.horizontal, TwinkoSpacing.m)
        .padding(.vertical, 10)
        .background(Color.surfacePrimary.opacity(0.90),
                    in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18)
            .strokeBorder(Color.borderSoft, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("checkInSummary")
    }

    // MARK: Twinko hero

    private var hero: some View {
        ZStack {
            Circle()
                .fill(Color(red: 1.0, green: 0.97, blue: 0.88))
                .frame(width: 150, height: 150)
                .blur(radius: 24)
                .opacity(0.26)
            Image("twinko_default_smile_v1_transparent")
                .resizable()
                .scaledToFit()
                .frame(width: 138, height: 138)
                .offset(y: reduceMotion ? 0 : (floating ? -5 : 5))
                .accessibilityLabel(Text("Twinko"))
        }
        .padding(.vertical, -6)
    }

    private func startFloating() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
            floating = true
        }
    }

    // MARK: Recommendation

    private func recommendationCard(for checkIn: DailyCheckIn) -> some View {
        let recommendation = recommender.recommendation(for: checkIn, lang: lang)
        return VStack(spacing: TwinkoSpacing.s) {
            Text(recommendation.message)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.deepPlum)
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                activeAction = recommendation.primaryAction
            } label: {
                Text(recommendation.primaryAction.label(lang))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.twinkoPrimary)
            .accessibilityIdentifier("homePrimaryAction")

            if let secondary = recommendation.secondaryAction {
                Button {
                    activeAction = secondary
                } label: {
                    Text(secondary.label(lang))
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(Color.linkPurple)
                        .frame(maxWidth: .infinity, minHeight: 40)
                }
                .accessibilityIdentifier("homeSecondaryAction")
            }
        }
        .padding(TwinkoSpacing.m)
        .background(Color.surfacePrimary.opacity(0.94),
                    in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20)
            .strokeBorder(Color.twinkoGold.opacity(0.4), lineWidth: 1))
        .transition(.opacity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("homeRecommendationCard")
    }

    /// Minimum context handoff into existing features.
    @ViewBuilder
    private func destination(for action: HomeAction) -> some View {
        switch action {
        case .chat:
            ChatView()
        case .meditation(let focus, _):
            MeditationFlowView(sourceContext: MeditationSourceContext(
                sourceType: .checkIn,
                focusSummary: todayCheckIn.map { checkIn in
                    lang == .english
                        ? "Feeling \(checkIn.mood.label(lang).lowercased()) today and wanting to \(checkIn.need.label(lang).lowercased())."
                        : "今天感覺\(checkIn.mood.label(lang))，想要\(checkIn.need.label(lang))。"
                },
                recommendedFocus: focus))
        case .tarot:
            TarotFlowView()
        case .horoscope:
            HoroscopeTodayView()
        case .music:
            MusicPlaceholderView()
        }
    }

    // MARK: Conditional continuation

    /// Shown only when real recent state exists (a conversation
    /// updated today) — never a fixed checklist, never fake history.
    @ViewBuilder
    private var continuationCard: some View {
        if let recent = chatStore.sessions.first,
           Calendar.current.isDateInToday(recent.updatedAt),
           !recent.messages.isEmpty {
            VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                Text(HomeExperienceStrings.continuationTitle(lang))
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.softWhite.opacity(0.85))
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                NavigationLink {
                    ChatView(session: recent)
                } label: {
                    HStack(spacing: TwinkoSpacing.m) {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.brandPurpleDeep)
                            .frame(width: 32, height: 32)
                            .background(Color.brandPurple.opacity(0.15), in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(HomeExperienceStrings.continueChat(lang))
                                .font(.system(.subheadline, design: .rounded).weight(.medium))
                                .foregroundStyle(Color.deepPlum)
                            Text(recent.displayTitle(for: lang))
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(Color.textSecondaryToken)
                                .lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.textMutedToken)
                    }
                    .padding(TwinkoSpacing.m)
                    .background(Color.surfacePrimary.opacity(0.85),
                                in: RoundedRectangle(cornerRadius: 18))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("homeContinuationChat")
            }
        }
    }

    // MARK: Compact Explore shortcuts

    private var exploreShortcuts: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            Text(HomeExperienceStrings.exploreTitle(lang))
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.softWhite.opacity(0.85))
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
            HStack(spacing: TwinkoSpacing.s) {
                shortcut(.tarot) { TarotFlowView() }
                shortcut(.zodiac) { HoroscopeTodayView() }
                shortcut(.meditate) { MeditationFlowView() }
                shortcut(.music) { MusicPlaceholderView() }
            }
        }
    }

    @ViewBuilder
    private func shortcut<Destination: View>(
        _ mode: HomeMode, @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            VStack(spacing: 5) {
                HomeModeIcon(mode: mode, diameter: 46)
                Text(HomeStrings.modeLabel(mode, lang))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.softWhite)
                    .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(HomeTilePressStyle())
        .accessibilityLabel(Text(HomeStrings.modeAccessibilityLabel(mode, lang)))
        .accessibilityIdentifier("homeTile-\(mode)")
    }
}

#Preview {
    AppShellView()
        .environmentObject(ProfileStore())
        .environmentObject(PrefsStore())
        .environmentObject(ChatStore())
}
