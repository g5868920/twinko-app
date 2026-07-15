import SwiftUI

// Minimal local placeholder page for Music (D-055 §12). It preserves
// the app's visual world, has working back navigation, contains no
// fake functionality, no player, no audio service, and no backend —
// and is intentionally easy to delete when the real mode is
// authorized and built. (The Meditate placeholder was replaced by the
// real Meditation flow.)

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
        MusicPlaceholderView()
            .environmentObject(PrefsStore())
    }
}
