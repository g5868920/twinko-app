import SwiftUI

// TEMPORARY VECTOR IMPLEMENTATION (D-055 founder-approved exception).
// The founder-delivered Home icon PNGs currently lack a real alpha
// channel (baked checkerboard), so the five Home mode icons are drawn
// here as native SwiftUI vectors, using the delivered PNGs strictly as
// visual references. These drawings are placeholders for the approved
// artwork: once transparent PNG exports are delivered and validated,
// they should replace this file's rendering. Do not treat these as the
// final visual target.

enum HomeMode: CaseIterable, Identifiable {
    case chat, tarot, zodiac, meditate, music
    var id: Self { self }
}

/// One reusable Home mode icon: a light-lavender outer ring, a purple
/// gradient disc, and a centered motif per mode — matching the shared
/// structure of the five reference PNGs. All five render at one fixed
/// diameter for equal visual weight.
struct HomeModeIcon: View {
    let mode: HomeMode
    var diameter: CGFloat = 68

    private static let ring = Color(red: 0.82, green: 0.74, blue: 0.95)

    var body: some View {
        ZStack {
            Circle()
                .fill(Self.ring)
            Circle()
                .fill(
                    LinearGradient(colors: discColors,
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .padding(diameter * 0.07)
            motif
        }
        .frame(width: diameter, height: diameter)
        .shadow(color: .black.opacity(0.18), radius: diameter * 0.07, y: diameter * 0.04)
        .accessibilityHidden(true)
    }

    private var discColors: [Color] {
        switch mode {
        case .chat:
            return [Color(red: 0.44, green: 0.38, blue: 0.80), Color(red: 0.31, green: 0.27, blue: 0.64)]
        case .tarot:
            return [Color(red: 0.50, green: 0.38, blue: 0.86), Color(red: 0.37, green: 0.28, blue: 0.70)]
        case .zodiac:
            return [Color(red: 0.58, green: 0.40, blue: 0.84), Color(red: 0.40, green: 0.31, blue: 0.74)]
        case .meditate:
            return [Color(red: 0.60, green: 0.50, blue: 0.90), Color(red: 0.46, green: 0.39, blue: 0.81)]
        case .music:
            return [Color(red: 0.52, green: 0.44, blue: 0.84), Color(red: 0.41, green: 0.34, blue: 0.73)]
        }
    }

    @ViewBuilder
    private var motif: some View {
        let d = diameter
        switch mode {
        case .chat:
            ZStack {
                ChatBubbleShape()
                    .fill(Color(red: 0.68, green: 0.83, blue: 0.96))
                    .frame(width: d * 0.46, height: d * 0.36)
                    .shadow(color: .black.opacity(0.15), radius: d * 0.02, y: d * 0.015)
                TwinkoStar(innerRatio: 0.45)
                    .fill(Color.twinkoGold)
                    .frame(width: d * 0.12, height: d * 0.12)
                    .offset(x: d * 0.22, y: -d * 0.18)
            }
        case .tarot:
            ZStack {
                RoundedRectangle(cornerRadius: d * 0.06)
                    .fill(Color(red: 0.46, green: 0.34, blue: 0.80))
                    .overlay(
                        RoundedRectangle(cornerRadius: d * 0.06)
                            .strokeBorder(Self.ring, lineWidth: d * 0.035)
                    )
                    .overlay(
                        TwinkoStar(innerRatio: 0.45)
                            .fill(Self.ring)
                            .frame(width: d * 0.15, height: d * 0.15)
                    )
                    .frame(width: d * 0.34, height: d * 0.46)
                    .rotationEffect(.degrees(14))
                    .shadow(color: .black.opacity(0.2), radius: d * 0.02, y: d * 0.015)
                TwinkoStar(innerRatio: 0.45)
                    .fill(Color.twinkoGold.opacity(0.9))
                    .frame(width: d * 0.09, height: d * 0.09)
                    .offset(x: -d * 0.24, y: -d * 0.2)
                TwinkoStar(innerRatio: 0.45)
                    .fill(Color.twinkoGold.opacity(0.7))
                    .frame(width: d * 0.06, height: d * 0.06)
                    .offset(x: d * 0.26, y: d * 0.22)
            }
        case .zodiac:
            ZStack {
                TwinkoStar(innerRatio: 0.52, tipRounding: 0.22, valleyRounding: 0.14)
                    .fill(
                        LinearGradient(colors: [Color(red: 1.0, green: 0.78, blue: 0.25),
                                                Color(red: 0.98, green: 0.56, blue: 0.16)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: d * 0.5, height: d * 0.5)
                    .shadow(color: .black.opacity(0.18), radius: d * 0.02, y: d * 0.015)
                Circle()
                    .fill(Color.white.opacity(0.85))
                    .frame(width: d * 0.05, height: d * 0.05)
                    .offset(x: -d * 0.27, y: -d * 0.16)
                Circle()
                    .fill(Color.white.opacity(0.65))
                    .frame(width: d * 0.035, height: d * 0.035)
                    .offset(x: d * 0.27, y: d * 0.2)
            }
        case .meditate:
            ZStack {
                CrescentShape()
                    .fill(Color(red: 0.93, green: 0.91, blue: 0.99))
                    .frame(width: d * 0.44, height: d * 0.44)
                    .shadow(color: .black.opacity(0.15), radius: d * 0.02, y: d * 0.015)
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: d * 0.04, height: d * 0.04)
                    .offset(x: d * 0.2, y: -d * 0.2)
            }
        case .music:
            ZStack {
                BeamedNoteShape()
                    .fill(Color(red: 0.80, green: 0.74, blue: 0.96))
                    .frame(width: d * 0.42, height: d * 0.44)
                    .shadow(color: .black.opacity(0.15), radius: d * 0.02, y: d * 0.015)
                TwinkoStar(innerRatio: 0.45)
                    .fill(Color.twinkoGold.opacity(0.8))
                    .frame(width: d * 0.08, height: d * 0.08)
                    .offset(x: d * 0.24, y: -d * 0.22)
            }
        }
    }
}

// MARK: - Motif shapes

/// Rounded speech bubble with a small tail, per the Chat reference.
private struct ChatBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let body = CGRect(x: rect.minX, y: rect.minY,
                          width: rect.width, height: rect.height * 0.82)
        path.addRoundedRect(in: body, cornerSize: CGSize(width: body.height * 0.45,
                                                         height: body.height * 0.45))
        // Tail toward the lower right.
        path.move(to: CGPoint(x: rect.midX + rect.width * 0.10, y: body.maxY - 1))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX + rect.width * 0.30, y: rect.maxY),
            control: CGPoint(x: rect.midX + rect.width * 0.14, y: rect.maxY - rect.height * 0.06)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX + rect.width * 0.34, y: body.maxY - 1),
            control: CGPoint(x: rect.midX + rect.width * 0.30, y: rect.maxY - rect.height * 0.08)
        )
        path.closeSubpath()
        return path
    }
}

