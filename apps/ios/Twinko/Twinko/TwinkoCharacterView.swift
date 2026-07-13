import SwiftUI

/// Directional rendering of the Twinko character baseline (rounded
/// star, large oval eyes, warm cheeks, soft golden glow) per
/// docs/prototype/TWINKO_P0_APP_SHELL_MOCK_CHAT_SPEC.md §4. This is a
/// directional prototype rendering, not a pixel-perfect asset.
struct TwinkoCharacterView: View {
    var size: CGFloat = 160

    private var bodyGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.86, blue: 0.4),
                Color(red: 0.98, green: 0.6, blue: 0.22)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        ZStack {
            Image(systemName: "seal.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(bodyGradient)
                .frame(width: size, height: size)
                .shadow(color: Color.orange.opacity(0.35), radius: size * 0.08, y: size * 0.02)

            face
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Twinko")
    }

    private var face: some View {
        VStack(spacing: size * 0.07) {
            HStack(spacing: size * 0.16) {
                eye
                eye
            }
            smile
            HStack(spacing: size * 0.34) {
                cheek
                cheek
            }
            .offset(y: -size * 0.09)
        }
    }

    private var eye: some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .frame(width: size * 0.09, height: size * 0.09)
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.025, height: size * 0.025)
                .offset(x: -size * 0.02, y: -size * 0.02)
        }
    }

    private var cheek: some View {
        Circle()
            .fill(Color(red: 0.95, green: 0.45, blue: 0.25).opacity(0.55))
            .frame(width: size * 0.09, height: size * 0.05)
    }

    private var smile: some View {
        Path { path in
            let width = size * 0.2
            let height = size * 0.07
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(to: CGPoint(x: width, y: 0), control: CGPoint(x: width / 2, y: height))
        }
        .stroke(Color.black.opacity(0.85), style: StrokeStyle(lineWidth: size * 0.02, lineCap: .round))
        .frame(width: size * 0.2, height: size * 0.08)
    }
}

#Preview {
    TwinkoCharacterView()
}
