import SwiftUI

// MARK: - Vortex shuffle ritual (redesign §17)

/// The magical rising-vortex shuffle: soft energy awakens near the
/// lower altar, a bounded pool of card backs rises and spirals gently
/// around the casting Twinko, then the vortex slows and converges into
/// exactly the drawn number of cards (one or three) while the rest
/// dissolve. Card identities come from the draw engine — choreography
/// never selects cards. Reduce Motion shows a simple rising fade with
/// the same timing/state logic. Animation ≈ 3.7 s plus a ≈ 0.7 s
/// suspended hold: a calm magical ritual — never frantic or
/// slot-machine-like.
struct TarotShuffleStage: View {
    let cardCount: Int
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var prefs: PrefsStore
    @State private var start = Date()
    @State private var reducedCardsUp = false
    @State private var emerged = false

    /// Reusable visual pool (§17): enough for a layered vortex without
    /// rendering 78 heavy views.
    private static let poolCount = 14
    /// Shuffle-state Twinko is deliberately larger than the standard
    /// hero — it should feel like it is channeling the reading.
    static let twinkoSize: CGFloat = 216
    private static let totalDuration: TimeInterval = 4.4
    private static let convergeStart: TimeInterval = 3.1
    private static let convergeDuration: TimeInterval = 0.6
    /// Convergence completes ≈3.7 s (spec: 3.2–4.2 s animation); the
    /// settled cards then hold suspended ≈0.7 s before the transition
    /// (spec hold 0.5–0.8 s).

    /// Settled cards hover clearly above Twinko's hat, positioned
    /// relative to the character frame (half size 108 + clearance +
    /// enlarged card half-height) — never on the forehead or hat.
    var settleY: CGFloat { cardCount == 1 ? -204 : -196 }
    /// Enlarged final cards: single +30%; three-card group +18–25%
    /// with the center card slightly larger than the sides.
    func settleScale(slot: Int) -> CGFloat {
        cardCount == 1 ? 1.30 : (slot == 1 ? 1.25 : 1.18)
    }

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
            .frame(height: 560)