/// Crescent moon (true path subtraction of an offset circle), per the
/// Meditate reference.
private struct CrescentShape: Shape {
    func path(in rect: CGRect) -> Path {
        let main = Path(ellipseIn: rect)
        let bite = Path(ellipseIn: rect
            .offsetBy(dx: rect.width * 0.30, dy: -rect.height * 0.12)
            .insetBy(dx: rect.width * 0.04, dy: rect.height * 0.04))
        return main.subtracting(bite)
    }
}

/// Classic beamed double note (♫), per the Music reference.
private struct BeamedNoteShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stemWidth = rect.width * 0.12
        let headHeight = rect.height * 0.26
        let headWidth = rect.width * 0.34

        // Left note head
        path.addEllipse(in: CGRect(x: rect.minX, y: rect.maxY - headHeight,
                                   width: headWidth, height: headHeight))
        // Right note head
        path.addEllipse(in: CGRect(x: rect.maxX - headWidth, y: rect.maxY - headHeight * 1.4,
                                   width: headWidth, height: headHeight))
        // Left stem
        path.addRoundedRect(
            in: CGRect(x: rect.minX + headWidth - stemWidth, y: rect.minY + rect.height * 0.10,
                       width: stemWidth, height: rect.height * 0.82 - headHeight / 2),
            cornerSize: CGSize(width: stemWidth / 2, height: stemWidth / 2)
        )
        // Right stem
        path.addRoundedRect(
            in: CGRect(x: rect.maxX - stemWidth, y: rect.minY,
                       width: stemWidth, height: rect.height * 0.84 - headHeight / 2),
            cornerSize: CGSize(width: stemWidth / 2, height: stemWidth / 2)
        )
        // Beam connecting the stems (slightly slanted)
        var beam = Path()
        beam.move(to: CGPoint(x: rect.minX + headWidth - stemWidth, y: rect.minY + rect.height * 0.10))
        beam.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        beam.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.18))
        beam.addLine(to: CGPoint(x: rect.minX + headWidth - stemWidth, y: rect.minY + rect.height * 0.28))
        beam.closeSubpath()
        path.addPath(beam)
        return path
    }
}

#Preview("All icons") {
    HStack(spacing: 16) {
        ForEach(HomeMode.allCases) { mode in
            HomeModeIcon(mode: mode)
        }
    }
    .padding()
    .background(TwinkoBackground.sky)
}
