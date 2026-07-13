import SwiftUI

/// Character-first Home Menu (S-005). Twinko is the emotional center;
/// the five modes surround it as soft tiles. Meditation and Music are
/// visibly disabled (即將推出) per D-054 — their presence and order do
/// not resolve D-047.
struct HomeView: View {
    @EnvironmentObject private var profileStore: ProfileStore

    /// Modes whose flows are implemented so far. Tarot and Astrology
    /// flip on as their milestone phases land.
    var chatEnabled = true
    var tarotEnabled = true
    var astrologyEnabled = true

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        let timeWord: String
        switch hour {
        case 5..<11: timeWord = "早安"
        case 11..<18: timeWord = "午安"
        default: timeWord = "晚安"
        }
        if let name = profileStore.profile?.preferredName, !name.isEmpty {
            return "\(timeWord)，\(name)"
        }
        return timeWord
    }

    var body: some View {
        ZStack {
            TwinkoBackground.sky.ignoresSafeArea()
            StarFieldView()

            VStack(spacing: TwinkoSpacing.m) {
                VStack(spacing: TwinkoSpacing.xs) {
                    Text(greeting)
                        .font(.twinkoTitle)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                    Text("今天想做點什麼呢？")
                        .font(.twinkoBody)
                        .foregroundStyle(.white.opacity(0.88))
                }
                .padding(.top, TwinkoSpacing.s)

                Spacer(minLength: 0)

                TwinkoCharacterView(mood: .happy, size: 190)

                Spacer(minLength: 0)

                VStack(spacing: TwinkoSpacing.l) {
                    HStack(alignment: .top, spacing: TwinkoSpacing.l) {
                        modeTile("聊聊天", icon: "bubble.left.and.bubble.right.fill",
                                 colors: [Color(red: 0.35, green: 0.55, blue: 0.85), Color(red: 0.25, green: 0.4, blue: 0.7)],
                                 enabled: chatEnabled) { ChatView() }
                        modeTile("塔羅", icon: "rectangle.portrait.on.rectangle.portrait.angled.fill",
                                 colors: [.skyPurple, .cosmicPurple],
                                 enabled: tarotEnabled) { TarotFlowView() }
                        modeTile("每日星座", icon: "sparkles",
                                 colors: [.warmOrange, .cheekOrange],
                                 enabled: astrologyEnabled) { AstrologyView() }
                    }
                    HStack(alignment: .top, spacing: TwinkoSpacing.l) {
                        FeatureTile(title: "冥想", systemImage: "figure.mind.and.body",
                                    iconColors: [Color(red: 0.4, green: 0.55, blue: 0.8), .cosmicPurple],
                                    isEnabled: false)
                        FeatureTile(title: "音樂", systemImage: "music.note",
                                    iconColors: [.skyPurple, Color(red: 0.4, green: 0.32, blue: 0.62)],
                                    isEnabled: false)
                    }
                }
                .padding(.bottom, TwinkoSpacing.xl)
            }
            .padding(.horizontal, TwinkoSpacing.m)
        }
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private func modeTile<Destination: View>(
        _ title: String, icon: String, colors: [Color], enabled: Bool,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        if enabled {
            NavigationLink {
                destination()
            } label: {
                FeatureTile(title: title, systemImage: icon, iconColors: colors, isEnabled: true)
            }
            .buttonStyle(.plain)
        } else {
            FeatureTile(title: title, systemImage: icon, iconColors: colors, isEnabled: false)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(ProfileStore())
    }
    .environment(\.locale, Locale(identifier: "zh-Hant"))
}
