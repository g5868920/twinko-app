import SwiftUI

// MARK: - App shell (four-tab bottom navigation)

/// Top-level shell owning only the four approved destinations —
/// Home, Chat, Explore, My Planet. Each tab hosts its own
/// NavigationStack; feature-internal navigation is untouched.
enum AppTab: String, CaseIterable, Identifiable {
    case home, chat, explore, myPlanet

    var id: String { rawValue }

    func label(_ lang: AppLanguage) -> String {
        switch self {
        case .home: return HomeExperienceStrings.tabHome(lang)
        case .chat: return HomeExperienceStrings.tabChat(lang)
        case .explore: return HomeExperienceStrings.tabExplore(lang)
        case .myPlanet: return HomeExperienceStrings.tabMyPlanet(lang)
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .chat: return "bubble.left"
        case .explore: return "sparkles"
        case .myPlanet: return "" // image asset identity
        }
    }

    /// Selected-state symbol ("sparkles" has no .fill variant).
    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .chat: return "bubble.left.fill"
        case .explore: return "sparkles"
        case .myPlanet: return ""
        }
    }

    var identifier: String {
        switch self {
        case .home: return "tab-home"
        case .chat: return "tab-chat"
        case .explore: return "tab-explore"
        case .myPlanet: return "tab-myplanet"
        }
    }
}

/// Shared shell state: the selected tab plus the derived bottom-tab
/// visibility. Visibility is never toggled imperatively by tab roots —
/// the ZStack keeps every root alive and their `onAppear` can re-fire
/// at unpredictable times, which raced (and lost) against immersive
/// pushes. Instead, each immersive screen registers a token while it
/// is on screen, Chat reports whether an active conversation is open,
/// and the tab bar hides whenever either is true.
@MainActor
final class ShellChrome: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published private(set) var tabBarHidden = false

    private var immersiveTokens: Set<UUID> = []
    private var chatConversationActive = false

    /// Immersive screens (Tarot, Meditation, Horoscope detail) call
    /// this with `active: true` on appear and `false` on disappear.
    /// Token-based so double-fired lifecycle callbacks stay idempotent
    /// and nested pushes (Tarot → Meditation) hand over cleanly.
    func setImmersive(_ token: UUID, active: Bool) {
        if active {
            immersiveTokens.insert(token)
        } else {
            immersiveTokens.remove(token)
        }
        recompute()
    }

    /// Chat reports its conversation state (landing = false).
    func setChatConversationActive(_ active: Bool) {
        chatConversationActive = active
        recompute()
    }

    private func recompute() {
        let hidden = !immersiveTokens.isEmpty || chatConversationActive
        if tabBarHidden != hidden { tabBarHidden = hidden }
    }
}

struct AppShellView: View {
    @EnvironmentObject private var prefs: PrefsStore
    @StateObject private var chrome = ShellChrome()

    private var lang: AppLanguage { prefs.language }
    private var selectedTab: AppTab { chrome.selectedTab }

