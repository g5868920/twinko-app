import SwiftUI

/// Decides the first screen: onboarding when no local profile exists,
/// Home for returning users (PRD Flow A / Flow B).
struct RootRouterView: View {
    @StateObject private var profileStore = ProfileStore()
    @StateObject private var chatStore = ChatStore()
    @StateObject private var prefs = PrefsStore()
    @State private var showingSetup = false

    var body: some View {
        NavigationStack {
            Group {
                if profileStore.profile == nil {
                    if showingSetup {
                        ProfileSetupView()
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    } else {
                        WelcomeView {
                            withAnimation(.easeInOut(duration: TwinkoMotion.standard)) {
                                showingSetup = true
                            }
                        }
                        .transition(.opacity)
                    }
                } else {
                    HomeView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: TwinkoMotion.standard), value: profileStore.profile == nil)
        }
        .environmentObject(profileStore)
        .environmentObject(chatStore)
        .environmentObject(prefs)
        // Language preference drives the SwiftUI locale (D-055 bilingual
        // Home); inner flows remain Traditional-Chinese-first per D-054.
        .environment(\.locale, prefs.locale)
    }
}

#Preview {
    RootRouterView()
        .environment(\.locale, Locale(identifier: "zh-Hant"))
}
