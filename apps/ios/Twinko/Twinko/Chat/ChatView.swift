import SwiftUI

/// TwinkoTalk Chat (chat-visual-primary reference): approved chat_v1
/// dreamy background, neutral warm-ivory reading surfaces, Day/Night
/// Twinko in the empty state and message avatars, gold send action, and
/// an elevated dark quick menu over a dimmed backdrop. Localized
/// English / Traditional Chinese, never both at once.
struct ChatView: View {
    @EnvironmentObject private var chatStore: ChatStore
    @EnvironmentObject private var prefs: PrefsStore
    @EnvironmentObject private var chrome: ShellChrome
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
    // Meditation handoff: the confirmation offer lives on the view
    // model (centralized conversation-level state).
    @State private var goToMeditation = false
    @State private var meditationContext: MeditationSourceContext = .direct

    /// Hides the back chevron when Chat is hosted as the Chat tab's
    /// root (bottom navigation owns the top-level switch).
    let isTabRoot: Bool

    /// Opens a fresh session by default, or continues an existing one
    /// from Chat History.
    init(session: ChatSession = ChatSession(), isTabRoot: Bool = false) {
        self.isTabRoot = isTabRoot
        _viewModel = StateObject(wrappedValue: ChatViewModel(session: session))
    }

    private var lang: AppLanguage { prefs.language }
    private var twinkoAsset: String { ChatDayNight.twinkoAssetName() }
    private var isConversationActive: Bool { !viewModel.messages.isEmpty }