    var body: some View {
        ZStack {
            // Keep tab contents alive so feature-internal state
            // (e.g. an ongoing chat draft) survives tab switches.
            // Hidden tabs leave the accessibility tree entirely:
            // VoiceOver must not read invisible screens, and the
            // snapshot cost of four full worlds at once is real.
            NavigationStack { HomeView() }
                .opacity(selectedTab == .home ? 1 : 0)
                .allowsHitTesting(selectedTab == .home)
                .accessibilityHidden(selectedTab != .home)
            NavigationStack { ChatView(isTabRoot: true) }
                .opacity(selectedTab == .chat ? 1 : 0)
                .allowsHitTesting(selectedTab == .chat)
                .accessibilityHidden(selectedTab != .chat)
            NavigationStack { ExploreView() }
                .opacity(selectedTab == .explore ? 1 : 0)
                .allowsHitTesting(selectedTab == .explore)
                .accessibilityHidden(selectedTab != .explore)
            NavigationStack { MyPlanetTabView() }
                .opacity(selectedTab == .myPlanet ? 1 : 0)
                .allowsHitTesting(selectedTab == .myPlanet)
                .accessibilityHidden(selectedTab != .myPlanet)
        }
        .overlay(alignment: .bottom) {
            if !chrome.tabBarHidden {
                TwinkoGlassDock(chrome: chrome, lang: lang)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: chrome.tabBarHidden)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .environmentObject(chrome)
    }

}

// MARK: - Floating glass dock (companion-universe redesign 2026-07-17)

/// Premium floating glass dock: capsule of thin material above the
/// bottom safe area, one coherent cosmic icon family, and a moving
/// glass active indicator (matchedGeometryEffect). Light haptic on
/// selection; the background artwork stays visible through the glass.
struct TwinkoGlassDock: View {
    @ObservedObject var chrome: ShellChrome
    let lang: AppLanguage
    @Namespace private var indicatorSpace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                let selected = chrome.selectedTab == tab
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(reduceMotion ? nil
                                  : .spring(response: 0.28, dampingFraction: 0.86)) {
                        chrome.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 2) {
                        dockIcon(tab, selected: selected)
                        Text(tab.label(lang))
                            .font(.system(size: 10,
                                          weight: selected ? .bold : .medium,
                                          design: .rounded))
                            .foregroundStyle(selected ? Color.brandPurpleDeep
                                                      : Color.deepPlum.opacity(0.55))
                    }
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background {
                        if selected {
                            // Moving liquid-glass indicator.
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.brandPurple.opacity(0.20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .strokeBorder(Color(hex: 0xD9C8FF).opacity(0.8),
                                                      lineWidth: 1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(LinearGradient(
                                            colors: [Color.white.opacity(0.2), .clear],
                                            startPoint: .top, endPoint: .center))
                                )
                                .padding(4)
                                .matchedGeometryEffect(id: "dockIndicator",
                                                       in: indicatorSpace)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .accessibilityIdentifier(tab.identifier)
                .accessibilityLabel(Text(tab.label(lang)))
                .accessibilityAddTraits(selected ? [.isSelected] : [])
            }
        }
        .padding(.horizontal, 6)
        .frame(height: 68)
        .background {
            // Floating navigation glass (material polish 2026-07-18):
            // translucent lavender capsule in the same atmospheric
            // family, slightly stronger separation than page cards —
            // the world stays visible through it.
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(LinearGradient(
                            colors: [Color(hex: 0xDBCDFA).opacity(0.34),
                                     Color(hex: 0xBBA9EE).opacity(0.26)],
                            startPoint: .top, endPoint: .bottom))
                )
                .overlay(
                    // Soft top highlight fading down.
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(LinearGradient(stops: [
                            .init(color: Color.white.opacity(0.24), location: 0),
                            .init(color: Color.white.opacity(0), location: 0.4),
                        ], startPoint: .top, endPoint: .bottom))
                )
        }
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .strokeBorder(
                    LinearGradient(stops: [
                        .init(color: Color.white.opacity(0.6), location: 0),
                        .init(color: Color(hex: 0xD1C4FF).opacity(0.35), location: 0.6),
                    ], startPoint: .top, endPoint: .bottom),
                    lineWidth: 1)
        )
        .shadow(color: Color.deepSpace.opacity(0.22), radius: 14, y: 6)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }

    /// One coherent cosmic icon family: every glyph sits in the same
    /// 30 pt bounding box with normalized scale — including the
    /// My Planet raster identity.
    @ViewBuilder
    private func dockIcon(_ tab: AppTab, selected: Bool) -> some View {
        ZStack {
            switch tab {
            case .home:
                Image(systemName: selected ? "house.fill" : "house")
                    .font(.system(size: 19, weight: .medium))
                Image(systemName: "sparkle")
                    .font(.system(size: 7))
                    .foregroundStyle(Color.twinkoGold.opacity(selected ? 1 : 0.55))
                    .offset(x: 9, y: -10)
            case .chat:
                // Reference chat icon: bubble with two tiny stars
                // inside (outline when inactive, filled when active).
                Image(systemName: selected ? "bubble.left.fill" : "bubble.left")
                    .font(.system(size: 18, weight: .medium))
                HStack(spacing: 2) {
                    Image(systemName: "star.fill").font(.system(size: 4.5))
                    Image(systemName: "star.fill").font(.system(size: 3.5))
                }
                .foregroundStyle(selected ? Color.twinkoGold
                                          : Color.twinkoGold.opacity(0.7))
                .offset(x: -1, y: -3)
            case .explore:
                // Cosmic navigator: a small drawn rocket ship with a
                // gold trail — clearly "exploration", never a generic
                // paper-plane send icon.
                DockRocketIcon(selected: selected)
                HStack(spacing: 1.5) {
                    Circle().frame(width: 2, height: 2)
                    Circle().frame(width: 1.5, height: 1.5)
                }
                .foregroundStyle(Color.twinkoGold.opacity(selected ? 0.95 : 0.5))
                .offset(x: -9, y: 9)
            case .myPlanet:
                // Normalized planet-and-ring drawn in code — matches
                // the family weight; the old raster identity
                // (home_my_planet_v1) is intentionally not used here.
                DockPlanetIcon(selected: selected)
                Image(systemName: "sparkle")
                    .font(.system(size: 6))
                    .foregroundStyle(Color.twinkoGold.opacity(selected ? 1 : 0.55))
                    .offset(x: 10, y: -9)
            }
        }
        .frame(width: 30, height: 30)
        .foregroundStyle(selected ? Color.brandPurpleDeep
                                  : Color.deepPlum.opacity(0.5))
        .shadow(color: selected ? Color.brandPurple.opacity(0.45) : .clear,
                radius: 4)
    }
}

