import SwiftUI

// MARK: - Tarot Twinko character states

/// Centralized Tarot Twinko asset-state mapping (founder review
/// 2026-07-16). Canonical set: idle / gentle concern / magic. The old
/// summary and interpreting poses are deprecated — summary states use
/// the idle character plus code-rendered effects.
enum TarotTwinkoState {
    case idle
    /// Empathetic state for sensitive moments — gently raised inner
    /// brows and a small reassuring smile (delivered 2026-07-16).
    case gentleConcern
    case magic
    /// Focused, gentle shuffle-casting state (redesign §18). The
    /// canonical `twinko_tarot_casting_v1` asset has not been
    /// delivered; the delivered magic pose has furrowed brows the spec
    /// rules out, so this alias resolves to the approved idle wizard
    /// pose (gentle expression) with casting energy rendered in code.
    /// Swap this one mapping when the canonical asset arrives.
    case casting

    var assetName: String {
        switch self {
        case .idle:
            return "twinko_tarot_idle_v1_transparent"
        case .gentleConcern:
            return "twinko_tarot_gentle_concern_v1_transparent"
        case .magic:
            return "twinko_tarot_magic_v1_transparent"
        case .casting:
            return "twinko_tarot_idle_v1_transparent"
        }
    }
}

/// Semantic Tarot Twinko sizes (spec §3.7).
enum TarotTwinkoSize {
    static let hero: CGFloat = 170
    static let supporting: CGFloat = 112
    static let mini: CGFloat = 56
}

/// Tarot Twinko with its runtime-composed effect layer. Effects live
/// in code, never baked into the character PNG; Reduce Motion swaps
/// motion for static treatment.
struct TarotTwinkoView: View {
    enum Effect { case none, idleGlow, summaryAura }

    let state: TarotTwinkoState
    var size: CGFloat = TarotTwinkoSize.supporting
    var effect: Effect = .none

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var floating = false

    var body: some View {
        ZStack {
            switch effect {
            case .none:
                EmptyView()
            case .idleGlow:
                Circle()
                    .fill(Color.twinkoGold)
                    .frame(width: size * 1.05, height: size * 1.05)
                    .blur(radius: 24)
                    .opacity(0.12)
            case .summaryAura:
                // Warm stable halo + sparse static sparkles — the
                // summary presentation uses the idle character.
                Circle()
                    .fill(Color.twinkoGold)
                    .frame(width: size * 1.1, height: size * 1.1)
                    .blur(radius: 22)
                    .opacity(0.18)
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(Color.twinkoGold.opacity(0.55))
                        .frame(width: 3.5, height: 3.5)
                        .offset(x: [-0.55, 0.6, -0.4, 0.5][index] * size * 0.62,
                                y: [-0.45, -0.3, 0.5, 0.42][index] * size * 0.55)
                }
            }
            Image(state.assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .offset(y: floatOffset)
        }
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion, effect == .idleGlow else { return }
            withAnimation(.easeInOut(duration: 3.6).repeatForever(autoreverses: true)) {
                floating = true
            }
        }
    }

    private var floatOffset: CGFloat {
        guard !reduceMotion, effect == .idleGlow else { return 0 }
        return floating ? -4 : 4
    }
}

/// Pure choreography helper so the final selected-card count is
/// testable apart from animation: a Three-Card reading must isolate
/// exactly three cards from the shuffle fan.
enum TarotShuffleChoreography {
    /// Indices of the fanned deck cards that converge into the final
    /// spread positions (centered within `fanCount`).
    static func selectedIndices(fanCount: Int, pick: Int) -> [Int] {
        guard pick > 0, fanCount > 0 else { return [] }
        let count = min(pick, fanCount)
        let start = (fanCount - count) / 2
        return Array(start..<(start + count))
    }
}

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
        // Exactly one accessibility element per card — inner image
        // layers must not surface as duplicates (spec §25).
        .accessibilityElement(children: .ignore)
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
