import SwiftUI

// Minimal local placeholder pages for Meditate and Music (D-055 §12).
// They preserve the app's visual world, have working back navigation,
// contain no fake functionality, no player, no audio service, and no
// backend — and are intentionally easy to delete when the real modes
// are authorized and built.

struct MeditatePlaceholderView: View {
    @EnvironmentObject private var prefs: PrefsStore

    var body: some View {
        PlaceholderScaffold(
            title: HomeStrings.modeLabel(.meditate, prefs.language),
            line: prefs.language == .english
                ? "Find a comfortable position and take three slow breaths."
                : "找個舒服的姿勢，先慢慢深呼吸三次。",
            mood: .neutral
        )
    }
}

struct MusicPlaceholderView: View {
    @EnvironmentObject private var prefs: PrefsStore

    var body: some View {
        PlaceholderScaffold(
            title: HomeStrings.modeLabel(.music, prefs.language),
            line: prefs.language == .english
                ? "A quiet moment can be its own kind of music."
                : "安靜的片刻，也是一種聲音。",
            mood: .listening
        )
    }
}

private struct PlaceholderScaffold: View {
    let title: String
    let line: String
    let mood: TwinkoMood

    var body: some View {
        ZStack {
            TwinkoBackground.cosmos.ignoresSafeArea()
            StarFieldView()

            VStack(spacing: TwinkoSpacing.m) {
                Spacer()
                TwinkoCharacterView(mood: mood, size: 140)
                Text(line)
                    .font(.twinkoBody)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TwinkoSpacing.xl)
                Spacer()
                Spacer()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.cosmicDeep.opacity(0.6), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        MeditatePlaceholderView()
            .environmentObject(PrefsStore())
    }
}
