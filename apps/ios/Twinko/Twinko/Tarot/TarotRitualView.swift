import SwiftUI

// MARK: - Shuffle ritual

/// Shuffle magic transition (animation spec §5): Twinko activates
/// magic, a warm-gold energy ring expands, card backs rise / fan /
/// drift, then exactly the drawn number of cards separates from the
/// fan and settles into spread positions while the rest fade — a
/// Three-Card reading always ends with exactly three isolated cards.
/// The aura ring and gold dust are code-driven layers. Reduce Motion
/// shows a short static beat instead.
struct TarotShuffleStage: View {
    let cardCount: Int
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var prefs: PrefsStore
    @State private var ringScale: CGFloat = 0.4
    @State private var ringOpacity: Double = 0
    @State private var cardsUp = false
    @State private var gathered = false
    @State private var twinkoIn = false

    private static let fanCount = 5
    private var selectedIndices: [Int] {
        TarotShuffleChoreography.selectedIndices(fanCount: Self.fanCount, pick: cardCount)
    }

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        VStack(spacing: TwinkoSpacing.l) {
            Spacer()

            ZStack {
                // Code-driven energy ring (no standalone effect asset).
                Circle()
                    .strokeBorder(
                        LinearGradient(colors: [.twinkoGold.opacity(0.9), .twinkoGold.opacity(0.1)],
                                       startPoint: .top, endPoint: .bottom),
                        lineWidth: 2
                    )
                    .frame(width: 210, height: 210)
                    .scaleEffect(ringScale)
                    .opacity(ringOpacity)

                // Code-driven sparse gold dust (no standalone asset).
                if !reduceMotion {
                    TarotGoldDust(active: cardsUp)
                        .frame(width: 260, height: 260)
                }

                // Rising, fanning card backs; the selected cards then
                // separate and settle while the rest fade out.
                ForEach(0..<Self.fanCount, id: \.self) { index in
                    let selectedSlot = selectedIndices.firstIndex(of: index)
                    TarotCardBack(width: 64)
                        .rotationEffect(.degrees(
                            gathered ? 0 : (cardsUp ? Double(index - 2) * 16 : 0)))
                        .offset(x: gathered
                                    ? gatherX(selectedSlot)
                                    : (cardsUp ? CGFloat(index - 2) * 44 : 0),
                                y: gathered ? -118 : (cardsUp ? -108 : 40))
                        .opacity(gathered
                                    ? (selectedSlot == nil ? 0 : 1)
                                    : (cardsUp ? 1 : 0))
                }

                TarotTwinkoView(state: .magic, size: TarotTwinkoSize.hero)
                    .scaleEffect(twinkoIn ? 1.0 : 0.92)
                    .opacity(twinkoIn ? 1 : 0)
            }
            .frame(height: 320)

            Text(TarotStrings.shuffling(lang))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.85))

            Spacer()
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(TarotStrings.shuffling(lang)))
        .onAppear { run() }
    }

    /// Final x offset for a selected card slot, centered per count.
    private func gatherX(_ slot: Int?) -> CGFloat {
        guard let slot else { return 0 }
        let spacing: CGFloat = 74
        return (CGFloat(slot) - CGFloat(cardCount - 1) / 2) * spacing
    }

    private func run() {
        if reduceMotion {
            twinkoIn = true
            Task {
                try? await Task.sleep(nanoseconds: 700_000_000)
                onFinished()
            }
            return
        }
        // Activation → ring → fan → selected cards separate and settle.
        withAnimation(.easeOut(duration: 0.35)) { twinkoIn = true }
        withAnimation(.easeOut(duration: 0.9).delay(0.25)) {
            ringScale = 1.15
            ringOpacity = 0.7
        }
        withAnimation(.easeOut(duration: 0.6).delay(1.2)) { ringOpacity = 0 }
        withAnimation(.easeInOut(duration: 0.5).delay(0.45)) { cardsUp = true }
        withAnimation(.easeInOut(duration: 0.45).delay(1.55)) { gathered = true }
        Task {
            try? await Task.sleep(nanoseconds: 2_400_000_000)
            onFinished()
        }
    }
}

