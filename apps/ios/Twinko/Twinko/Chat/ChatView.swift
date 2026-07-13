import SwiftUI

/// The Mock Chat screen: empty state, local input, deterministic
/// loading/success/fallback states, in-memory-only messages. Visual
/// direction: warm night room (Brand Guide §6 Chat).
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
        .background {
            ZStack {
                TwinkoBackground.night.ignoresSafeArea()
                StarFieldView(tint: .twinkoGold.opacity(0.7))
            }
        }
        .navigationTitle("Twinko")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.midnightNavy.opacity(0.6), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
        VStack(spacing: TwinkoSpacing.s) {
            TwinkoCharacterView(mood: .listening, size: 96)
                .padding(.bottom, TwinkoSpacing.s)
            Text("Say hello to Twinko")
                .font(.twinkoHeadline)
                .foregroundStyle(.white)
            Text("This is a quiet place to talk. Type anything below to start.")
                .font(.twinkoBody)
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
            Text("Tip: type \"error test\" to see how Twinko responds when it isn't sure.")
                .font(.twinkoCaption)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
        .accessibilityIdentifier("chatEmptyState")
    }

    private var loadingBubble: some View {
        HStack {
            HStack(spacing: TwinkoSpacing.s) {
                TwinkoCharacterView(mood: .thinking, size: 30)
                ThinkingDotsView(tint: .softWhite)
            }
            .padding(12)
            .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: TwinkoRadius.bubble))
            Spacer()
        }
        .accessibilityIdentifier("chatLoadingState")
    }

    private var composer: some View {
        HStack(spacing: TwinkoSpacing.s) {
            TextField("Type a message...", text: $viewModel.draftText, axis: .vertical)
                .font(.twinkoBody)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.14), in: RoundedRectangle(cornerRadius: TwinkoRadius.bubble))
                .foregroundStyle(.white)
                .tint(.twinkoGold)
                .focused($isInputFocused)
                .lineLimit(1...4)
                .onSubmit { viewModel.send() }
                .accessibilityIdentifier("chatInputField")

            Button {
                viewModel.send()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(colors: [.twinkoGold, .warmOrange],
                                       startPoint: .top, endPoint: .bottom)
                    )
            }
            .disabled(viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityLabel(Text("送出"))
            .accessibilityIdentifier("chatSendButton")
        }
        .padding()
        .background(Color.midnightNavy.opacity(0.85))
    }
}

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.sender == .user { Spacer(minLength: 40) }

            Text(message.text)
                .font(.twinkoBody)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(bubbleBackground, in: RoundedRectangle(cornerRadius: TwinkoRadius.bubble))
                .foregroundStyle(message.sender == .user ? Color.inkNavy : .white)

            if message.sender == .twinko { Spacer(minLength: 40) }
        }
    }

    private var bubbleBackground: some ShapeStyle {
        if message.sender == .user {
            return AnyShapeStyle(
                LinearGradient(colors: [.twinkoGold, Color(red: 1.0, green: 0.72, blue: 0.35)],
                               startPoint: .top, endPoint: .bottom)
            )
        }
        return AnyShapeStyle(Color.white.opacity(0.14))
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
