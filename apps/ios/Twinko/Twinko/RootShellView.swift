import SwiftUI

/// The minimal P0 shell: the Twinko character, the temporary working
/// label "Twinko," and a single path into Chat. See
/// docs/prototype/TWINKO_P0_APP_SHELL_MOCK_CHAT_SPEC.md §2.1 — no other
/// screen, mode, or menu belongs here.
struct RootShellView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.55, green: 0.42, blue: 0.75),
                        Color(red: 0.95, green: 0.7, blue: 0.5)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()

                    TwinkoCharacterView(size: 200)

                    Text("Twinko")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("A quiet place to talk.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))

                    Spacer()

                    NavigationLink {
                        ChatView()
                    } label: {
                        Text("Chat with Twinko")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 32)
                            .background(Color.black.opacity(0.25), in: Capsule())
                    }
                    .padding(.bottom, 48)
                    .accessibilityIdentifier("chatEntryButton")
                }
                .padding()
            }
        }
    }
}

#Preview {
    RootShellView()
}