// MARK: - Dock icon family (drawn members)

/// Small drawn rocket for the Explore tab: rounded nose-up body,
/// window, and side fins, angled like a ship in flight. Inherits the
/// dock's foreground style so active/inactive states match the family.
struct DockRocketIcon: View {
    let selected: Bool

    var body: some View {
        ZStack {
            // Body with rounded nose.
            Capsule()
                .fill(selected ? AnyShapeStyle(.foreground)
                               : AnyShapeStyle(.foreground.opacity(0.9)))
                .frame(width: 9.5, height: 18)
            // Side fins.
            ForEach([-1.0, 1.0], id: \.self) { side in
                Triangle()
                    .fill(.foreground)
                    .frame(width: 5, height: 7)
                    .scaleEffect(x: side, y: 1)
                    .offset(x: side * 6, y: 4.5)
            }
            // Window.
            Circle()
                .fill(Color.white.opacity(selected ? 0.95 : 0.75))
                .frame(width: 4.5, height: 4.5)
                .offset(y: -2.5)
        }
        .rotationEffect(.degrees(38))
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY),
                          control: CGPoint(x: rect.minX + rect.width * 0.2, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Normalized planet-and-ring for the My Planet tab: simple circle
/// body with one elliptical ring, drawn to the same optical size and
/// weight as the other dock icons (replaces the old raster icon in
/// the dock only).
struct DockPlanetIcon: View {
    let selected: Bool

    var body: some View {
        ZStack {
            if selected {
                Circle()
                    .fill(.foreground)
                    .frame(width: 15, height: 15)
            } else {
                Circle()
                    .strokeBorder(.foreground, lineWidth: 1.7)
                    .frame(width: 15, height: 15)
            }
            Ellipse()
                .strokeBorder(.foreground, lineWidth: 1.4)
                .frame(width: 25, height: 9)
                .rotationEffect(.degrees(-18))
        }
    }
}

// MARK: - Explore (immersive cosmic map, 2026-07-17)

/// Explore — a cosmic navigation map: five floating feature planets
/// over the approved deep-space background, faint orbit paths, a
/// drifting navigator ship, glass label tags, and a calm star-travel
/// activation. Routes into the existing feature flows; the dock stays
/// visible on the map and immersive flows hide it themselves.
struct ExploreView: View {
    @EnvironmentObject private var prefs: PrefsStore
    @EnvironmentObject private var chrome: ShellChrome
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var drifting = false
    @State private var isVisible = false
    @State private var activePlanet: ExplorePlanet?
    @State private var launching: ExplorePlanet?

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                orbitDecoration(in: geo.size)

                ForEach(ExplorePlanet.allCases) { planet in
                    planetView(planet, in: geo.size)
                }

                // Slow navigator ship drifting near the top.
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: 0xEFE7FA).opacity(0.8))
                    .rotationEffect(.degrees(40))
                    .shadow(color: Color.twinkoGold.opacity(0.5), radius: 4)
                    .position(x: geo.size.width * 0.82,
                              y: geo.size.height * 0.10)
                    .offset(x: reduceMotion || !isVisible ? 0 : (drifting ? -14 : 6),
                            y: reduceMotion || !isVisible ? 0 : (drifting ? 5 : -3))
                    .accessibilityHidden(true)

