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
            mood: .listening,
            backgroundImage: "bg_music_v1"
        )
    }
}

private struct PlaceholderScaffold: View {
    let title: String
    let line: String
    let mood: TwinkoMood
    /// Founder-approved full-screen background; nil keeps the legacy
    /// cosmos gradient (Activities awaits its own approved asset).
    var backgroundImage: String? = nil

    var body: some View {
        ZStack {
            if let backgroundImage {
                // Approved artwork: aspect-fill, no added code stars.
                TwinkoFullScreenBackground(imageName: backgroundImage,
                                           topOpacity: 0.12, bottomOpacity: 0.18)
            } else {
                TwinkoBackground.cosmos.ignoresSafeArea()
                StarFieldView()
            }

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
        .dockClearance()
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

// MARK: - Activities coming soon (companion-universe redesign)

/// Honest Twinko-styled coming-soon destination for Activities. No
/// location permission, no city detection, no real event data — one
/// warm glass card, a small Activities planet, and Back.
struct ActivitiesComingSoonView: View {
    @EnvironmentObject private var prefs: PrefsStore
    @Environment(\.dismiss) private var dismiss

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        ZStack {
            // Approved nearby-activities artwork (bg_activity_v1),
            // aspect-fill behind the safe areas — no added code stars.
            TwinkoFullScreenBackground(imageName: "bg_activity_v1",
                                       topOpacity: 0.12, bottomOpacity: 0.18)

            VStack(spacing: TwinkoSpacing.m) {
                Spacer()
                TwinkoCosmicOrb(diameter: 96, tint: Color(hex: 0xC77B4E)) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 32, weight: .medium))
                }
                Text(HomeExperienceStrings.entryActivities(lang))
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                Text(HomeExperienceStrings.activitiesComingSoon(lang))
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .twinkoGlass(cornerRadius: 22, tint: 0.14)
                    .padding(.horizontal, TwinkoSpacing.l)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text(HomeExperienceStrings.backLabel(lang))
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .accessibilityIdentifier("activitiesBackButton")
                .padding(.bottom, TwinkoSpacing.l)
            }
        }
        .dockClearance()
        .toolbar(.hidden, for: .navigationBar)
    }
}
