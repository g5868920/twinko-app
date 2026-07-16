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

struct AppShellView: View {
    @EnvironmentObject private var prefs: PrefsStore
    @State private var selectedTab: AppTab = .home

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Keep tab contents alive so feature-internal state
                // (e.g. an ongoing chat draft) survives tab switches.
                NavigationStack { HomeView() }
                    .opacity(selectedTab == .home ? 1 : 0)
                    .allowsHitTesting(selectedTab == .home)
                NavigationStack { ChatView(isTabRoot: true) }
                    .opacity(selectedTab == .chat ? 1 : 0)
                    .allowsHitTesting(selectedTab == .chat)
                NavigationStack { ExploreView() }
                    .opacity(selectedTab == .explore ? 1 : 0)
                    .allowsHitTesting(selectedTab == .explore)
                NavigationStack { MyPlanetTabView() }
                    .opacity(selectedTab == .myPlanet ? 1 : 0)
                    .allowsHitTesting(selectedTab == .myPlanet)
            }
            tabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // MARK: Bottom bar (stable readable surface)

    private var tabBar: some View {
        HStack {
            ForEach(AppTab.allCases) { tab in
                let selected = selectedTab == tab
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 3) {
                        if tab == .myPlanet {
                            Image("home_my_planet_v1_transparent")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .opacity(selected ? 1 : 0.62)
                        } else {
                            Image(systemName: selected ? tab.selectedIcon : tab.icon)
                                .font(.system(size: 19, weight: .medium))
                                .foregroundStyle(selected ? Color.brandPurpleDeep
                                                          : Color.inkNavy.opacity(0.45))
                        }
                        Text(tab.label(lang))
                            .font(.system(size: 10,
                                          weight: selected ? .bold : .medium,
                                          design: .rounded))
                            .foregroundStyle(selected ? Color.brandPurpleDeep
                                                      : Color.inkNavy.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .contentShape(Rectangle())
                }
                .accessibilityIdentifier(tab.identifier)
                .accessibilityLabel(Text(tab.label(lang)))
                .accessibilityAddTraits(selected ? [.isSelected] : [])
            }
        }
        .padding(.top, 6)
        .padding(.horizontal, 8)
        .background(
            Color(red: 0.97, green: 0.95, blue: 0.99)
                .overlay(Color.brandPurple.opacity(0.05))
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.borderSoft.opacity(0.6))
                .frame(height: 0.7)
        }
    }
}

// MARK: - Explore

/// Explore: the full content and feature catalog. Reuses the existing
/// feature flows and shared Home mode icons; the compact Home
/// shortcuts point here for "View all".
struct ExploreView: View {
    @EnvironmentObject private var prefs: PrefsStore

    private var lang: AppLanguage { prefs.language }

    private let entries: [HomeMode] = [.tarot, .zodiac, .meditate, .music]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.87, green: 0.82, blue: 0.97),
                         Color(red: 0.95, green: 0.90, blue: 0.97)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            StarFieldView(tint: Color(red: 0.72, green: 0.60, blue: 0.92).opacity(0.6))
                .accessibilityHidden(true)

            ScrollView {
                VStack(spacing: TwinkoSpacing.s) {
                    Text(HomeExperienceStrings.tabExplore(lang))
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(Color.inkNavy)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, TwinkoSpacing.m)

                    ForEach(entries) { mode in
                        NavigationLink {
                            destination(for: mode)
                        } label: {
                            HStack(spacing: TwinkoSpacing.m) {
                                HomeModeIcon(mode: mode, diameter: 46)
                                Text(HomeStrings.modeLabel(mode, lang))
                                    .font(.twinkoHeadline)
                                    .foregroundStyle(Color.inkNavy)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.inkNavy.opacity(0.35))
                            }
                            .padding(TwinkoSpacing.m)
                            .background(Color.white.opacity(0.62),
                                        in: RoundedRectangle(cornerRadius: 18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .strokeBorder(Color.borderSoft.opacity(0.7), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("explore-\(mode)")
                    }
                }
                .padding(.horizontal, TwinkoSpacing.m)
                .padding(.bottom, TwinkoSpacing.l)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func destination(for mode: HomeMode) -> some View {
        switch mode {
        case .chat: ChatView()
        case .tarot: TarotFlowView()
        case .zodiac: HoroscopeTodayView()
        case .meditate: MeditationFlowView()
        case .music: MusicPlaceholderView()
        }
    }
}

// MARK: - My Planet tab host

/// Hosts the existing My Planet content as a full tab destination
/// (the sheet-presentation modifiers inside are inert here).
struct MyPlanetTabView: View {
    var body: some View {
        MyPlanetContentView()
    }
}
