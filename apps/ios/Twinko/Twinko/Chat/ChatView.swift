import SwiftUI

/// The P0 Mock Chat screen: empty state, local input, deterministic
/// loading/success/fallback states, in-memory-only messages. See
/// docs/prototype/TWINKO_P0_APP_SHELL_MOCK_CHAT_SPEC.md §2.2–§3.
struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool

    init(viewModel: ChatViewModel = ChatViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            messageList
            composer
        }
        .background(Color(red: 0.99, green: 0.94, blue: 0.86).ignoresSafeArea())
        .navigationTitle("Twinko")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if viewModel.messages.isEmpty {
                        emptyState
                    }
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    if viewModel.state == .loading {
                        loadingBubble
                            .id("loading")
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.state) { _, _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        let target: AnyHashable? = viewModel.state == .loading
            ? "loading"
            : viewModel.messages.last?.id
        guard let target else { return }
        withAnimation {
            proxy.scrollTo(target, anchor: .bottom)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            TwinkoCharacterView(size: 72)
            Text("Say hello to Twinko")
                .font(.headline)
            Text("This is a quiet place to talk. Type anything below to start.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text("Tip: type \"error test\" to see how Twinko responds when it isn't sure.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
        .accessibilityIdentifier("chatEmptyState")
    }

    private var loadingBubble: some View {
        HStack {
            HStack(spacing: 8) {
                TwinkoCharacterView(size: 24)
                ProgressView()
            }
            .padding(10)
            .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 14))
            Spacer()
        }
        .accessibilityIdentifier("chatLoadingState")
    }

    private var composer: some View {
        HStack(spacing: 8) {
            TextField("Type a message...", text: $viewModel.draftText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .focused($isInputFocused)
                .lineLimit(1...4)
                .onSubmit { viewModel.send() }
                .accessibilityIdentifier("chatInputField")

            Button {
                viewModel.send()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
            }
            .disabled(viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityIdentifier("chatSendButton")
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.sender == .user { Spacer(minLength: 40) }

            Text(message.text)
                .padding(10)
                .background(bubbleColor, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(message.sender == .user ? .white : .primary)

            if message.sender == .twinko { Spacer(minLength: 40) }
        }
    }

    private var bubbleColor: Color {
        message.sender == .user ? Color.accentColor : Color.white.opacity(0.85)
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