    /// Bottom navigation stays on the Chat landing and hides only
    /// while an active conversation is open (polish 2026-07-17).
    static func hidesTabBar(conversationActive: Bool) -> Bool {
        conversationActive
    }

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
            chrome.tabBarHidden = Self.hidesTabBar(conversationActive: isConversationActive)
        }
        .onChange(of: isConversationActive) { _, active in
            chrome.tabBarHidden = Self.hidesTabBar(conversationActive: active)
        }
        .onDisappear {
            // Landing-level screens (History, other pushes) show the
            // bottom navigation again.
            chrome.tabBarHidden = false
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { isDay = ChatDayNight.isDay() }
        }
        .animation(.easeOut(duration: 0.25), value: viewModel.messages.isEmpty)
    }

    // MARK: Header

    /// No page title and no translucent header block (polish
    /// 2026-07-17) — just Back where meaningful and the star menu.
    private var header: some View {
        HStack {
            if isTabRoot && !isConversationActive {
                Color.clear.frame(width: 44, height: 44)
            } else {
                Button {
                    if isTabRoot {
                        // Leave the active conversation back to the
                        // Chat landing (the conversation stays saved).
                        withAnimation(.easeOut(duration: 0.25)) {
                            viewModel.startNewSession()
                        }
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.deepPlum)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(Text(lang == .english ? "Back" : "返回"))
                .accessibilityIdentifier("chatBackButton")
            }
            Spacer()
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                isInputFocused = false
                withAnimation(.easeOut(duration: 0.2)) { showingQuickMenu.toggle() }
            } label: {
                // Brighter, more magical star (polish 2026-07-17):
                // saturated Twinko gold with a restrained glow.
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.twinkoGold)
                    .shadow(color: Color.twinkoGold.opacity(0.65), radius: 5)
                    .frame(width: 38, height: 38)
                    .background(Color.surfacePrimary.opacity(0.85), in: Circle())
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .accessibilityLabel(Text(lang == .english ? "Chat menu" : "聊天選單"))
            .accessibilityIdentifier("chatMenuButton")
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
                                // Starts the conversation directly with
                                // this prompt as the first user message.
                                viewModel.draftText = starter
                                viewModel.send(lang: lang)
                            } label: {
                                // Suggestion card: translucent lavender
                                // surface, icon chip, chevron — clearly
                                // distinct from the white composer field
                                // (which stays the stronger affordance).
                                HStack(spacing: 10) {
                                    Image(systemName: starterIcon(index))
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color.brandPurpleDeep)
                                        .frame(width: 26, height: 26)
                                        .background(Color.surfacePrimary.opacity(0.9),
                                                    in: Circle())
                                    Text(starter)
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundStyle(Color.deepPlum)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer(minLength: 6)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(Color.brandPurpleDeep.opacity(0.55))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(Color.brandPurple.opacity(0.16),
                                            in: RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(Color.brandPurple.opacity(0.28),
                                                      lineWidth: 1)
                                )
                                .contentShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(TarotSuggestionPressStyle())
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
                    if let offer = viewModel.meditationOffer {
                        meditationOfferCard(offer)
                            .id("meditationOffer")
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 8)
            }
            .onChange(of: viewModel.messages.count) { _, _ in scrollToBottom(proxy) }
            .onChange(of: viewModel.state) { _, _ in scrollToBottom(proxy) }
            .onChange(of: viewModel.meditationOffer) { _, offer in
                if offer != nil { scrollToBottom(proxy) }
            }
            .onAppear { scrollToBottom(proxy) }
            .defaultScrollAnchor(.bottom)
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
        let target: AnyHashable?
        if viewModel.meditationOffer != nil {
            target = AnyHashable("meditationOffer")
        } else if viewModel.state == .loading {
            target = AnyHashable("typing")
        } else {
            target = viewModel.messages.last.map { AnyHashable($0.id) }
        }
        guard let target else { return }
        withAnimation { proxy.scrollTo(target, anchor: .bottom) }
    }

    // MARK: Meditation confirmation card

    /// Contextual confirmation card shown after the related Twinko
    /// message — one shared component for explicit requests and
    /// proactive suggestions (only trigger source differs).
    private func meditationOfferCard(_ offer: ChatMeditationOffer) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.brandPurpleDeep)
                Text(ChatStrings.meditationConfirm(lang))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.deepPlum)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button {
                meditationContext = viewModel.acceptMeditationOffer(lang: lang)
                goToMeditation = true
            } label: {
                Text(ChatStrings.meditationConfirmAccept(lang))
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.textInverseToken)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(
                        LinearGradient(colors: [.brandPurple, .brandPurpleDeep],
                                       startPoint: .top, endPoint: .bottom),
                        in: RoundedRectangle(cornerRadius: 22))
            }
            .accessibilityIdentifier("chatMeditationAccept")
            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    viewModel.declineMeditationOffer()
                }
            } label: {
                Text(ChatStrings.meditationConfirmDecline(lang))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.textSecondaryToken)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .accessibilityIdentifier("chatMeditationDecline")
        }
        .padding(TwinkoSpacing.m)
        .background(Color.surfacePrimary.opacity(0.96),
                    in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20)
            .strokeBorder(Color.borderSoft, lineWidth: 1))
        .padding(.leading, 38)
        .padding(.trailing, 12)
        .transition(.opacity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("chatMeditationOfferCard")
    }

    // MARK: Composer    // MARK: Composer

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
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                viewModel.send(lang: lang)
            } label: {
                // Premium purple send action (polish 2026-07-17): a
                // calm violet gradient with restrained glow; disabled
                // stays visible and intentional.
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.textInverseToken.opacity(canSend ? 1 : 0.75))
                    .frame(width: 44, height: 44)
                    .background(
                        canSend
                            ? AnyShapeStyle(LinearGradient(
                                colors: [.brandPurple, .brandPurpleDeep],
                                startPoint: .top, endPoint: .bottom))
                            : AnyShapeStyle(Color.brandPurple.opacity(0.30)),
                        in: Circle())
                    .shadow(color: canSend ? Color.brandPurpleDeep.opacity(0.35) : .clear,
                            radius: 6, y: 2)
            }
            .buttonStyle(PurplePressStyle(enabled: canSend))
            .disabled(!canSend)
            // Centers the 44pt button against the 52pt single-line
            // field; for expanded input it stays bottom-aligned with
            // the same consistent inset.
            .padding(.bottom, 4)
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

/// Purple send-button press treatment (polish 2026-07-17).
private struct PurplePressStyle: ButtonStyle {
    let enabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Circle()
                    .fill(configuration.isPressed && enabled
                          ? Color.brandPurpleDeep.opacity(0.45) : Color.clear)
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
            .environmentObject(ShellChrome())
    }
}
