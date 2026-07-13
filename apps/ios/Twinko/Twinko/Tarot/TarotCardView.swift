import SwiftUI

/// Original card visuals: deep violet faces with gold accents, drawn
/// with native shapes only. The inbound card-style reference guides the
/// mood; nothing is copied.
struct TarotCardFace: View {
    let card: TarotCard
    var width: CGFloat = 120

    var body: some View {
        VStack(spacing: width * 0.08) {
            Image(systemName: card.icon)
                .font(.system(size: width * 0.30, weight: .medium))
                .foregroundStyle(
                    LinearGradient(colors: [.twinkoGold, .warmOrange],
                                   startPoint: .top, endPoint: .bottom)
                )
            Text(card.name)
                .font(.system(size: width * 0.15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.softWhite)
        }
        .frame(width: width, height: width * 1.5)
        .background(
            RoundedRectangle(cornerRadius: width * 0.10)
                .fill(
                    LinearGradient(colors: [Color(red: 0.33, green: 0.24, blue: 0.55), .cosmicDeep],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: width * 0.10)
                .strokeBorder(Color.twinkoGold.opacity(0.8), lineWidth: 2)
                .padding(4)
        )
        .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
    }
}

struct TarotCardBack: View {
    var width: CGFloat = 120

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: width * 0.10)
                .fill(
                    LinearGradient(colors: [.cosmicPurple, .cosmicDeep],
                                   startPoint: .top, endPoint: .bottom)
                )
            RoundedRectangle(cornerRadius: width * 0.10)
                .strokeBorder(Color.twinkoGold.opacity(0.65), lineWidth: 2)
                .padding(4)
            TwinkoStar(innerRatio: 0.46)
                .fill(Color.twinkoGold.opacity(0.85))
                .frame(width: width * 0.36, height: width * 0.36)
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(Color.twinkoGold.opacity(0.5))
                    .frame(width: 4, height: 4)
                    .offset(x: index.isMultiple(of: 2) ? -width * 0.28 : width * 0.28,
                            y: index < 2 ? -width * 0.55 : width * 0.55)
            }
        }
        .frame(width: width, height: width * 1.5)
        .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
    }
}

/// Tap-to-flip card. Uses a 3D flip unless Reduce Motion is on, in
/// which case it crossfades.
struct FlipTarotCard: View {
    let card: TarotCard
    @Binding var isRevealed: Bool
    var width: CGFloat = 120

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var angle: Double = 0

    var body: some View {
        ZStack {
            TarotCardBack(width: width)
                .opacity(showingFront ? 0 : 1)
            TarotCardFace(card: card, width: width)
                .opacity(showingFront ? 1 : 0)
                .rotation3DEffect(.degrees(reduceMotion ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(.degrees(reduceMotion ? 0 : angle), axis: (x: 0, y: 1, z: 0))
        .onTapGesture { reveal() }
        .accessibilityLabel(isRevealed ? Text("牌面：\(card.name)") : Text("蓋著的牌，點兩下翻開"))
        .accessibilityAddTraits(.isButton)
    }

    private var showingFront: Bool {
        reduceMotion ? isRevealed : angle > 90
    }

    private func reveal() {
        guard !isRevealed else { return }
        isRevealed = true
        if reduceMotion {
            return
        }
        withAnimation(.easeInOut(duration: TwinkoMotion.reveal * 0.75)) {
            angle = 180
        }
    }
}