/// Sparse warm-gold dust: a fixed constellation of small circles that
/// drift gently outward and fade. Deterministic positions, low
/// opacity — a soft shimmer, not a glitter storm.
private struct TarotGoldDust: View {
    let active: Bool
    private static let points: [(x: CGFloat, y: CGFloat, s: CGFloat, d: Double)] = [
        (0.20, 0.30, 4, 0.0), (0.80, 0.25, 3, 0.3), (0.32, 0.70, 3, 0.5),
        (0.72, 0.68, 4, 0.15), (0.50, 0.12, 3, 0.4), (0.12, 0.55, 3, 0.6),
        (0.88, 0.50, 3, 0.2), (0.55, 0.85, 4, 0.35)
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(Self.points.enumerated()), id: \.offset) { _, p in
                Circle()
                    .fill(Color.twinkoGold.opacity(active ? 0.0 : 0.45))
                    .frame(width: p.s, height: p.s)
                    .position(x: geo.size.width * p.x, y: geo.size.height * p.y)
                    .offset(y: active ? -22 : 0)
                    .animation(.easeOut(duration: 1.4).delay(p.d), value: active)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Reveal

/// Manual reveal stage: face-down cards the user flips one by one.
/// The CTA enables only after every card is revealed (spec §4.4 —
/// never auto-flip).
struct TarotRevealStage: View {
    let cards: [TarotDrawnCard]
    let heading: String
    let onFinished: () -> Void

    @EnvironmentObject private var prefs: PrefsStore
    @State private var revealed: [Bool]

    init(cards: [TarotDrawnCard], heading: String, onFinished: @escaping () -> Void) {
        self.cards = cards
        self.heading = heading
        self.onFinished = onFinished
        _revealed = State(initialValue: Array(repeating: false, count: cards.count))
    }

    private var lang: AppLanguage { prefs.language }
    private var allRevealed: Bool { revealed.allSatisfy { $0 } }

    var body: some View {
        VStack(spacing: TwinkoSpacing.l) {
            Spacer()

            Text(heading)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.textInverseToken)

            HStack(spacing: TwinkoSpacing.m) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, drawn in
                    VStack(spacing: 8) {
                        FlipTarotCard(drawn: drawn,
                                      isRevealed: $revealed[index],
                                      width: cards.count == 1 ? 150 : 100)
                        if revealed[index] {
                            VStack(spacing: 2) {
                                if let position = drawn.position, position != .guidance {
                                    Text(position.label(lang))
                                        .font(.system(.caption2, design: .rounded).weight(.semibold))
                                        .foregroundStyle(Color.twinkoGold)
                                }
                                Text(drawn.card.displayName(for: lang))
                                    .font(.system(.caption, design: .rounded).weight(.semibold))
                                    .foregroundStyle(Color.textInverseToken)
                                Text(drawn.orientation.label(lang))
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundStyle(Color.textInverseToken.opacity(0.75))
                            }
                            .transition(.opacity)
                        }
                    }
                }
            }

            Spacer()

            if allRevealed {
                Button {
                    onFinished()
                } label: {
                    Text(TarotStrings.seeReading(lang))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.twinkoPrimary)
                .padding(.horizontal, TwinkoSpacing.l)
                .transition(.opacity)
            } else {
                Text(revealed.contains(true)
                     ? TarotStrings.tapNextCard(lang)
                     : TarotStrings.tapToFlip(lang))
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.deepSpace.opacity(0.35), in: Capsule())
            }
            Spacer(minLength: TwinkoSpacing.xl)
        }
        .animation(.easeOut(duration: 0.25), value: revealed)
    }
}