            Text(emerged ? TarotStrings.cardsEmerged(lang) : TarotStrings.shuffling(lang))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.85))
                .animation(.easeInOut(duration: 0.4), value: emerged)

            Spacer()
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(emerged ? TarotStrings.cardsEmerged(lang)
                                         : TarotStrings.shuffling(lang)))
        .onAppear { run() }
    }

    // MARK: Full vortex

    private var vortex: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSince(start)
            ZStack {
                // Phase A — blue-violet energy awakening at the altar.
                Ellipse()
                    .fill(
                        RadialGradient(colors: [TarotCTAPalette.violetGlow.opacity(0.5),
                                                Color(hex: 0x5B7BE8).opacity(0.2),
                                                .clear],
                                       center: .center, startRadius: 4, endRadius: 160)
                    )
                    .frame(width: 300, height: 110)
                    .offset(y: 210)
                    .opacity(riseIn(t, from: 0.05, over: 0.4) * (1 - converge(t)))
                    .blur(radius: 7)

                // Restrained stardust: violet magical energy + a few
                // gold accents (gold = chosen / resolved).
                TarotStardust(active: t > 0.5, tint: TarotCTAPalette.violetGlow)
                    .frame(width: 340, height: 400)
                TarotStardust(active: t > 0.8, tint: .twinkoGold)
                    .frame(width: 250, height: 300)
                    .opacity(0.7)

                // Icy-blue / blue-violet star glints twinkling at the
                // vortex edges — visible but never noisy, kept off
                // Twinko's face, and gone once the cards converge.
                TarotShuffleGlints(t: t, fade: 1 - easeInOut(converge(t)))
                    .frame(width: 370, height: 460)

                // Phase B/C — the card vortex: varied depth, scale,
                // rotation, delay and speed; selected cards converge,
                // the rest dissolve and fall away.
                ForEach(0..<Self.poolCount, id: \.self) { index in
                    let s = cardState(index: index, t: t)
                    let chosen = selectedIndices.contains(index)
                    let e = easeInOut(converge(t))
                    TarotCardBack(width: 66)
                        // Blue-violet trail while swirling; the chosen
                        // cards resolve into a gold aura as they settle.
                        .shadow(color: TarotCTAPalette.violetGlow
                                    .opacity(0.55 * (1 - e)), radius: 9)
                        .shadow(color: Color.twinkoGold
                                    .opacity(chosen ? 0.5 * e : 0), radius: 10)
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

    /// A larger, actively channeling Twinko with a blue-violet energy
    /// ring and aura (blue-violet = magical energy in motion).
    private func castingTwinko(_ t: TimeInterval) -> some View {
        ZStack {
            // Incomplete blue-violet energy ring: two soft arc segments
            // slowly rotating — never one plain solid circle.
            ZStack {
                Circle()
                    .trim(from: 0.06, to: 0.42)
                    .stroke(
                        LinearGradient(colors: [TarotCTAPalette.violetGlow.opacity(0.85),
                                                Color(hex: 0x5B7BE8).opacity(0.15)],
                                       startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                    )
                Circle()
                    .trim(from: 0.55, to: 0.93)
                    .stroke(
                        LinearGradient(colors: [Color(hex: 0x5B7BE8).opacity(0.6),
                                                TarotCTAPalette.violetGlow.opacity(0.1)],
                                       startPoint: .bottom, endPoint: .top),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
            }
            .frame(width: 274, height: 274)
            .rotationEffect(.degrees(t * 26))
            .scaleEffect(0.5 + 0.65 * riseIn(t, from: 0.2, over: 0.9))
            // The blue ring accompanies most of the longer ritual and
            // dissolves as convergence begins.
            .opacity(riseIn(t, from: 0.2, over: 0.6) * (1 - riseIn(t, from: 2.6, over: 0.7)))
            Circle()
                .fill(TarotCTAPalette.violetGlow)
                .frame(width: 190, height: 190)
                .blur(radius: 36)
                .opacity(0.20 + 0.06 * sin(t * 2.2))
            TarotTwinkoView(state: .casting, size: Self.twinkoSize)
                .scaleEffect(0.92 + 0.08 * riseIn(t, from: 0, over: 0.35))
                .opacity(riseIn(t, from: 0, over: 0.35))
        }
    }

    /// Per-card vortex state at time `t` — deterministic per index so
    /// the motion is layered but stable (no per-frame randomness).
    private func cardState(index: Int, t: TimeInterval)
        -> (x: CGFloat, y: CGFloat, scale: CGFloat, rotation: Double,
            opacity: Double, z: Double) {
        let delay = Double(index) * 0.07
        let speed = 0.29 + Double((index * 13) % 5) * 0.048     // revolutions/s (slower ritual)
        let radius = 155.0 + Double((index * 37) % 100)         // wider orbit around Twinko
        let baseScale = 0.58 + Double((index * 23) % 35) / 100
        let baseAngle = Double(index) / Double(Self.poolCount) * 2 * .pi

        let rise = easeOut(clamp((t - delay) / 1.1))
        let c = converge(t)
        let angle = baseAngle + t * speed * 2 * .pi

        // Tornado spiral: cards emerge from below the reading area and
        // climb vertically while orbiting — the funnel narrows a touch
        // as it rises, and the vortex slows into the convergence.
        // Slight per-card drift keeps the paths elliptical and
        // imperfect rather than a clean carousel circle.
        let drift = sin(t * 0.9 + Double(index)) * 10
        let funnel = 1.0 - 0.18 * rise
        let orbitX = cos(angle) * radius * rise * funnel + drift
        let orbitY = 380 * (1 - rise) - 48 + sin(angle) * radius * 0.38 * rise
        let orbitRot = sin(angle) * 16
        let depth = sin(angle)   // >0 = in front of Twinko

        if let slot = selectedIndices.firstIndex(of: index) {
            // Converges into a row hovering clearly above Twinko's
            // head — never on the forehead or hat (§ separation rule).
            let spacing: CGFloat = cardCount == 1 ? 0 : 96
            let targetX = (CGFloat(slot) - CGFloat(cardCount - 1) / 2) * spacing
            let e = easeInOut(c)
            return (x: lerp(orbitX, targetX, e),
                    y: lerp(orbitY, settleY, e),
                    scale: lerp(baseScale, settleScale(slot: slot), e),
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
    /// and opacity — same draw result, with a static blue-violet glow
    /// standing in for the sparkle layer (§19).
    private var reducedVortex: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(colors: [TarotCTAPalette.violetGlow.opacity(0.35),
                                            Color(hex: 0x5B7BE8).opacity(0.18),
                                            .clear],
                                   center: .center, startRadius: 10, endRadius: 190)
                )
                .frame(width: 380, height: 380)
                .blur(radius: 12)
                .accessibilityHidden(true)
            ForEach(0..<5, id: \.self) { index in
                let selectedSlot = TarotShuffleChoreography
                    .selectedIndices(fanCount: 5, pick: cardCount)
                    .firstIndex(of: index)
                let spacing: CGFloat = cardCount == 1 ? 0 : 96
                TarotCardBack(width: 66)
                    .scaleEffect(reducedCardsUp
                                 ? (selectedSlot == nil ? 0.8 : settleScale(slot: selectedSlot!))
                                 : 0.85)
                    .offset(x: reducedCardsUp && selectedSlot != nil
                                ? (CGFloat(selectedSlot!) - CGFloat(cardCount - 1) / 2) * spacing
                                : CGFloat(index - 2) * 34,
                            y: reducedCardsUp ? settleY : 150)
                    .opacity(reducedCardsUp ? (selectedSlot == nil ? 0 : 1) : 0.0)
                    .animation(.easeInOut(duration: 1.1).delay(Double(index) * 0.08),
                               value: reducedCardsUp)
            }
            TarotTwinkoView(state: .casting, size: Self.twinkoSize)
        }
    }

    private func run() {
        start = Date()
        if reduceMotion {
            withAnimation { reducedCardsUp = true }
            Task {
                // Long enough to still communicate ritual progress.
                try? await Task.sleep(nanoseconds: 1_800_000_000)
                emerged = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                onFinished()
            }
            return
        }
        Task {
            // Copy switches once convergence completes; the settled
            // cards hold suspended before the transition to Reveal,
            // marked with one light completion haptic.
            let emergeAt = Self.convergeStart + Self.convergeDuration + 0.1
            try? await Task.sleep(nanoseconds: UInt64(emergeAt * 1_000_000_000))
            emerged = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            try? await Task.sleep(nanoseconds:
                UInt64((Self.totalDuration - emergeAt) * 1_000_000_000))
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

/// Sparse magical stardust: a fixed constellation of small circles
/// that drift gently upward and fade. Deterministic positions, low
/// opacity — a soft shimmer, not a glitter storm. Tint carries the
/// brand logic (violet = energy, gold = chosen).
struct TarotStardust: View {
    let active: Bool
    var tint: Color = .twinkoGold
    private static let points: [(x: CGFloat, y: CGFloat, s: CGFloat, d: Double)] = [
        (0.20, 0.30, 4, 0.0), (0.80, 0.25, 3, 0.3), (0.32, 0.70, 3, 0.5),
        (0.72, 0.68, 4, 0.15), (0.50, 0.12, 3, 0.4), (0.12, 0.55, 3, 0.6),
        (0.88, 0.50, 3, 0.2), (0.55, 0.85, 4, 0.35)
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(Self.points.enumerated()), id: \.offset) { _, p in
                Circle()
                    .fill(tint.opacity(active ? 0.0 : 0.5))
                    .frame(width: p.s, height: p.s)
                    .position(x: geo.size.width * p.x, y: geo.size.height * p.y)
                    .offset(y: active ? -26 : 0)
                    .animation(.easeOut(duration: 1.4).delay(p.d), value: active)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Icy-blue and blue-violet star glints for the shuffle ritual: a
/// fixed constellation of small sparkles with phase-offset opacity
/// pulses and a gentle vertical shimmer, driven by the vortex clock —
/// deterministic, no particle system. Positions ring the vortex edges
/// so nothing sits over Twinko's face; `fade` removes the layer as the
/// shuffle converges.
struct TarotShuffleGlints: View {
    let t: TimeInterval
    let fade: Double

    static let iceBlue = Color(hex: 0x9FD4FF)
    private static let points: [(x: CGFloat, y: CGFloat, size: CGFloat,
                                 phase: Double, blueViolet: Bool)] = [
        (0.10, 0.18, 17, 0.0, false), (0.88, 0.14, 14, 1.6, true),
        (0.16, 0.62, 13, 2.9, true),  (0.90, 0.55, 18, 0.9, false),
        (0.30, 0.06, 13, 2.1, false), (0.68, 0.04, 14, 3.4, true),
        (0.05, 0.40, 14, 4.1, false), (0.94, 0.34, 13, 5.0, true),
        (0.24, 0.88, 15, 1.2, false), (0.76, 0.90, 13, 3.8, true),
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(Self.points.enumerated()), id: \.offset) { _, p in
                let tint = p.blueViolet ? TarotCTAPalette.violetGlow : Self.iceBlue
                let pulse = max(0, sin(t * 1.3 + p.phase))
                // A soft floor keeps the constellation gently present
                // between twinkles so the blue layer reads on the busy
                // illustrated background.
                Image(systemName: "sparkle")
                    .font(.system(size: p.size))
                    .foregroundStyle(tint)
                    .opacity((0.30 + 0.60 * pulse * pulse) * fade)
                    .shadow(color: tint.opacity((0.25 + 0.55 * pulse) * fade), radius: 5)
                    .position(x: geo.size.width * p.x,
                              y: geo.size.height * p.y
                                  + CGFloat(sin(t * 0.7 + p.phase)) * 6)
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
    /// True when re-entered from the Result via Back: the reading is
    /// complete, so card faces show directly — no card backs, no
    /// re-flip, no shuffle replay (§ critical back behavior).
    let completedReturn: Bool
    let onFinished: () -> Void

    @EnvironmentObject private var prefs: PrefsStore
    @State private var revealed: [Bool]

    init(cards: [TarotDrawnCard], heading: String,
         initiallyRevealed: Bool = false, onFinished: @escaping () -> Void) {
        self.cards = cards
        self.heading = heading
        self.completedReturn = initiallyRevealed
        self.onFinished = onFinished
        _revealed = State(initialValue: Array(repeating: initiallyRevealed,
                                              count: cards.count))
    }

    private var lang: AppLanguage { prefs.language }
    private var allRevealed: Bool { revealed.allSatisfy { $0 } }

    var body: some View {
        // Weighted spacers (top 2 : bottom 1): the composition sits
        // just below center — never sunk against the bottom edge — and
        // the bounded gap keeps the CTA close to the cards instead of
        // leaving a dead band in the middle of the screen.
        VStack(spacing: TwinkoSpacing.l) {
            Spacer()
            Spacer()

            Text(completedReturn ? TarotStrings.revealCompleted(lang) : heading)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.textInverseToken)

            HStack(spacing: TwinkoSpacing.m) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, drawn in
                    VStack(spacing: 8) {
                        FlipTarotCard(drawn: drawn,
                                      isRevealed: $revealed[index],
                                      width: cards.count == 1 ? 150 : 100,
                                      isFinalRequired:
                                        revealed.filter { $0 }.count == cards.count - 1)
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

            Spacer(minLength: TwinkoSpacing.xl)
                .frame(maxHeight: 96)

            if allRevealed {
                Button {
                    onFinished()
                } label: {
                    Text(completedReturn ? TarotStrings.viewFullReading(lang)
                                         : TarotStrings.seeReading(lang))
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
                    .foregroundStyle(Color.textInverseToken.opacity(0.85))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background {
                        Capsule()
                            .fill(LinearGradient(colors: [Color(hex: 0x9C8CD8).opacity(0.38),
                                                          Color(hex: 0x6E5FB0).opacity(0.30)],
                                                 startPoint: .top, endPoint: .bottom))
                    }
                    .overlay(Capsule().strokeBorder(
                        LinearGradient(stops: [
                            .init(color: Color.white.opacity(0.35), location: 0),
                            .init(color: Color(hex: 0xD1C4FF).opacity(0.16), location: 1),
                        ], startPoint: .top, endPoint: .bottom),
                        lineWidth: 1))
            }
            Spacer(minLength: TwinkoSpacing.l)
        }
        .animation(.easeOut(duration: 0.25), value: revealed)
    }
}
