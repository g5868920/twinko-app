import SwiftUI

// MARK: - Primary button

/// Warm capsule button used for every primary CTA.
struct TwinkoPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.twinkoHeadline)
            .foregroundStyle(.white)
            .padding(.vertical, 15)
            .padding(.horizontal, TwinkoSpacing.xl)
            .frame(minHeight: 44)
            .background(
                LinearGradient(colors: [.twinkoGold, .warmOrange],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                in: Capsule()
            )
            .shadow(color: Color.warmOrange.opacity(0.45), radius: 10, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: TwinkoMotion.quick), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == TwinkoPrimaryButtonStyle {
    static var twinkoPrimary: TwinkoPrimaryButtonStyle { TwinkoPrimaryButtonStyle() }
}

// MARK: - Card

/// Soft rounded information card. `tone` picks a light card for sky
/// screens or a translucent dark card for night/cosmic screens.
struct TwinkoCard<Content: View>: View {
    enum Tone { case light, dark }
    var tone: Tone = .light
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(TwinkoSpacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background, in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
            .shadow(color: .black.opacity(tone == .light ? 0.08 : 0.25), radius: 8, y: 3)
    }

    private var background: some ShapeStyle {
        switch tone {
        case .light: return AnyShapeStyle(Color.softWhite.opacity(0.94))
        case .dark: return AnyShapeStyle(Color.white.opacity(0.10))
        }
    }
}

// MARK: - Feature tile

/// Home Menu mode tile: circular icon above a label. Disabled tiles keep
/// the shared aesthetic but read clearly as 「即將推出」 — never broken.
struct FeatureTile: View {
    let title: String
    let systemImage: String
    let iconColors: [Color]
    var isEnabled: Bool = true

    var body: some View {
        VStack(spacing: TwinkoSpacing.s) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: iconColors,
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 62, height: 62)
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                Image(systemName: systemImage)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text(title)
                .font(.twinkoHeadline)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
            if !isEnabled {
                Text("即將推出")
                    .font(.twinkoCaption)
                    .foregroundStyle(.white.opacity(0.95))
                    .padding(.horizontal, TwinkoSpacing.s)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.28), in: Capsule())
            }
        }
        .frame(minWidth: 88, minHeight: 44)
        .opacity(isEnabled ? 1 : 0.55)
        .saturation(isEnabled ? 1 : 0.35)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isEnabled ? Text(title) : Text("\(title)，即將推出"))
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Thinking dots

/// Three softly pulsing dots for loading states. Falls back to a static
/// ellipsis when Reduce Motion is on.
struct ThinkingDotsView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase = false
    var tint: Color = .inkNavy

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(tint.opacity(0.7))
                    .frame(width: 7, height: 7)
                    .opacity(reduceMotion ? 1 : (phase ? 1 : 0.25))
                    .animation(
                        reduceMotion ? nil :
                            .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.18),
                        value: phase
                    )
            }
        }
        .onAppear { phase = true }
        .accessibilityLabel(Text("思考中"))
    }
}
