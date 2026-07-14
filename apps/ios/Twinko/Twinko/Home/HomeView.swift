import SwiftUI

/// D-055 Home: the approved `home_screen_v1.png` sky as a full-screen
/// aspect-fill background, the procedural Twinko centered (temporary,
/// pending a transparent character export), five mode entries in the
/// approved 2–2–1 orbit, one top-right Profile control, and no product
/// wordmark. Bilingual labels per the active Home specification.
struct HomeView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var prefs: PrefsStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var floating = false
    @State private var breathing = false
    @State private var showingProfileSheet = false

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        GeometryReader { geo in
            // Full-screen coordinates: the background must extend behind
            // the safe areas, so the whole layout works edge to edge and
            // the safe-area insets are applied manually where needed.
            let w = geo.size.width
            let h = geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom
            let topInset = geo.safeAreaInsets.top
            let compact = w < 380
            let iconDiameter: CGFloat = compact ? 62 : 68
            let twinkoSize: CGFloat = compact ? 116 : 128

            ZStack {
                // Approved fixed background — aspect fill, edge to edge,
                // no recoloring (intentionally opaque asset).
                Image("home_screen_v1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: w, height: h)
                    .clipped()
                    .accessibilityHidden(true)

                // Subtle pink-purple halo behind Twinko (separate layer,
                // low opacity, per spec §6).
                RadialGradient(
                    colors: [Color.skyPurple.opacity(0.35), .clear],
                    center: .center, startRadius: 0, endRadius: twinkoSize * 1.1
                )
                .frame(width: twinkoSize * 2.2, height: twinkoSize * 2.2)
                .opacity(reduceMotion ? 0.9 : (breathing ? 1.0 : 0.85))
                .position(x: w * 0.5, y: h * 0.43)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

                // Central Twinko (procedural component — temporary for
                // Home until a transparent character export exists).
                TwinkoCharacterView(mood: .happy, size: twinkoSize)
                    .scaleEffect(reduceMotion ? 1 : (breathing ? 1.015 : 1.0))
                    .offset(y: reduceMotion ? 0 : (floating ? -5 : 0))
                    .position(x: w * 0.5, y: h * 0.43)

                // 2–2–1 orbit of mode entries.
                modeTile(.chat, diameter: iconDiameter) { ChatView() }
                    .position(x: w * 0.23, y: h * 0.21)
                modeTile(.tarot, diameter: iconDiameter) { TarotFlowView() }
                    .position(x: w * 0.77, y: h * 0.21)
                modeTile(.zodiac, diameter: iconDiameter) { AstrologyView() }
                    .position(x: w * 0.21, y: h * 0.60)
                modeTile(.meditate, diameter: iconDiameter) { MeditatePlaceholderView() }
                    .position(x: w * 0.79, y: h * 0.60)
                modeTile(.music, diameter: iconDiameter) { MusicPlaceholderView() }
                    .position(x: w * 0.5, y: h * 0.75)

                // Top-right Profile control (44pt target, ~18pt right
                // margin, ~14pt below the top safe area).
                profileButton
                    .position(x: w - 37, y: topInset + 33)
            }
            .frame(width: w, height: h)
            .offset(y: -topInset)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingProfileSheet) {
            ProfileSheetView()
        }
        .onAppear { startIdleMotion() }
    }

    // MARK: Mode tiles

    @ViewBuilder
    private func modeTile<Destination: View>(
        _ mode: HomeMode, diameter: CGFloat,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            VStack(spacing: 7) {
                HomeModeIcon(mode: mode, diameter: diameter)
                Text(HomeStrings.modeLabel(mode, lang))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.softWhite)
                    .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
                    .lineLimit(1)
                    .fixedSize()
            }
            .frame(minWidth: 76, minHeight: 76)
            .contentShape(Rectangle())
        }
        .buttonStyle(HomeTilePressStyle())
        .accessibilityLabel(Text(HomeStrings.modeAccessibilityLabel(mode, lang)))
        .accessibilityIdentifier("homeTile-\(mode)")
    }

    // MARK: Profile control

    private var profileButton: some View {
        Button {
            showingProfileSheet = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color.cosmicDeep.opacity(0.55))
                if let initial = profileStore.profile?.preferredName.first {
                    Text(String(initial))
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.86, green: 0.80, blue: 0.97))
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(red: 0.86, green: 0.80, blue: 0.97))
                }
            }
            .frame(width: 38, height: 38)
            .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
            .frame(width: 44, height: 44)
            .contentShape(Circle())
        }
        .accessibilityLabel(Text(HomeStrings.openProfile(lang)))
        .accessibilityIdentifier("homeProfileButton")
    }

    // MARK: Idle motion (spec §7, with Reduce Motion fallback)

    private func startIdleMotion() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            floating = true
        }
        withAnimation(.easeInOut(duration: 2.9).repeatForever(autoreverses: true)) {
            breathing = true
        }
    }
}

/// Shared tap feedback for the five mode tiles (spec §13): press scale
/// 0.95, ~150ms, subtle brightness lift.
private struct HomeTilePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .brightness(configuration.isPressed ? 0.05 : 0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(ProfileStore())
            .environmentObject(ChatStore())
            .environmentObject(PrefsStore())
    }
}
