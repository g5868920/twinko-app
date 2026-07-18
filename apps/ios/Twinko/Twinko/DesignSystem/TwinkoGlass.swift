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
    /// Night variant for moonlit worlds (Meditation): deeper cool
    /// violet tints and a dimmer rim so the glass belongs to the dark
    /// scene while keeping the same material language.
    var night: Bool = false

    /// Tint pair (top slightly brighter — subtle vertical tonal
    /// variation, never a strong gradient band).
    private var tintTop: Color {
        if warm { return night ? Color(hex: 0xF6E8DC) : Color(hex: 0xFFF3E6) }
        return night ? Color(hex: 0x9C8CD8) : Color(hex: 0xE6DCFC)
    }
    private var tintBottom: Color {
        if warm { return night ? Color(hex: 0xE3CFE8) : Color(hex: 0xEFD9EE) }
        return night ? Color(hex: 0x6E5FB0) : Color(hex: 0xC3AFF2)
    }
    private var rimTop: Double { night ? 0.5 : 0.75 }
    private var rimMid: Double { night ? 0.22 : 0.35 }
    private var innerHighlight: Double { night ? 0.16 : 0.24 }

    func body(content: Content) -> some View {
        // Clear-glass polish (2026-07-18, second pass): the system
        // material was removed entirely — its frosting always lifted
        // and desaturated the backdrop into milky plastic. The target
        // glass is CLEAR: a pure low-opacity cool-violet gradient the
        // background bleeds straight through, plus a luminous top
        // border, a soft inner top highlight, and a wide floating
        // shadow. Cooler over the purple sky, warmer over the clouds.
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(selected
                          ? AnyShapeStyle(Color.brandPurple.opacity(0.22))
                          : AnyShapeStyle(LinearGradient(
                                colors: [tintTop.opacity(min(tint * 1.35, 0.9)),
                                         tintBottom.opacity(tint)],
                                startPoint: .top, endPoint: .bottom)))
                    .overlay(
                        // Subtle inner top-edge highlight fading down —
                        // dimensional glass depth, never a white sheet.
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(LinearGradient(stops: [
                                .init(color: Color.white.opacity(innerHighlight), location: 0),
                                .init(color: Color.white.opacity(0), location: 0.30),
                            ], startPoint: .top, endPoint: .bottom))
                    )
            }
            .overlay(
                // Soft luminous lilac-white rim, brightest along the
                // top edge — an edge light, never a neon ring.
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(selected
                                  ? AnyShapeStyle(Color(hex: 0xD9C8FF).opacity(0.85))
                                  : AnyShapeStyle(LinearGradient(stops: [
                                        .init(color: Color.white.opacity(rimTop), location: 0),
                                        .init(color: Color.white.opacity(rimMid), location: 0.3),
                                        .init(color: Color(hex: 0xD1C4FF).opacity(night ? 0.22 : 0.30),
                                              location: 1),
                                    ], startPoint: .top, endPoint: .bottom)),
                                  lineWidth: 1)
            )
            .shadow(color: Color.deepSpace.opacity(0.12), radius: 16, y: 7)
    }
}

extension View {
    func twinkoGlass(cornerRadius: CGFloat = 24, tint: Double = 0.12,
                     selected: Bool = false, warm: Bool = false,
                     night: Bool = false) -> some View {
        modifier(TwinkoGlassSurface(cornerRadius: cornerRadius, tint: tint,
                                    selected: selected, warm: warm, night: night))
    }
}

// MARK: - Illuminated night choice (shared selectable-chip recipe)

/// The shared selectable-surface treatment for night worlds
/// (Meditation setup/completion, Tarot): clear night glass at rest;
/// selected surfaces "light up" — a translucent lavender fill, a gold
/// gradient rim, and a soft gold halo. Matches the Meditation setup
/// chips exactly so every night flow speaks one selection language.
struct TwinkoNightChoiceSurface: ViewModifier {
    var cornerRadius: CGFloat = 14
    var selected: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(selected
                          ? AnyShapeStyle(LinearGradient(
                                colors: [Color.brandPurple.opacity(0.55),
                                         Color.brandPurpleDeep.opacity(0.48)],
                                startPoint: .top, endPoint: .bottom))
                          : AnyShapeStyle(LinearGradient(
                                colors: [Color(hex: 0x9C8CD8).opacity(0.42),
                                         Color(hex: 0x6E5FB0).opacity(0.34)],
                                startPoint: .top, endPoint: .bottom)))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(LinearGradient(stops: [
                                .init(color: Color.white.opacity(selected ? 0.20 : 0.14),
                                      location: 0),
                                .init(color: Color.white.opacity(0), location: 0.35),
                            ], startPoint: .top, endPoint: .bottom))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(selected
                        ? AnyShapeStyle(LinearGradient(
                              colors: [Color.twinkoGold.opacity(0.85),
                                       Color.twinkoGold.opacity(0.45)],
                              startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(LinearGradient(stops: [
                              .init(color: Color.white.opacity(0.40), location: 0),
                              .init(color: Color(hex: 0xD1C4FF).opacity(0.18), location: 1),
                          ], startPoint: .top, endPoint: .bottom)),
                        lineWidth: 1)
            )
            .shadow(color: selected ? Color.twinkoGold.opacity(0.30)
                                    : Color.deepSpace.opacity(0.18),
                    radius: selected ? 9 : 6, y: 3)
    }
}

extension View {
    func twinkoNightChoice(cornerRadius: CGFloat = 14,
                           selected: Bool = false) -> some View {
        modifier(TwinkoNightChoiceSurface(cornerRadius: cornerRadius,
                                          selected: selected))
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
