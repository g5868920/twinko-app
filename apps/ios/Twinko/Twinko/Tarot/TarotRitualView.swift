import SwiftUI

// MARK: - Vortex shuffle ritual (redesign §17)

/// The magical rising-vortex shuffle: soft energy awakens near the
/// lower altar, a bounded pool of card backs rises and spirals gently
/// around the casting Twinko, then the vortex slows and converges into
/// exactly the drawn number of cards (one or three) while the rest
/// dissolve. Card identities come from the draw engine — choreography
/// never selects cards. Reduce Motion shows a simple rising fade with
/// the same timing/state logic. Total ≈ 2.9 s: calm, premium,
/// ritualistic — never frantic or slot-machine-like.
struct TarotShuffleStage: View {
    let cardCount: Int
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var prefs: PrefsStore
    @State private var start = Date()
    @State private var reducedCardsUp = false

    /// Reusable visual pool (§17): enough for a layered vortex without
    /// rendering 78 heavy views.
    private static let poolCount = 14
    private static let totalDuration: TimeInterval = 2.9
    private static let convergeStart: TimeInterval = 1.95
    private static let convergeDuration: TimeInterval = 0.65

    private var selectedIndices: [Int] {
        TarotShuffleChoreography.selectedIndices(fanCount: Self.poolCount,
                                                 pick: cardCount)
    }

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        VStack(spacing: TwinkoSpacing.l) {
            Spacer()

            ZStack {
                if reduceMotion {
                    reducedVortex
                } else {
                    vortex
                }
            }
            .frame(height: 380)

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

    // MARK: Full vortex

    private var vortex: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSince(start)
            ZStack {
                // Phase A — energy awakening near the lower altar.
                Ellipse()
                    .fill(
                        RadialGradient(colors: [Color.twinkoGold.opacity(0.4),
                                                Color.brandPurple.opacity(0.15),
                                                .clear],
                                       center: .center, startRadius: 4, endRadius: 130)
                    )
                    .frame(width: 240, height: 90)
                    .offset(y: 165)
                    .opacity(riseIn(t, from: 0.05, over: 0.4) * (1 - converge(t)))
                    .blur(radius: 6)

                // Restrained gold dust while the vortex is alive.
                TarotGoldDust(active: t > 0.5)
                    .frame(width: 280, height: 300)

                // Phase B/C — the card vortex: varied depth, scale,
                // rotation, delay and speed; selected cards converge,
                // the rest dissolve and fall away.
                ForEach(0..<Self.poolCount, id: \.self) { index in
                    let s = cardState(index: index, t: t)
                    TarotCardBack(width: 56)
                        .scaleEffect(s.scale)
                        .rotationEffect(.degrees(s.rotation))
                        .offset(x: s.x, y: s.y)
                        .opacity(s.opacity)
                        .zIndex(s.z)
                }

                // The casting Twinko: gentle, focused — with a
                // code-rendered energy ring (no baked effects).
                castingTwinko(t)
                    .zIndex(0.5)
            }
        }
    }

    private func castingTwinko(_ t: TimeInterval) -> some View {
        ZStack {
            Circle()
                .strokeBorder(
                    LinearGradient(colors: [.twinkoGold.opacity(0.9),
                                            .twinkoGold.opacity(0.08)],
                                   startPoint: .top, endPoint: .bottom),
                    lineWidth: 2
                )
                .frame(width: 210, height: 210)
                .scaleEffect(0.5 + 0.65 * riseIn(t, from: 0.2, over: 0.9))
                .opacity(riseIn(t, from: 0.2, over: 0.6) * (1 - riseIn(t, from: 1.4, over: 0.6)))
            Circle()
                .fill(Color.twinkoGold)
                .frame(width: 150, height: 150)
                .blur(radius: 30)
                .opacity(0.14 + 0.05 * sin(t * 2.2))
            TarotTwinkoView(state: .casting, size: TarotTwinkoSize.hero)
                .scaleEffect(0.92 + 0.08 * riseIn(t, from: 0, over: 0.35))
                .opacity(riseIn(t, from: 0, over: 0.35))
        }
    }

    /// Per-card vortex state at time `t` — deterministic per index so
    /// the motion is layered but stable (no per-frame randomness).
    private func cardState(index: Int, t: TimeInterval)
        -> (x: CGFloat, y: CGFloat, scale: CGFloat, rotation: Double,
            opacity: Double, z: Double) {
        let delay = Double(index) * 0.06
        let speed = 0.42 + Double((index * 13) % 5) * 0.07      // revolutions/s
        let radius = 92.0 + Double((index * 37) % 58)
        let baseScale = 0.55 + Double((index * 23) % 35) / 100
        let baseAngle = Double(index) / Double(Self.poolCount) * 2 * .pi

        let rise = easeOut(clamp((t - delay) / 1.1))
        let c = converge(t)
        let angle = baseAngle + t * speed * 2 * .pi

        // Spiral orbit: rises from the lower altar into a flattened
        // ellipse around Twinko; the vortex slows as it converges.
        let orbitX = cos(angle) * radius * rise
        let orbitY = 250 * (1 - rise) - 30 + sin(angle) * radius * 0.32 * rise
        let orbitRot = sin(angle) * 16
        let depth = sin(angle)   // >0 = in front of Twinko

        if let slot = selectedIndices.firstIndex(of: index) {
            // Converges into its final spread position.
            let spacing: CGFloat = cardCount == 1 ? 0 : 86
            let targetX = (CGFloat(slot) - CGFloat(cardCount - 1) / 2) * spacing
            let e = easeInOut(c)
            return (x: lerp(orbitX, targetX, e),
                    y: lerp(orbitY, -34, e),
                    scale: lerp(baseScale, 1.0, e),
                    rotation: orbitRot * (1 - e),
                    opacity: Double(rise > 0 ? 1 : 0),
                    z: 1 + e + max(0, depth))
        }
        // Dissolves and falls away as the vortex ends.
        return (x: orbitX,
                y: orbitY + 90 * easeInOut(c),
                scale: baseScale * (1 - 0.35 * c),
                rotation: orbitRot,
                opacity: Double(rise > 0 ? 1 : 0) * (1 - easeInOut(c)),
                z: max(0, depth))
    }

    // MARK: Reduce Motion fallback (§19)

    /// Several cards fading gently upward, converging through scale
    /// and opacity — same draw result, same completion timing.
    private var reducedVortex: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                let selectedSlot = TarotShuffleChoreography
                    .selectedIndices(fanCount: 5, pick: cardCount)
                    .firstIndex(of: index)
                let spacing: CGFloat = cardCount == 1 ? 0 : 86
                TarotCardBack(width: 56)
                    .scaleEffect(reducedCardsUp ? (selectedSlot == nil ? 0.8 : 1.0) : 0.85)
                    .offset(x: reducedCardsUp && selectedSlot != nil
                                ? (CGFloat(selectedSlot!) - CGFloat(cardCount - 1) / 2) * spacing
                                : CGFloat(index - 2) * 34,
                            y: reducedCardsUp ? -34 : 130)
                    .opacity(reducedCardsUp ? (selectedSlot == nil ? 0 : 1) : 0.0)
                    .animation(.easeInOut(duration: 1.1).delay(Double(index) * 0.08),
                               value: reducedCardsUp)
            }
            TarotTwinkoView(state: .casting, size: TarotTwinkoSize.hero)
        }
    }

    private func run() {
        start = Date()
        if reduceMotion {
            withAnimation { reducedCardsUp = true }
            Task {
                try? await Task.sleep(nanoseconds: 1_600_000_000)
                onFinished()
            }
            return
        }
        Task {
            try? await Task.sleep(nanoseconds: UInt64(Self.totalDuration * 1_000_000_000))
            onFinished()
        }
    }

    // MARK: Small math helpers

    private func clamp(_ v: Double) -> Double { min(max(v, 0), 1) }
    private func easeOut(_ p: Double) -> Double { 1 - pow(1 - p, 2.4) }
    private func easeInOut(_ p: Double) -> Double { p * p * (3 - 2 * p) }
    private func lerp(_ a: CGFloat, _ b: CGFloat, _ p: Double) -> CGFloat {
        a + (b - a) * CGFloat(p)
    }
    private func converge(_ t: TimeInterval) -> Double {
        clamp((t - Self.convergeStart) / Self.convergeDuration)
    }
    private func riseIn(_ t: TimeInterval, from: TimeInterval,
                        over: TimeInterval) -> Double {
        clamp((t - from) / over)
    }
}

/// Sparse warm-gold dust: a fixed constellation of small circles that
/// drift gently outward and fade. Deterministic positions, low
/// opacity — a soft shimmer, not a glitter storm.
struct TarotGoldDust: View {
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
/// The CTA enables only after every card is revealed (never
/// auto-flip). Revealed cards receive the subtle gold activation glow.
/// When entered via Back from the result, cards stay revealed —
/// backward navigation never re-hides or redraws a reading (§41).
struct TarotRevealStage: View {
    let cards: [TarotDrawnCard]
    let heading: String
    let onFinished: () -> Void

    @EnvironmentObject private var prefs: PrefsStore
    @State private var revealed: [Bool]

    init(cards: [TarotDrawnCard], heading: String,
         initiallyRevealed: Bool = false, onFinished: @escaping () -> Void) {
        self.cards = cards
        self.heading = heading
        self.onFinished = onFinished
        _revealed = State(initialValue: Array(repeating: initiallyRevealed,
                                              count: cards.count))
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
                            .tarotRevealedGlow(revealed[index])
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
                .buttonStyle(.tarotMagicPrimary)
                .padding(.horizontal, TwinkoSpacing.l)
                .transition(.opacity)
                .accessibilityIdentifier("tarotSeeReading")
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