                VStack {
                    Text(HomeExperienceStrings.exploreMapTitle(lang))
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: 0xF3ECFF))
                        .shadow(color: .black.opacity(0.4), radius: 3, y: 1)
                        .padding(.top, TwinkoSpacing.s)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                }
            }
        }
        .background {
            TwinkoFullScreenBackground(imageName: TwinkoBackgrounds.exploreResolved,
                                       topOpacity: 0.25, bottomOpacity: 0.35)
        }
        .dockClearance()
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $activePlanet) { planet in
            planet.destination
        }
        .onAppear { updateMotion(active: chrome.selectedTab == .explore) }
        .onChange(of: chrome.selectedTab) { _, tab in
            // Opacity-based tab switching never fires onDisappear, so
            // nonessential motion is paused explicitly off-tab (both a
            // performance rule and an accessibility-snapshot必要).
            updateMotion(active: tab == .explore)
        }
        .onDisappear { updateMotion(active: false) }
    }

    /// Starts or cancels the continuous drift (an explicit short
    /// animation interrupts an in-flight repeatForever).
    private func updateMotion(active: Bool) {
        isVisible = active
        if active && !reduceMotion {
            withAnimation(.easeInOut(duration: 4.6).repeatForever(autoreverses: true)) {
                drifting = true
            }
        } else {
            withAnimation(.linear(duration: 0.05)) { drifting = false }
        }
    }

    // MARK: Decoration

    private func orbitDecoration(in size: CGSize) -> some View {
        ZStack {
            ForEach(0..<2, id: \.self) { index in
                Ellipse()
                    .strokeBorder(Color(hex: 0xD9C8FF).opacity(0.10 + Double(index) * 0.04),
                                  lineWidth: 1)
                    .frame(width: size.width * (1.1 - Double(index) * 0.25),
                           height: size.height * (0.55 - Double(index) * 0.12))
                    .position(x: size.width * 0.5, y: size.height * 0.52)
            }
            ForEach(0..<6, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: [6.0, 4.0, 5.0, 4.0, 6.0, 5.0][index]))
                    .foregroundStyle(Color.twinkoGold
                        .opacity([0.5, 0.35, 0.45, 0.3, 0.5, 0.4][index]))
                    .position(x: size.width * [0.12, 0.88, 0.30, 0.72, 0.08, 0.92][index],
                              y: size.height * [0.22, 0.34, 0.10, 0.16, 0.62, 0.72][index])
            }
        }
        .accessibilityHidden(true)
    }

    // MARK: Planets

    private func planetView(_ planet: ExplorePlanet, in size: CGSize) -> some View {
        let point = planet.position
        let phase = reduceMotion || !isVisible ? 0.0 : (drifting ? 1.0 : -1.0)
        return Button {
            activate(planet)
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    // Atmospheric glow + activation halo.
                    Circle()
                        .fill(planet.tint)
                        .frame(width: planet.size * 1.25, height: planet.size * 1.25)
                        .blur(radius: 18)
                        .opacity(launching == planet ? 0.55 : 0.28)
                    // Planet body.
                    Circle()
                        .fill(RadialGradient(colors: [planet.tint.opacity(0.95),
                                                      planet.tint.opacity(0.6),
                                                      Color.deepSpace.opacity(0.7)],
                                             center: .init(x: 0.35, y: 0.28),
                                             startRadius: 3,
                                             endRadius: planet.size * 0.8))
                        .overlay(Circle().fill(LinearGradient(
                            colors: [Color.white.opacity(0.25), .clear],
                            startPoint: .topLeading, endPoint: .center)))
                        .overlay(Circle().strokeBorder(
                            Color(hex: 0xD9C8FF).opacity(0.5), lineWidth: 1))
                    // Orbit ring detail.
                    Ellipse()
                        .strokeBorder(Color(hex: 0xE8DCFF).opacity(0.55), lineWidth: 1.2)
                        .frame(width: planet.size * 1.35, height: planet.size * 0.42)
                        .rotationEffect(.degrees(-16))
                    // Feature glyph.
                    planet.glyph
                        .foregroundStyle(Color(hex: 0xF6F0FF))
                        .shadow(color: .black.opacity(0.3), radius: 2)
                    // Tiny gold star accent.
                    Image(systemName: "sparkle")
                        .font(.system(size: planet.size * 0.12))
                        .foregroundStyle(Color.twinkoGold.opacity(0.95))
                        .offset(x: planet.size * 0.36, y: -planet.size * 0.34)
                }
                .frame(width: planet.size, height: planet.size)
                .scaleEffect(launching == planet ? 1.12 : 1.0)

                // Glass label tag.
                VStack(spacing: 0) {
                    Text(planet.title(lang))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: 0xF6F0FF))
                    Text(planet.descriptor(lang))
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(Color(hex: 0xE8DCFF).opacity(0.85))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .twinkoGlass(cornerRadius: 12, tint: 0.10)
            }
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .position(x: size.width * point.x, y: size.height * point.y)
        .offset(y: CGFloat(phase) * planet.driftAmplitude)
        .animation(reduceMotion || !isVisible ? .linear(duration: 0.05)
                   : .easeInOut(duration: planet.driftDuration).repeatForever(autoreverses: true),
                   value: drifting)
        .accessibilityIdentifier("explore-\(planet.rawValue)")
        .accessibilityLabel(Text(lang == .english
            ? "Open \(planet.title(lang)). \(planet.descriptor(lang))"
            : "開啟\(planet.title(lang))，\(planet.descriptor(lang))"))
    }

    /// Light haptic → brief halo/forward pulse → calm star-travel push.
    private func activate(_ planet: ExplorePlanet) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard !reduceMotion else {
            activePlanet = planet
            return
        }
        withAnimation(.easeOut(duration: 0.22)) { launching = planet }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            activePlanet = planet
            withAnimation(.easeOut(duration: 0.3)) { launching = nil }
        }
    }
}

