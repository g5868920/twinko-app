import SwiftUI

/// TwinkoTalk Chat (chat-visual-primary reference): approved chat_v1
/// dreamy background, neutral warm-ivory reading surfaces, Day/Night
/// Twinko in the empty state and message avatars, gold send action, and
/// an elevated dark quick menu over a dimmed backdrop. Localized
/// English / Traditional Chinese, never both at once.
struct ChatView: View {
    @EnvironmentObject private var chatStore: ChatStore
    @EnvironmentObject private var prefs: PrefsStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    @State private var isDay = ChatDayNight.isDay()
    @State private var showingQuickMenu = false
    @State private var showingDraftDiscard = false
    @State private var goToHistory = false
    @State private var floating = false
    // Meditation handoff: one offer per conversation; declining hides
    // it for that session only. No emotion detection — the offer
    // appears once a Twinko reply exists.
    @State private var goToMeditation = false
    @State private var meditationDeclinedSessionID: UUID?

    /// Opens a fresh session by default, or continues an existing one
    /// from Chat History.
    init(session: ChatSession = ChatSession()) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(session: session))
    }

    private var lang: AppLanguage { prefs.language }
    private var twinkoAsset: String { ChatDayNight.twinkoAssetName() }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                if viewModel.messages.isEmpty && viewModel.state != .loading {
                    emptyState
                        .transition(.opacity)
                } else {
                    messageList
                        .transition(.opacity)
                }
                if showsMeditationOffer {
                    meditationOffer
                }
                composer
            }

            if showingQuickMenu {
                quickMenu
            }
        }
        .background {
            // Approved chat_v1.png — full-screen aspect fill behind the
            // safe areas, no recoloring or overlays.
            GeometryReader { geo in
                Image("chat_v1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .accessibilityHidden(true)
            }
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goToHistory) {
            ChatHistoryView()
        }
        .navigationDestination(isPresented: $goToMeditation) {
            MeditationFlowView(sourceContext: meditationContext)
        }
        .confirmationDialog(
            ChatStrings.discardDraftTitle(lang),
            isPresented: $showingDraftDiscard,
            titleVisibility: .visible
        ) {
            Button(ChatStrings.discardDraft(lang), role: .destructive) {
                withAnimation(.easeOut(duration: 0.25)) {
                    viewModel.startNewSession()
                }
            }
            Button(ChatStrings.keepWriting(lang), role: .cancel) {}
        }
        .onAppear {
            isDay = ChatDayNight.isDay()
            viewModel.store = chatStore
            // If this conversation was deleted from History while open,
            // fall back to a fresh empty chat instead of resurrecting it.
            if !viewModel.messages.isEmpty && !chatStore.contains(viewModel.sessionID) {
                viewModel.startNewSession()
            }
            startIdle()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { isDay = ChatDayNight.isDay() }
        }
        .animation(.easeOut(duration: 0.25), value: viewModel.messages.isEmpty)
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            Text(ChatStrings.title(lang))
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.deepPlum)
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.deepPlum)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(Text(lang == .english ? "Back" : "返回"))
                .accessibilityIdentifier("chatBackButton")
                Spacer()
                Button {
                    isInputFocused = false
                    withAnimation(.easeOut(duration: 0.2)) { showingQuickMenu = true }
                } label: {
                    Image(systemName: "star.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.accentGold)
                        .frame(width: 38, height: 38)
                        .background(Color.surfacePrimary.opacity(0.72), in: Circle())
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                .accessibilityLabel(Text(lang == .english ? "Chat menu" : "聊天選單"))
                .accessibilityIdentifier("chatMenuButton")
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 48)
    }

    // MARK: Empty state

    private var emptyState: some View {
        GeometryReader { geo in
            let compact = geo.size.width < 380
            let twinkoWidth: CGFloat = compact ? 132 : 156
            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: geo.size.height * 0.04)

                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.97, blue: 0.88))
                            .frame(width: twinkoWidth * 1.1, height: twinkoWidth * 1.1)
                            .blur(radius: 22)
                            .opacity(0.22)
                        Image(twinkoAsset)
                            .resizable()
                            .scaledToFit()
                            .frame(width: twinkoWidth, height: twinkoWidth)
                            .offset(y: reduceMotion ? 0 : (floating ? -5 : 5))
                            .accessibilityLabel(Text("Twinko"))
                    }

                    VStack(spacing: 6) {
                        Text(ChatStrings.introLine1(lang))
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .foregroundStyle(Color.deepPlum)
                        Text(ChatStrings.introLine2(lang))
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color.textSecondaryToken)
                    }
                    .multilineTextAlignment(.center)

                    VStack(spacing: 10) {
                        ForEach(Array(ChatStrings.starters(lang).enumerated()), id: \.offset) { index, starter in
                            Button {
                                viewModel.draftText = starter
                                isInputFocused = true
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: starterIcon(index))
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(Color.linkPurple)
                                    Text(starter)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(Color.deepPlum)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .frame(minHeight: 48)
                                .background(Color.surfacePrimary.opacity(0.94),
                                            in: RoundedRectangle(cornerRadius: 22))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .strokeBorder(Color.borderSoft, lineWidth: 1)
                                )
                            }
                            .accessibilityIdentifier("chatStarter-\(index)")
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 16)
                }
                .frame(minHeight: geo.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private func starterIcon(_ index: Int) -> String {
        ["bubble.left", "heart", "star"][index % 3]
    }

    // MARK: Message list

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                        messageRow(message, showsAvatar: showsAvatar(at: index))
                            .id(message.id)
                    }
                    if viewModel.state == .loading {
                        typingRow
                            .id("typing")
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .onChange(of: viewModel.messages.count) { _, _ in scrollToBottom(proxy) }
            .onChange(of: viewModel.state) { _, _ in scrollToBottom(proxy) }
            .onAppear { scrollToBottom(proxy) }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private func showsAvatar(at index: Int) -> Bool {
        let messages = viewModel.messages
        guard messages[index].sender == .twinko else { return false }
        return index == 0 || messages[index - 1].sender != .twinko
    }

    @ViewBuilder
    private func messageRow(_ message: ChatMessage, showsAvatar: Bool) -> some View {
        if message.sender == .twinko {
            HStack(alignment: .top, spacing: 8) {
                if showsAvatar {
                    TwinkoChatAvatar(assetName: twinkoAsset)
                } else {
                    Color.clear.frame(width: 38, height: 1)
                }
                twinkoBubble { Text(message.text) }
                Spacer(minLength: 50)
            }
        } else {
            HStack {
                Spacer(minLength: 70)
                Text(message.text)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.textInverseToken)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(colors: [.userBubbleTop, .userBubbleSolid],
                                       startPoint: .top, endPoint: .bottom),
                        in: RoundedRectangle(cornerRadius: 22)
                    )
                    .shadow(color: Color(red: 0.06, green: 0.07, blue: 0.15).opacity(0.08),
                            radius: 8, y: 2)
            }
        }
    }

    private func twinkoBubble<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .font(.system(.body, design: .rounded))
            .foregroundStyle(Color.textPrimaryToken)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.twinkoBubble, in: RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(Color.twinkoBubbleBorder, lineWidth: 1)
            )
            .shadow(color: Color(red: 0.06, green: 0.07, blue: 0.15).opacity(0.08),
                    radius: 8, y: 2)
    }

    private var typingRow: some View {
        HStack(alignment: .top, spacing: 8) {
            if viewModel.messages.last?.sender != .twinko {
                TwinkoChatAvatar(assetName: twinkoAsset)
            } else {
                Color.clear.frame(width: 38, height: 1)
            }
            twinkoBubble { ThinkingDotsView(tint: .textSecondaryToken) }
            Spacer()
        }
        .accessibilityIdentifier("chatLoadingState")
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        let target: AnyHashable? = viewModel.state == .loading
            ? "typing" : viewModel.messages.last?.id
        guard let target else { return }
        withAnimation { proxy.scrollTo(target, anchor: .bottom) }
    }

    // MARK: Meditation handoff

    /// Shown once a Twinko reply exists, at most once per conversation
    /// (declining hides it for that session). No content analysis.
    private var showsMeditationOffer: Bool {
        viewModel.messages.last?.sender == .twinko
            && viewModel.state != .loading
            && meditationDeclinedSessionID != viewModel.sessionID
            && !showingQuickMenu
    }

    /// Small locally derived summary: the most recent user message,
    /// truncated — never the whole transcript.
    private var meditationContext: MeditationSourceContext {
        let lastUserText = viewModel.messages.last(where: { $0.sender == .user })?.text ?? ""
        let summary = String(lastUserText.prefix(50))
        return MeditationSourceContext(sourceType: .chat,
                                       recentChatSummary: summary.isEmpty ? nil : summary,
                                       tarotQuestion: nil, tarotSummary: nil,
                                       emotionalTone: nil)
    }

    private var meditationOffer: some View {
        HStack(spacing: 10) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.brandPurpleDeep)
            Text(MeditationStrings.chatOffer(lang))
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Color.deepPlum)
                .lineLimit(2)
            Spacer(minLength: 4)
            Button {
                goToMeditation = true
            } label: {
                Text(MeditationStrings.chatOfferAccept(lang))
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.textInverseToken)
                    .padding(.horizontal, 12)
                    .frame(minHeight: 32)
                    .background(
                        LinearGradient(colors: [.brandPurple, .brandPurpleDeep],
                                       startPoint: .top, endPoint: .bottom),
                        in: Capsule())
                    .frame(minHeight: 44)
                    .contentShape(Capsule())
            }
            .accessibilityIdentifier("chatMeditationAccept")
            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    meditationDeclinedSessionID = viewModel.sessionID
                }
            } label: {
                Text(MeditationStrings.chatOfferDecline(lang))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.textSecondaryToken)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityIdentifier("chatMeditationDecline")
        }
        .padding(.leading, 14)
        .padding(.trailing, 4)
        .background(Color.surfacePrimary.opacity(0.94),
                    in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18)
            .strokeBorder(Color.borderSoft, lineWidth: 1))
        .padding(.horizontal, 12)
        .padding(.top, 4)
        .transition(.opacity)
        .accessibilityElement(children: .contain)
    }

    // MARK: Composer

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField(
                "", text: $viewModel.draftText,
                prompt: Text(ChatStrings.composerPlaceholder(lang))
                    .foregroundStyle(Color.textMutedToken),
                axis: .vertical
            )
            .font(.system(.body, design: .rounded))
            .foregroundStyle(Color.textPrimaryToken)
            .tint(.linkPurple)
            .lineLimit(1...5) // caps growth ≈140 pt
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .frame(minHeight: 52)
            .background(Color.surfaceInput, in: RoundedRectangle(cornerRadius: 26))
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .strokeBorder(Color.borderSoft, lineWidth: 1)
            )
            .focused($isInputFocused)
            .accessibilityIdentifier("chatInputField")

            Button {
                viewModel.send()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.textInverseToken)
                    .frame(width: 44, height: 44)
                    .background(canSend ? Color.sendEnabled : Color.sendDisabled.opacity(0.6),
                                in: Circle())
                    .shadow(color: canSend
                            ? Color(red: 0.06, green: 0.07, blue: 0.15).opacity(0.08) : .clear,
                            radius: 4, y: 2)
            }
            .buttonStyle(GoldPressStyle(enabled: canSend))
            .disabled(!canSend)
            .accessibilityLabel(Text(lang == .english ? "Send" : "送出"))
            .accessibilityIdentifier("chatSendButton")
        }
        .padding(.horizontal, 12)
        .padding(.top, 6)
        .padding(.bottom, 8)
    }

    private var canSend: Bool {
        !viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: Quick menu

    private var quickMenu: some View {
        ZStack(alignment: .top) {
            // Dark translucent scrim de-emphasizing the chat beneath.
            Color.deepSpace.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { closeQuickMenu() }
                .accessibilityLabel(Text(lang == .english ? "Close menu" : "關閉選單"))

            VStack(spacing: 16) {
                VStack(spacing: 0) {
                    quickMenuRow(icon: "plus.circle", iconColor: .accentGold,
                                 label: ChatStrings.newChat(lang),
                                 identifier: "menuNewChatRow") {
                        closeQuickMenu()
                        if !viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            showingDraftDiscard = true
                        } else {
                            withAnimation(.easeOut(duration: 0.25)) {
                                viewModel.startNewSession()
                            }
                        }
                    }
                    Divider()
                        .overlay(Color.textInverseToken.opacity(0.15))
                        .padding(.horizontal, 12)
                    quickMenuRow(icon: "bubble.left", iconColor: Color(hex: 0xCBBDF0),
                                 label: ChatStrings.history(lang),
                                 identifier: "menuHistoryRow") {
                        closeQuickMenu()
                        goToHistory = true
                    }
                }
                .frame(width: 196)
                .background(Color.menuDeep, in: RoundedRectangle(cornerRadius: 22))
                .shadow(color: Color(red: 0.06, green: 0.07, blue: 0.15).opacity(0.16),
                        radius: 32, y: 12)

                Button {
                    closeQuickMenu()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.textInverseToken)
                        .frame(width: 40, height: 40)
                        .background(Color.menuDeep.opacity(0.9), in: Circle())
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                .accessibilityLabel(Text(lang == .english ? "Close" : "關閉"))
                .accessibilityIdentifier("menuCloseButton")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 16)
            .padding(.top, 52)
        }
        .transition(.opacity)
    }

    private func quickMenuRow(icon: String, iconColor: Color, label: String,
                              identifier: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(iconColor)
                    .frame(width: 24)
                Text(label)
                    .font(.system(.body, design: .rounded).weight(.medium))
                    .foregroundStyle(Color.textInverseToken)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .contentShape(Rectangle())
        }
        .accessibilityIdentifier(identifier)
    }

    private func closeQuickMenu() {
        withAnimation(.easeOut(duration: 0.2)) { showingQuickMenu = false }
    }

    private func startIdle() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            floating = true
        }
    }
}

/// Gold send-button press treatment (DESIGN.md §26 Composer States).
private struct GoldPressStyle: ButtonStyle {
    let enabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Circle()
                    .fill(configuration.isPressed && enabled
                          ? Color.sendPressed : Color.clear)
            )
            .scaleEffect(configuration.isPressed && enabled ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        ChatView()
            .environmentObject(ChatStore())
            .environmentObject(PrefsStore())
    }
}
