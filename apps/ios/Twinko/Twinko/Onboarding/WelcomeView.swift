import SwiftUI

/// First-launch welcome (S-001). Twinko is central; "Twinko" is shown
/// only as the temporary prototype working label. Warm, magical,
/// low-pressure — no data is requested here, and the CTA explains that
/// a short setup comes next.
struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            TwinkoBackground.sky.ignoresSafeArea()
            StarFieldView()

            VStack(spacing: TwinkoSpacing.m) {
                Spacer()

                TwinkoCharacterView(mood: .happy, size: 200)
                    .padding(.bottom, TwinkoSpacing.s)

                Text("嗨，我是 Twinko")
                    .font(.twinkoLargeTitle)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 3, y: 1)

                Text("一顆陪你聊聊、想想、\n慢慢沉澱心情的小星星。")
                    .font(.twinkoBody)
                    .foregroundStyle(.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Spacer()

                Button {
                    onContinue()
                } label: {
                    Text("開始認識你")
                }
                .buttonStyle(.twinkoPrimary)
                .accessibilityIdentifier("welcomeContinueButton")

                Text("接下來會請你留下一點小資料，\n只存在這台裝置上的原型裡。")
                    .font(.twinkoCaption)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, TwinkoSpacing.l)
            }
            .padding()
        }
    }
}

#Preview {
    WelcomeView(onContinue: {})
}
