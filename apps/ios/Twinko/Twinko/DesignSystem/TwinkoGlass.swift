import SwiftUI

// MARK: - Canonical full-screen backgrounds (2026-07-17)

/// Founder-approved canonical background names for the top-level
/// experience — bundled in the asset catalog and used directly. These
/// exact names are final; provisional names
/// (bg_home_companion_world_v2, bg_explore_cosmic_navigation_v1,
/// bg_my_planet_surface_v1) are retired and `home_screen_v1` is
/// superseded as the Home background (`home_my_planet_v1` remains the
/// distinct My Planet identity/icon artwork).
enum TwinkoBackgrounds {
    static let home = "bg_home_screen_v3"
    static let explore = "bg_explore_v3"
    static let myPlanet = "bg_my_planet_v3"

    // The canonical assets are delivered; screens reference them
    // directly (no runtime fallback mapping).
    static let homeResolved = home
    static let exploreResolved = explore
    static let myPlanetResolved = myPlanet
}

/// Shared full-screen background layer: aspect-fill, edge-to-edge,
/// behind the status bar and bottom safe area, with a restrained
/// readability gradient — never a large opaque cover.
struct TwinkoFullScreenBackground: View {
    let imageName: String
    var topOpacity: Double = 0.22
    var bottomOpacity: Double = 0.30

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                LinearGradient(
                    stops: [
                        .init(color: Color.deepSpace.opacity(topOpacity), location: 0),
                        .init(color: Color.deepSpace.opacity(topOpacity * 0.55), location: 0.4),
                        .init(color: Color.deepSpace.opacity(bottomOpacity), location: 1),
                    ],
                    startPoint: .top, endPoint: .bottom)
            }
            .accessibilityHidden(true)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Twinko glass surface (single shared base, 2026-07-17)

/// The one shared glass base for the top-level universe (Home,
/// Explore, My Planet, dock): thin material + soft lilac tint, 1 pt
/// lilac-white border, subtle top-leading inner highlight, and a wide
/// soft shadow. Feature screens compose this locally; unrelated
/// feature flows keep their existing surfaces.
struct TwinkoGlassSurface: ViewModifier {
    var cornerRadius: CGFloat = 24
    var tint: Double = 0.12
    var selected: Bool = false
    /// Warm speech glass (Twinko's bubble family): ivory-lilac instead
    /// of the atmospheric lavender — warmer, highest readability.
    var warm: Bool = false

    /// Atmospheric lavender tint pair (top slightly brighter — subtle
    /// vertical tonal variation, never a strong gradient band).
    private var tintTop: Color { warm ? Color(hex: 0xFFF2E2) : Color(hex: 0xDBCDFA) }
    private var tintBottom: Color { warm ? Color(hex: 0xEFDDF2) : Color(hex: 0xBBA9EE) }

    func body(content: Content) -> some View {
        // Container-material polish (2026-07-18): translucent
        // lavender / blue-violet atmospheric glass over the material
        // blur — the background bleeds through and shifts the glass
        // cooler over purple sky and warmer over the peach clouds.
        // Never milky white, gray, or beige.
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(selected
                                  ? AnyShapeStyle(Color.brandPurple.opacity(0.20))
                                  : AnyShapeStyle(LinearGradient(
                                        colors: [tintTop.opacity(tint * 0.95),
                                                 tintBottom.opacity(tint * 0.7)],
                                        startPoint: .top, endPoint: .bottom)))
                    )
                    .overlay(
                        // Subtle inner top-edge highlight fading down —
                        // dimensional glass depth, never a white sheet.
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(LinearGradient(stops: [
                                .init(color: Color.white.opacity(0.22), location: 0),
                                .init(color: Color.white.opacity(0), location: 0.32),
                            ], startPoint: .top, endPoint: .bottom))
                    )
            }
            .overlay(
                // Soft lilac-white border, slightly stronger along the
                // top edge — luminous, never a neon ring.
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(selected
                                  ? AnyShapeStyle(Color(hex: 0xD9C8FF).opacity(0.85))
                                  : AnyShapeStyle(LinearGradient(stops: [
                                        .init(color: Color.white.opacity(0.65), location: 0),
                                        .init(color: Color(hex: 0xD1C4FF).opacity(0.38),
                                              location: 0.55),
                                        .init(color: Color(hex: 0xD1C4FF).opacity(0.30),
                                              location: 1),
                                    ], startPoint: .top, endPoint: .bottom)),
                                  lineWidth: 1)
            )
            .shadow(color: Color.deepSpace.opacity(0.14), radius: 10, y: 4)
    }
}

extension View {
    func twinkoGlass(cornerRadius: CGFloat = 24, tint: Double = 0.12,
                     selected: Bool = false, warm: Bool = false) -> some View {
        modifier(TwinkoGlassSurface(cornerRadius: cornerRadius, tint: tint,
                                    selected: selected, warm: warm))
    }
}

/// Quiet pressed feedback shared by glass controls: 0.97 scale,
/// slight dim, light haptic.
struct TwinkoGlassPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }
}

// MARK: - Dock clearance

/// Bottom clearance for the floating glass dock. `safeAreaInset`
/// applied outside a NavigationStack does not reach its children, so
/// every dock-visible screen applies this locally; it collapses
/// automatically while an immersive flow hides the dock.
struct DockClearance: ViewModifier {
    @EnvironmentObject private var chrome: ShellChrome

    func body(content: Content) -> some View {
        // Height-driven (not structural) so simultaneous re-renders —
        // e.g. a live language switch touching every screen — never
        // thrash the layout with inset insert/remove cycles.
        content.safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear.frame(height: chrome.tabBarHidden ? 0 : 78)
        }
    }
}

extension View {
    func dockClearance() -> some View { modifier(DockClearance()) }
}

// MARK: - Cosmic orb container

/// Small cosmic orb: translucent purple glass shell, lilac ring, soft
/// internal highlight, and a custom glyph — the shared construction
/// for Explore-More entries, My Planet hubs, and dock icons so SF
/// Symbols never appear raw.
struct TwinkoCosmicOrb<Glyph: View>: View {
    var diameter: CGFloat = 46
    var tint: Color = .brandPurple
    var showStar: Bool = true
    @ViewBuilder var glyph: () -> Glyph

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(colors: [tint.opacity(0.75),
                                            tint.opacity(0.45),
                                            Color.deepSpace.opacity(0.55)],
                                   center: .init(x: 0.35, y: 0.3),
                                   startRadius: 2, endRadius: diameter * 0.75)
                )
            Circle()
                .fill(LinearGradient(colors: [Color.white.opacity(0.28), .clear],
                                     startPoint: .topLeading, endPoint: .center))
            glyph()
                .foregroundStyle(Color(hex: 0xF3ECFF))
            if showStar {
                Image(systemName: "sparkle")
                    .font(.system(size: diameter * 0.14))
                    .foregroundStyle(Color.twinkoGold.opacity(0.9))
                    .offset(x: diameter * 0.3, y: -diameter * 0.32)
            }
        }
        .frame(width: diameter, height: diameter)
        .overlay(Circle().strokeBorder(Color(hex: 0xD9C8FF).opacity(0.55), lineWidth: 1))
        .shadow(color: tint.opacity(0.35), radius: 6, y: 2)
        .accessibilityHidden(true)
    }
}