/// The five Explore worlds: one shared construction family with
/// distinct identities, positioned as a fixed readable map.
enum ExplorePlanet: String, CaseIterable, Identifiable, Hashable {
    case tarot, horoscope, meditation, music, activities

    var id: String { rawValue }

    /// Relative map position (portrait, below the title, above dock).
    var position: CGPoint {
        switch self {
        case .tarot: return CGPoint(x: 0.28, y: 0.24)
        case .horoscope: return CGPoint(x: 0.74, y: 0.33)
        case .meditation: return CGPoint(x: 0.30, y: 0.55)
        case .music: return CGPoint(x: 0.72, y: 0.66)
        case .activities: return CGPoint(x: 0.42, y: 0.84)
        }
    }

    var size: CGFloat {
        switch self {
        case .tarot: return 96
        case .horoscope: return 88
        case .meditation: return 92
        case .music: return 82
        case .activities: return 78
        }
    }

    var tint: Color {
        switch self {
        case .tarot: return Color(hex: 0x6B4BA8)        // deep violet oracle
        case .horoscope: return Color(hex: 0x4E5FB8)    // luminous blue-violet
        case .meditation: return Color(hex: 0x5D7BC8)   // calm moon lilac-blue
        case .music: return Color(hex: 0x9A4FB0)        // violet-magenta rhythm
        case .activities: return Color(hex: 0xC77B4E)   // warm coral-gold social
        }
    }

    var driftDuration: Double {
        switch self {
        case .tarot: return 4.0
        case .horoscope: return 4.8
        case .meditation: return 5.4
        case .music: return 4.4
        case .activities: return 5.0
        }
    }

    var driftAmplitude: CGFloat {
        switch self {
        case .tarot, .meditation: return 5
        case .horoscope, .activities: return 4
        case .music: return 6
        }
    }

    @ViewBuilder
    var glyph: some View {
        switch self {
        case .tarot:
            RoundedRectangle(cornerRadius: 3)
                .strokeBorder(Color(hex: 0xF6F0FF), lineWidth: 1.4)
                .frame(width: 18, height: 26)
                .overlay(Image(systemName: "star.fill").font(.system(size: 8)))
                .rotationEffect(.degrees(-8))
        case .horoscope:
            Image(systemName: "circle.hexagongrid")
                .font(.system(size: 26, weight: .light))
                .overlay(Image(systemName: "star.fill").font(.system(size: 8))
                    .foregroundStyle(Color.twinkoGold))
        case .meditation:
            Image(systemName: "moon.fill")
                .font(.system(size: 24, weight: .medium))
        case .music:
            Image(systemName: "music.note")
                .font(.system(size: 24, weight: .medium))
        case .activities:
            Image(systemName: "location.fill")
                .font(.system(size: 22, weight: .medium))
        }
    }

    func title(_ lang: AppLanguage) -> String {
        switch self {
        case .tarot: return HomeExperienceStrings.entryTarot(lang)
        case .horoscope: return HomeExperienceStrings.entryHoroscope(lang)
        case .meditation: return HomeExperienceStrings.entryMeditation(lang)
        case .music: return HomeExperienceStrings.entryMusic(lang)
        case .activities: return HomeExperienceStrings.entryActivities(lang)
        }
    }

    func descriptor(_ lang: AppLanguage) -> String {
        switch self {
        case .tarot: return HomeExperienceStrings.planetTarotDesc(lang)
        case .horoscope: return HomeExperienceStrings.planetHoroscopeDesc(lang)
        case .meditation: return HomeExperienceStrings.planetMeditationDesc(lang)
        case .music: return HomeExperienceStrings.planetMusicDesc(lang)
        case .activities: return HomeExperienceStrings.planetActivitiesDesc(lang)
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .tarot: TarotFlowView()
        case .horoscope: HoroscopeTodayView()
        case .meditation: MeditationFlowView()
        case .music: MusicPlaceholderView()
        case .activities: ActivitiesComingSoonView()
        }
    }
}

// MARK: - My Planet tab host

/// Hosts the My Planet personal world as a full tab destination.
struct MyPlanetTabView: View {
    var body: some View {
        MyPlanetContentView()
    }
}
