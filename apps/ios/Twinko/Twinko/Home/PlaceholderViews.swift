import SwiftUI

// Minimal local placeholder page for Music (D-055 §12). It preserves
// the app's visual world, has working back navigation, contains no
// fake functionality, no player, no audio service, and no backend —
// and is intentionally easy to delete when the real mode is
// authorized and built. (The Meditate placeholder was replaced by the
// real Meditation flow.)

/// Shared floating header for dark-world placeholder pages: the same
/// warm-gold Back treatment as Tarot / Horoscope / Meditation, with a
/// centered rounded title — never the system navigation bar.
private struct PlaceholderHeader: View {
    let title: String
    let backLabel: String
    let backIdentifier: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.textInverseToken)
            HStack {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.backward")
                        .tarotHeaderControlIcon()
                }
                .buttonStyle(TarotHeaderControlStyle())
                .accessibilityLabel(Text(backLabel))
                .accessibilityIdentifier(backIdentifier)
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 48)
    }
}

struct MusicPlaceholderView: View {
    @EnvironmentObject private var prefs: PrefsStore
    @EnvironmentObject private var chrome: ShellChrome
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var floating = false
    @State private var immersiveToken = UUID()

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        ZStack {
            // Approved artwork: aspect-fill, no added code stars.
            TwinkoFullScreenBackground(imageName: "bg_music_v1",
                                       topOpacity: 0.12, bottomOpacity: 0.18)

            VStack(spacing: 0) {
                PlaceholderHeader(
                    title: HomeStrings.modeLabel(.music, lang),
                    backLabel: lang == .english ? "Back" : "返回",
                    backIdentifier: "musicBackButton",
                    onBack: { dismiss() })

                VStack(spacing: TwinkoSpacing.m) {
                    Spacer()
                    // Founder-approved music Twinko on the shared
                    // companion float — motion scoped to this image
                    // only, never the page.
                    Image("twinko_music_v1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .twinkoFloat(active: floating, amplitude: 4, duration: 3.2)
                        .accessibilityLabel(Text("Twinko"))
                    Text(lang == .english
                         ? "A quiet moment can be its own kind of music."
                         : "安靜的片刻，也是一種聲音。")
                        .font(.twinkoBody)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TwinkoSpacing.xl)
                    Spacer()
                    Spacer()
                }
            }
        }
        .dockClearance()
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Immersive page: the dock hides while Music is open.
            chrome.setImmersive(immersiveToken, active: true)
            floating = true
        }
        .onDisappear {
            chrome.setImmersive(immersiveToken, active: false)
        }
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
/// warm glass card, a small Activities planet, and the standard
/// top-left Back (the bottom Back button was retired 2026-07-18).
struct ActivitiesComingSoonView: View {
    @EnvironmentObject private var prefs: PrefsStore
    @EnvironmentObject private var chrome: ShellChrome
    @Environment(\.dismiss) private var dismiss
    @State private var immersiveToken = UUID()

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        ZStack {
            // Approved nearby-activities artwork (bg_activity_v1),
            // aspect-fill behind the safe areas — no added code stars.
            TwinkoFullScreenBackground(imageName: "bg_activity_v1",
                                       topOpacity: 0.12, bottomOpacity: 0.18)

            VStack(spacing: 0) {
                PlaceholderHeader(
                    title: HomeExperienceStrings.entryActivities(lang),
                    backLabel: lang == .english ? "Back" : "返回",
                    backIdentifier: "activitiesBackButton",
                    onBack: { dismiss() })

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
                    Spacer()
                }
            }
        }
        .dockClearance()
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Immersive page: the dock hides while Activity is open.
            chrome.setImmersive(immersiveToken, active: true)
        }
        .onDisappear {
            chrome.setImmersive(immersiveToken, active: false)
        }
    }
}
