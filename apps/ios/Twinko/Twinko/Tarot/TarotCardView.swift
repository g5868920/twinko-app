import SwiftUI

/// Face-up card front from the canonical 78-card registry assets.
/// Reversed cards render rotated 180° (and are always also labeled in
/// text elsewhere — orientation never relies on rotation alone).
struct TarotCardFace: View {
    let drawn: TarotDrawnCard
    var width: CGFloat = 120

    var body: some View {
        Image(drawn.card.assetName)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: width * 1.5)
            .clipShape(RoundedRectangle(cornerRadius: width * 0.09))
            .overlay(
                RoundedRectangle(cornerRadius: width * 0.09)
                    .strokeBorder(Color.accentGold.opacity(0.7), lineWidth: 1.5)
            )
            .rotationEffect(.degrees(drawn.orientation == .reversed ? 180 : 0))
            .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
    }
}

/// Canonical face-down card (derived transparent copy of
/// `tarot_card_back_v1`), used for shuffle, previews, and reveal.
struct TarotCardBack: View {
    var width: CGFloat = 120

    var body: some View {
        Image("tarot_card_back_v1_transparent")
            .resizable()
            .scaledToFit()
            .frame(width: width, height: width * 1.5)
            .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
    }
}

/// Manual tap-to-flip reveal card (spec §6): small lift + scale on
/// tap, 3D Y-axis flip ~600 ms with the front swapping at 90°.
/// Reduce Motion crossfades instead. Face-down idle has a gentle
/// breathing float.
struct FlipTarotCard: View {
    let drawn: TarotDrawnCard
    @Binding var isRevealed: Bool
    var width: CGFloat = 120

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var prefs: PrefsStore
    @State private var angle: Double = 0
    @State private var lifted = false
    @State private var breathing = false

    var body: some View {
        ZStack {
            TarotCardBack(width: width)
                .opacity(showingFront ? 0 : 1)
            TarotCardFace(drawn: drawn, width: width)
                .opacity(showingFront ? 1 : 0)
                .rotation3DEffect(.degrees(reduceMotion ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(.degrees(reduceMotion ? 0 : angle), axis: (x: 0, y: 1, z: 0))
        .scaleEffect(lifted ? 1.03 : 1.0)
        .offset(y: lifted ? -6 : (breathing && !isRevealed && !reduceMotion ? -3 : 0))
        .onTapGesture { reveal() }
        .onAppear { startBreathing() }
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(.isButton)
    }

    private var accessibilityText: Text {
        let lang = prefs.language
        if isRevealed {
            return Text("\(drawn.card.displayName(for: lang))，\(drawn.orientation.label(lang))")
        }
        return Text(TarotStrings.faceDownCard(lang))
    }

    private var showingFront: Bool {
        reduceMotion ? isRevealed : angle > 90
    }

    private func startBreathing() {
        guard !reduceMotion, !isRevealed else { return }
        withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
            breathing = true
        }
    }

    private func reveal() {
        guard !isRevealed else { return }
        isRevealed = true
        if reduceMotion { return }
        withAnimation(.easeOut(duration: 0.12)) { lifted = true }
        withAnimation(.easeInOut(duration: 0.6).delay(0.08)) { angle = 180 }
        withAnimation(.easeOut(duration: 0.2).delay(0.6)) { lifted = false }
    }
}
