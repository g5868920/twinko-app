import SwiftUI

/// Interim shell: the Twinko character, the temporary working label
/// "Twinko," and a single path into Chat. Replaced by the app router +
/// Home Menu in the onboarding phase of the D-054 milestone.
struct RootShellView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                TwinkoBackground.sky.ignoresSafeArea()
                StarFieldView()

                VStack(spacing: TwinkoSpacing.m) {
                    Spacer()

                    TwinkoCharacterView(mood: .happy, size: 210)

                    Text("Twinko")
                        .font(.twinkoLargeTitle)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 3, y: 1)

                    Text("A quiet place to talk.")
                        .font(.twinkoBody)
                        .foregroundStyle(.white.opacity(0.9))

                    Spacer()

                    NavigationLink {
                        ChatView()
                    } label: {
                        Text("Chat with Twinko")
                    }
                    .buttonStyle(.twinkoPrimary)
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
