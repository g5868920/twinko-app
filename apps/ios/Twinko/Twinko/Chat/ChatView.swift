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

    /// Immersive Chat (refinement 2026-07-17): the shared dock hides
    /// whenever any Chat surface — landing or active conversation — is
    /// frontmost, and returns when the user leaves (Back to Home /
    /// Chat History push / another tab). Uses the existing shared
    /// chrome flag; no second visibility state.
    static func hidesTabBar(chatSurfaceVisible: Bool) -> Bool {
        chatSurfaceVisible
    }

    /// Whether this instance is currently the frontmost Chat surface:
    /// pushed instances are visible by definition while on screen; the
    /// tab-root instance stays alive across tab switches, so it is
    /// visible only while the Chat tab is selected.
    private var isFrontmostChatSurface: Bool {
        isTabRoot ? chrome.selectedTab == .chat : true
    }

    private func reportChromeAndMotion() {
        chrome.setChatConversationActive(
            Self.hidesTabBar(chatSurfaceVisible: isFrontmostChatSurface))
        updateFloating(active: isFrontmostChatSurface)
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
        .dockClearance()
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
            reportChromeAndMotion()
        }
        .onChange(of: chrome.selectedTab) { _, _ in
            // The tab-root instance stays alive (opacity-switched), so
            // tab changes re-report visibility and pause the float
            // off-tab; pushed instances are unaffected.
            if isTabRoot { reportChromeAndMotion() }
        }
        .onDisappear {
            // Leaving this chat surface (pop to History, push into an
            // immersive child) clears the flag; immersive children keep
            // the bar hidden through their own tokens, and re-appearing
            // re-reports the state above.
            chrome.setChatConversationActive(false)
            updateFloating(active: false)
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
            // Back is always present (immersive landing, 2026-07-17):
            // pushed instances pop the existing stack; the tab-root
            // conversation returns to the landing; the tab-root landing
            // returns to Home — the existing route ownership in every
            // case, no new tracker.
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                if !isTabRoot {
                    dismiss()
                } else if isConversationActive {
                    // Leave the active conversation back to the Chat
                    // landing (the conversation stays saved).
                    withAnimation(.easeOut(duration: 0.25)) {
                        viewModel.startNewSession()
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.25)) {
                        chrome.selectedTab = .home
                    }
                }
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.deepPlum)
                    .frame(width: 38, height: 38)
                    .background(
                        Circle().fill(
                            LinearGradient(colors: [Color.white.opacity(0.55),
                                                    Color(hex: 0xC9B8EE).opacity(0.45)],
                                           startPoint: .top, endPoint: .bottom))
                    )
                    .overlay(Circle().strokeBorder(Color(hex: 0xB9A8E8).opacity(0.6),
                                                   lineWidth: 1))
                    .shadow(color: Color.brandPurpleDeep.opacity(0.18), radius: 3, y: 1)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(ChatControlPressStyle())
            .accessibilityLabel(Text(lang == .english ? "Back" : "返回"))
            .accessibilityIdentifier("chatBackButton")
            Spacer()
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                isInputFocused = false
                withAnimation(.easeOut(duration: 0.2)) { showingQuickMenu.toggle() }
            } label: {
                // Clearly interactive star orb (refinement 2026-07-17):
                // saturated lavender-purple glass with a top highlight,
                // holding a brighter dimensional gold star — reads as a
                // control, never background decoration. Balanced with
                // the Back orb.
                Image(systemName: "star.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(
                        LinearGradient(colors: [Color(hex: 0xFFEDB0), .twinkoGoldDeep],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing))
                    .shadow(color: Color.twinkoGoldDeep.opacity(0.85), radius: 3, y: 1)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 6, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.95))
                            .offset(x: 3, y: -2)
                    }
                    .frame(width: 38, height: 38)
                    .background(
                        Circle().fill(
                            LinearGradient(colors: [Color(hex: 0xC9B8EE).opacity(0.9),
                                                    Color(hex: 0x9A85DE).opacity(0.8)],
                                           startPoint: .top, endPoint: .bottom))
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(stops: [
                                    .init(color: .white.opacity(0.85), location: 0),
                                    .init(color: Color(hex: 0x8E7AE6).opacity(0.6),
                                          location: 0.7),
                                ], startPoint: .top, endPoint: .bottom),
                                lineWidth: 1)
                    )
                    .shadow(color: Color.brandPurpleDeep.opacity(0.3), radius: 4, y: 2)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(ChatControlPressStyle())
            .accessibilityLabel(Text(lang == .english ? "Chat menu" : "聊天選單"))
            .accessibilityIdentifier("chatMenuButton")
        }
        .padding(.horizontal, 8)
        .frame(height: 48)
    }

    // MARK: Empty state

    /// One-scene landing (refinement 2026-07-17): no normal vertical
    /// scrolling — `ViewThatFits` measures the fixed hero content and
    /// falls back to a controlled scroll only for very small screens,
    /// Accessibility Dynamic Type, or the open keyboard. Flexible
    /// spacers in the standard branch balance the scene between the
    /// floating header and the composer.
    private var emptyState: some View {
        ViewThatFits(in: .vertical) {
            VStack(spacing: 20) {
                Spacer(minLength: 8)
                landingHero
                Spacer(minLength: 8)
            }
            ScrollView {
                VStack(spacing: 20) {
                    landingHero
                }
                .padding(.vertical, 8)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var landingHero: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.97, blue: 0.88))
                    .frame(width: 170, height: 170)
                    .blur(radius: 22)
                    .opacity(0.22)
                Image(twinkoAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 156, height: 156)
                    .offset(y: reduceMotion ? 0 : (floating ? -3.5 : 3.5))
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

            VStack(spacing: 12) {
                ForEach(Array(ChatStrings.starters(lang).enumerated()), id: \.offset) { index, starter in
                    promptCard(starter, index: index)
                }
            }
            .padding(.horizontal, 30)
        }
    }

    /// One coherent family of soft glass prompt cards: icon orb, prompt
    /// text, chevron — warm translucent glass with a very subtle
    /// per-card emotional tint. Height adapts to wrapped text.
    private func promptCard(_ starter: String, index: Int) -> some View {
        let tint = starterTint(index)
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            // Starts the conversation directly with this prompt as the
            // first user message (existing behavior).
            viewModel.draftText = starter
            viewModel.send(lang: lang)
        } label: {
            HStack(spacing: 12) {
                // Lavender glass icon orb — one cohesive family, never
                // a bright solid-white circle.
                Image(systemName: starterIcon(index))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.brandPurpleDeep)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(Color(hex: 0xD9CFF2).opacity(0.75))
                            .overlay(
                                Circle()
                                    .fill(LinearGradient(stops: [
                                        .init(color: .white.opacity(0.55), location: 0),
                                        .init(color: .white.opacity(0), location: 0.55),
                                    ], startPoint: .top, endPoint: .bottom))
                                    .padding(1)
                            )
                    )
                    .overlay(Circle().strokeBorder(tint.opacity(0.6), lineWidth: 1))
                    .shadow(color: Color.brandPurpleDeep.opacity(0.15), radius: 2, y: 1)
                Text(starter)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.deepPlum)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 6)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.brandPurpleDeep.opacity(0.9))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                // Distinctly darker lavender glass over the pink
                // background — Twinko's suggested ways to begin, never
                // settings rows.
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(hex: 0xB9A8E8).opacity(0.38))
                    .overlay(RoundedRectangle(cornerRadius: 18)
                        .fill(tint.opacity(0.16)))
            )
            .overlay(
                // Soft top catch-light + tinted border: glass, not a
                // flat outlined form row.
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(
                        LinearGradient(stops: [
                            .init(color: .white.opacity(0.75), location: 0),
                            .init(color: Color(hex: 0x9A85DE).opacity(0.55), location: 0.6),
                        ], startPoint: .top, endPoint: .bottom),
                        lineWidth: 1)
            )
            .shadow(color: Color.brandPurpleDeep.opacity(0.16), radius: 6, y: 3)
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(ChatPromptPressStyle())
        .accessibilityIdentifier("chatStarter-\(index)")
    }

    private func starterIcon(_ index: Int) -> String {
        ["bubble.left", "heart", "star"][index % 3]
    }

    /// Very subtle emotional tints — one family, three moods:
    /// today = blue-lilac, pressure = lavender, company = warm lilac.
    private func starterTint(_ index: Int) -> Color {
        [Color(hex: 0x8FA0E8), Color(hex: 0xA88BFE), Color(hex: 0xD9A0C0)][index % 3]
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
                // Premium purple send action (refinement 2026-07-17):
                // saturated lavender→brand-purple fill, soft top
                // catch-light, and a restrained warm inner border.
                // Disabled reads quieter but still clearly the send
                // control; validity comes from the existing draft rule.
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(canSend ? Color.textInverseToken
                                             : Color(hex: 0xF3EDFF).opacity(0.9))
                    .frame(width: 44, height: 44)
                    .background(
                        canSend
                            ? AnyShapeStyle(LinearGradient(
                                colors: [.brandPurple, Color(hex: 0x6A53C4)],
                                startPoint: .top, endPoint: .bottom))
                            : AnyShapeStyle(Color.brandPurple.opacity(0.55)),
                        in: Circle())
                    .overlay(
                        // Dimensional highlight along the upper edge.
                        Circle()
                            .fill(LinearGradient(stops: [
                                .init(color: .white.opacity(canSend ? 0.30 : 0.10), location: 0),
                                .init(color: .white.opacity(0), location: 0.45),
                            ], startPoint: .top, endPoint: .bottom))
                            .padding(2)
                            .allowsHitTesting(false)
                    )
                    .overlay(Circle().strokeBorder(
                        canSend ? Color(hex: 0xFFF3D6).opacity(0.55)
                                : Color.white.opacity(0.4),
                        lineWidth: 1))
                    .shadow(color: canSend ? Color.brandPurpleDeep.opacity(0.40) : .clear,
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

    /// Gentle landing float: ~7 pt vertical travel over a ~3.2 s
    /// ease-in-out cycle. Reduce Motion keeps Twinko static; the float
    /// pauses whenever this surface is not frontmost (off-tab or
    /// covered) — one animation, no timers.
    private func updateFloating(active: Bool) {
        if active && !reduceMotion {
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                floating = true
            }
        } else {
            withAnimation(.linear(duration: 0.05)) { floating = false }
        }
    }
}

/// Purple send-button press treatment: slight scale, soft halo, and a
/// brief restrained sparkle shimmer (Reduce Motion: scale only).
private struct PurplePressStyle: ButtonStyle {
    let enabled: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && enabled
        configuration.label
            .background(
                Circle()
                    .fill(pressed ? Color.brandPurpleDeep.opacity(0.45) : Color.clear)
            )
            .overlay {
                if pressed && !reduceMotion {
                    TarotPressSparkles()
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .scaleEffect(pressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

/// Quiet pressed feedback for Chat's floating controls (Back, star
/// orb): subtle scale + brightness lift, no heavy background.
private struct ChatControlPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? 0.06 : 0)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Prompt-card press: surface brightens slightly and nudges ~2.5 pt
/// toward its chevron with a light settle.
private struct ChatPromptPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? 0.05 : 0)
            .offset(x: configuration.isPressed ? 2.5 : 0)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
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
