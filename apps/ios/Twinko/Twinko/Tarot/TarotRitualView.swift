import SwiftUI

/// Shuffle ritual + face-down reveal. The shuffle is a short, gentle
/// animation that always ends on its own (loading must never trap the
/// user); Reduce Motion skips straight to the face-down cards.
struct TarotRitualStage: View {
    let draw: TarotDraw
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shuffling = true
    @State private var revealed: [Bool]
    @State private var wobble = false

    init(draw: TarotDraw, onFinished: @escaping () -> Void) {
        self.draw = draw
        self.onFinished = onFinished
        _revealed = State(initialValue: Array(repeating: false, count: draw.cards.count))
    }

    private var allRevealed: Bool { revealed.allSatisfy { $0 } }

    var body: some View {
        VStack(spacing: TwinkoSpacing.l) {
            Spacer()

            if shuffling {
                shuffleView
            } else {
                revealView
            }

            Spacer()

            if !shuffling {
                if allRevealed {
                    Button {
                        onFinished()
                    } label: {
                        Text("看看牌想說什麼")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.twinkoPrimary)
                    .padding(.horizontal, TwinkoSpacing.l)
                } else {
                    Text("輕點牌面，把牌翻開")
                        .font(.twinkoBody)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            Spacer(minLength: TwinkoSpacing.xl)
        }
        .onAppear { startShuffle() }
    }

    private var shuffleView: some View {
        VStack(spacing: TwinkoSpacing.l) {
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    TarotCardBack(width: 110)
                        .rotationEffect(.degrees(wobble ? Double(index - 1) * 10 : Double(1 - index) * 10))
                        .offset(x: wobble ? CGFloat(index - 1) * 24 : CGFloat(1 - index) * 24)
                }
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.55).repeatCount(3, autoreverses: true),
                       value: wobble)
            Text("正在為你洗牌⋯⋯")
                .font(.twinkoBody)
                .foregroundStyle(.white.opacity(0.85))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("正在洗牌"))
    }

    private var revealView: some View {
        VStack(spacing: TwinkoSpacing.m) {
            Text(draw.spread == .single ? "這是今天陪你的牌" : "由左到右：情境・洞察・建議")
                .font(.twinkoHeadline)
                .foregroundStyle(.white)
            HStack(spacing: TwinkoSpacing.m) {
                ForEach(Array(draw.cards.enumerated()), id: \.element.id) { index, card in
                    FlipTarotCard(card: card,
                                  isRevealed: $revealed[index],
                                  width: draw.spread == .single ? 150 : 100)
                }
            }
        }
    }

    private func startShuffle() {
        if reduceMotion {
            shuffling = false
            return
        }
        wobble = true
        Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            withAnimation(.easeInOut(duration: TwinkoMotion.standard)) {
                shuffling = false
            }
        }
    }
}
