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
    // Test-only deep route for manual Simulator verification (same
    // pattern as -uiTestReset / -uiTestSeedProfile).
    @State private var autoOpenHoroscope =
        ProcessInfo.processInfo.arguments.contains("-uiTestOpenHoroscope")

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
            let iconDiameter: CGFloat = compact ? 68 : 74
            let twinkoSize: CGFloat = compact ? 150 : 178
            let twinkoCenter = CGPoint(x: w * 0.5, y: h * 0.44)
            // Cluster offsets from Twinko's center, expressed as
            // fractions of screen height so the cluster's vertical span
            // scales consistently across devices (~65-72% of usable
            // height on standard iPhones). Chat/Tarot sit higher and
            // wider than Zodiac/Meditate; Music is tucked further below
            // the lower pair, keeping the whole group visually joined.
            let scale: CGFloat = compact ? 0.92 : 1.0
            let upper = CGVector(dx: h * 0.145 * scale, dy: h * 0.175 * scale)
            let lower = CGVector(dx: h * 0.128 * scale, dy: h * 0.163 * scale)
            let musicDrop: CGFloat = h * 0.37 * scale

            ZStack {
                // Approved fixed background — aspect fill, edge to edge,
                // no recoloring (intentionally opaque asset).
                Image("home_screen_v1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: w, height: h)
                    .clipped()
                    .accessibilityHidden(true)

                // Layered glow behind Twinko (separate UI layers): warm
                // creamy inner glow + soft pink-lavender outer aura,
                // breathing gently.
                Circle()
                    .fill(Color(red: 0.76, green: 0.62, blue: 0.92))
                    .frame(width: twinkoSize * 1.26, height: twinkoSize * 1.26)
                    .blur(radius: 38)
                    .opacity(reduceMotion ? 0.16 : (breathing ? 0.20 : 0.12))
                    .position(twinkoCenter)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                Circle()
                    .fill(Color(red: 1.0, green: 0.97, blue: 0.88))
                    .frame(width: twinkoSize * 1.10, height: twinkoSize * 1.10)
                    .blur(radius: 22)
                    .opacity(reduceMotion ? 0.25 : (breathing ? 0.30 : 0.20))
                    .position(twinkoCenter)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)

                // Central Twinko — the approved character image, via a
                // derived transparent runtime asset (external baked
                // checkerboard removed; artwork pixels untouched). The
                // procedural TwinkoCharacterView is no longer used on
                // Home but remains available to other screens.
                Image("twinko_default_smile_v1_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: twinkoSize, height: twinkoSize)
                    .scaleEffect(reduceMotion ? 1 : (breathing ? 1.015 : 1.0))
                    .offset(y: reduceMotion ? 0 : (floating ? -6 : 6))
                    .position(twinkoCenter)
                    .accessibilityLabel(Text("Twinko"))

                // 2–2–1 orbit, clustered around Twinko.
                modeTile(.chat, diameter: iconDiameter) { ChatView() }
                    .position(x: twinkoCenter.x - upper.dx, y: twinkoCenter.y - upper.dy)
                modeTile(.tarot, diameter: iconDiameter) { TarotFlowView() }
                    .position(x: twinkoCenter.x + upper.dx, y: twinkoCenter.y - upper.dy)
                modeTile(.zodiac, diameter: iconDiameter) { HoroscopeTodayView() }
                    .position(x: twinkoCenter.x - lower.dx, y: twinkoCenter.y + lower.dy)
                modeTile(.meditate, diameter: iconDiameter) { MeditationFlowView() }
                    .position(x: twinkoCenter.x + lower.dx, y: twinkoCenter.y + lower.dy)
                modeTile(.music, diameter: iconDiameter) { MusicPlaceholderView() }
                    .position(x: twinkoCenter.x, y: twinkoCenter.y + musicDrop)

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
        .navigationDestination(isPresented: $autoOpenHoroscope) {
            HoroscopeTodayView()
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
                    .font(lang == .traditionalChinese
                          ? .custom("PingFangTC-Medium", size: 16)
                          : .system(size: 16, weight: .semibold, design: .rounded))
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
        // TEMPORARY PROFILE PLANET — founder-approved SwiftUI prototype
        // asset (no PNG exists); see ProfilePlanetIcon.
        Button {
            showingProfileSheet = true
        } label: {
            ProfilePlanetIcon(diameter: 39)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(HomeTilePressStyle())
        .accessibilityLabel(Text(HomeStrings.openProfile(lang)))
        .accessibilityIdentifier("homeProfileButton")
    }

    // MARK: Idle motion (spec §7, with Reduce Motion fallback)

    private func startIdleMotion() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            floating = true
        }
        withAnimation(.easeInOut(duration: 4.8).repeatForever(autoreverses: true)) {
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
