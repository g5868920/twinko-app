import SwiftUI

/// Chat History (redesign 2026-07-17, reference
/// `docs/ux/references/chat_history_reference_v1.png`): a calm archive
/// of moments shared with Twinko — the softened Chat-world background,
/// a floating header, a custom glass search field, date groups with
/// starlight dividers, and warm-lilac glass conversation cards with
/// one standardized chat-bubble icon. Rename / Delete keep the branded
/// popover + modal system. Localized EN / zh-Hant.
struct ChatHistoryView: View {
    @EnvironmentObject private var chatStore: ChatStore
    @EnvironmentObject private var prefs: PrefsStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var renameTarget: ChatSession?
    @State private var renameText = ""
    @State private var deleteTarget: ChatSession?
    @FocusState private var renameFieldFocused: Bool
    private static let renameMaxLength = 30
    @State private var actionMenuTarget: ChatSession?
    @State private var moreButtonFrames: [UUID: CGRect] = [:]
    @State private var searchText = ""
    @FocusState private var searchFocused: Bool
    @State private var showingDeletedToast = false
    /// Card navigation by id (pushed via `navigationDestination`):
    /// keeps the existing push/pop stack while letting the card be a
    /// plain Button with reliable tap + haptic handling.
    @State private var openSessionID: UUID?

    private var lang: AppLanguage { prefs.language }

    private var trimmedQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var isSearching: Bool { !trimmedQuery.isEmpty }
    private var searchMatches: [ChatSession] {
        ChatHistorySearch.filter(chatStore.sessions, query: searchText, lang: lang)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                if chatStore.sessions.isEmpty {
                    emptyState
                } else {
                    searchField
                    if isSearching && searchMatches.isEmpty {
                        noResultsState
                    } else {
                        sessionList
                    }
                }
            }

            if let target = actionMenuTarget, let anchor = moreButtonFrames[target.id] {
                actionPopover(target, anchor: anchor)
            }
            if let target = renameTarget {
                renameModal(target)
            }
            if let target = deleteTarget {
                deleteModal(target)
            }

            if showingDeletedToast {
                deletedToast
            }
        }
        .background {
            // The same Chat-world background as the Chat room, quieted
            // by a code-only warm-mist overlay — the source asset is
            // untouched and stays recognizably Chat-world.
            GeometryReader { geo in
                ZStack {
                    Image("chat_v1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: 0xEFE6F7).opacity(0.55), location: 0),
                            .init(color: Color(hex: 0xF3EAF4).opacity(0.45), location: 0.5),
                            .init(color: Color(hex: 0xEFE2EE).opacity(0.55), location: 1),
                        ],
                        startPoint: .top, endPoint: .bottom)
                }
                .accessibilityHidden(true)
            }
            .ignoresSafeArea()
        }
        .coordinateSpace(name: "historyRoot")
        .dockClearance()
        .onPreferenceChange(MoreButtonFrameKey.self) { moreButtonFrames = $0 }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $openSessionID) { id in
            ChatView(session: chatStore.session(with: id) ?? ChatSession())
        }
        .animation(.easeOut(duration: 0.15), value: actionMenuTarget != nil)
        .animation(.easeOut(duration: 0.2), value: renameTarget != nil)
        .animation(.easeOut(duration: 0.2), value: deleteTarget != nil)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: isSearching)
    }

    // MARK: Branded action popover (DESIGN.md §27 — replaces native Menu)

    private func actionPopover(_ target: ChatSession, anchor: CGRect) -> some View {
        BrandedActionPopover(
            anchor: anchor,
            rows: [
                BrandedActionPopoverRow(icon: "pencil", label: ChatStrings.rename(lang),
                                         tint: .textInverseToken) {
                    renameTarget = target
                    renameText = target.displayTitle(for: lang)
                },
                BrandedActionPopoverRow(icon: "trash",
                                         label: ChatStrings.deleteConversation(lang),
                                         tint: .warningCoral) {
                    deleteTarget = target
                }
            ],
            onDismiss: { actionMenuTarget = nil }
        )
    }

    // MARK: Branded modals (DESIGN.md §26 — replaces native Alert / confirmationDialog)

    private func renameModal(_ target: ChatSession) -> some View {
        BrandedModal(
            title: ChatStrings.renameModalTitle(lang),
            content: {
                TextField("", text: $renameText)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.textPrimaryToken)
                    .tint(.linkPurple)
                    .focused($renameFieldFocused)
                    .submitLabel(.done)
                    .onSubmit { saveRename(target) }
                    .onChange(of: renameText) { _, newValue in
                        if newValue.count > Self.renameMaxLength {
                            renameText = String(newValue.prefix(Self.renameMaxLength))
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .background(Color.surfaceInput, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.borderSoft, lineWidth: 1)
                    )
                    .accessibilityIdentifier("renameTitleField")
                    .onAppear { renameFieldFocused = true }
            },
            cancelTitle: ChatStrings.cancel(lang),
            confirmTitle: ChatStrings.save(lang),
            confirmDisabled: renameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onCancel: { renameTarget = nil },
            onConfirm: { saveRename(target) }
        )
        .transition(.opacity)
    }

    /// Trims, rejects empty, persists, and locks the manual title.
    private func saveRename(_ target: ChatSession) {
        let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        chatStore.rename(target.id, to: trimmed)
        renameTarget = nil
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// One concise confirmation sentence — no separate warning
    /// subtitle (polish 2026-07-17).
    private func deleteModal(_ target: ChatSession) -> some View {
        BrandedModal(
            icon: "exclamationmark.triangle.fill",
            iconColor: .destructiveToken,
            title: ChatStrings.deleteConfirmTitle(lang),
            content: { EmptyView() },
            cancelTitle: ChatStrings.cancel(lang),
            confirmTitle: ChatStrings.delete(lang),
            isDestructive: true,
            onCancel: { deleteTarget = nil },
            onConfirm: {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
                    chatStore.delete(target.id)
                }
                deleteTarget = nil
                showDeletedToast()
            }
        )
        .transition(.opacity)
    }

    /// Short non-blocking confirmation after a delete.
    private var deletedToast: some View {
        VStack {
            Spacer()
            Label(ChatStrings.deletedToast(lang), systemImage: "checkmark")
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(Color.textInverseToken)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Color.menuDeep.opacity(0.92), in: Capsule())
                .shadow(color: Color.deepPlum.opacity(0.2), radius: 8, y: 3)
                .padding(.bottom, 96)
        }
        .transition(.opacity)
        .allowsHitTesting(false)
        .accessibilityIdentifier("historyDeletedToast")
    }

    private func showDeletedToast() {
        withAnimation(.easeOut(duration: 0.2)) { showingDeletedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeOut(duration: 0.3)) { showingDeletedToast = false }
        }
    }

    // MARK: Floating header (no bar, no large native title)

    private var header: some View {
        ZStack {
            VStack(spacing: 1) {
                Text(ChatStrings.history(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.deepPlum)
                Text(ChatStrings.historySubtitle(lang))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Color.deepPlum.opacity(0.55))
                    .lineLimit(1)
            }
            HStack {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.deepPlum)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(HistoryControlPressStyle())
                .accessibilityLabel(Text(lang == .english ? "Back" : "返回"))
                .accessibilityIdentifier("historyBackButton")
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 52)
    }

    // MARK: Custom glass search field

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.deepPlum.opacity(0.45))
            TextField(
                "", text: $searchText,
                prompt: Text(ChatStrings.searchPlaceholder(lang))
                    .foregroundStyle(Color.deepPlum.opacity(0.4))
            )
            .font(.system(.subheadline, design: .rounded))
            .foregroundStyle(Color.deepPlum)
            .tint(.linkPurple)
            .submitLabel(.search)
            .onSubmit { searchFocused = false }
            .focused($searchFocused)
            .accessibilityLabel(Text(ChatStrings.searchPlaceholder(lang)))
            .accessibilityIdentifier("historySearchField")
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.deepPlum.opacity(0.35))
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(Text(ChatStrings.clearSearch(lang)))
                .accessibilityIdentifier("historySearchClear")
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, 6)
        .frame(height: 42)
        .background(Color.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 21))
        .overlay(
            RoundedRectangle(cornerRadius: 21)
                .strokeBorder(searchFocused
                              ? Color.brandPurple.opacity(0.55)
                              : Color.brandPurple.opacity(0.22),
                              lineWidth: 1)
        )
        .shadow(color: Color.deepPlum.opacity(0.05), radius: 4, y: 2)
        .padding(.horizontal, 20)
        .padding(.top, 2)
        .padding(.bottom, 8)
    }

    // MARK: Grouped list / flat search results

    private var sessionList: some View {
        ScrollView {
            LazyVStack(spacing: 11, pinnedViews: []) {
                if isSearching {
                    sectionLabel(ChatStrings.searchResults(lang))
                    ForEach(searchMatches) { session in
                        card(session)
                    }
                } else {
                    ForEach(ChatHistoryGroup.grouped(chatStore.sessions), id: \.0) { group, sessions in
                        sectionLabel(group.label(lang))
                        ForEach(sessions) { session in
                            card(session)
                        }
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 4)
            .padding(.bottom, 16)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    /// Quiet section marker: tiny sparkle + label + fading starlight
    /// hairline — never a bold native header.
    private func sectionLabel(_ label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkle")
                .font(.system(size: 8))
                .foregroundStyle(Color.accentGold.opacity(0.7))
            Text(label)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.deepPlum.opacity(0.6))
            LinearGradient(colors: [Color.accentGold.opacity(0.35),
                                    Color.accentGold.opacity(0)],
                           startPoint: .leading, endPoint: .trailing)
                .frame(height: 1)
        }
        .padding(.top, 8)
        .padding(.leading, 2)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    // MARK: Conversation glass card

    private func card(_ session: ChatSession) -> some View {
        HStack(spacing: 10) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                openSessionID = session.id
            } label: {
                HStack(spacing: 12) {
                    chatIconOrb
                    VStack(alignment: .leading, spacing: 3) {
                        Text(session.displayTitle(for: lang))
                            .font(.system(size: 16.5, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.deepPlum)
                            .lineLimit(1)
                            .layoutPriority(1)
                        Text(session.lastMessagePreview)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(Color.deepPlum.opacity(0.55))
                            .lineLimit(1)
                    }
                    Spacer(minLength: 4)
                    Text(session.updatedAt.formatted(
                        .relative(presentation: .named)
                        .locale(prefs.locale)))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.deepPlum.opacity(0.4))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .layoutPriority(-1)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(HistoryCardPressStyle())

            Button {
                actionMenuTarget = session
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.brandPurpleDeep.opacity(0.55))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(HistoryControlPressStyle())
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: MoreButtonFrameKey.self,
                        value: [session.id: geo.frame(in: .named("historyRoot"))]
                    )
                }
            )
            .accessibilityLabel(Text(lang == .english
                ? "More options for \(session.displayTitle(for: lang))"
                : "「\(session.displayTitle(for: lang))」的更多選項"))
        }
        .padding(.leading, 12)
        .padding(.vertical, 6)
        .frame(minHeight: 64)
        .background(
            // Warm ivory-lilac glass memory card: translucent over the
            // softened background with a top catch-light.
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(colors: [Color(hex: 0xFFFBF2), Color(hex: 0xF3EBF9)],
                                   startPoint: .top, endPoint: .bottom)
                )
                .opacity(0.78)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(
                    LinearGradient(stops: [
                        .init(color: .white.opacity(0.85), location: 0),
                        .init(color: Color.brandPurple.opacity(0.25), location: 0.65),
                    ], startPoint: .top, endPoint: .bottom),
                    lineWidth: 1)
        )
        .shadow(color: Color.deepPlum.opacity(0.07), radius: 6, y: 3)
        .transition(reduceMotion ? .opacity
                    : .opacity.combined(with: .scale(scale: 0.96)))
    }

    /// The one standardized conversation icon: a simple chat bubble in
    /// a translucent lavender glass circle with a subtle inner
    /// highlight — identical for every row, no topic variation.
    private var chatIconOrb: some View {
        Image(systemName: "bubble.left")
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Color.brandPurpleDeep)
            .frame(width: 38, height: 38)
            .background(
                Circle()
                    .fill(Color.brandPurple.opacity(0.16))
                    .overlay(
                        Circle()
                            .fill(LinearGradient(stops: [
                                .init(color: .white.opacity(0.5), location: 0),
                                .init(color: .white.opacity(0), location: 0.5),
                            ], startPoint: .top, endPoint: .bottom))
                            .padding(1)
                    )
            )
            .overlay(Circle().strokeBorder(Color.brandPurple.opacity(0.3), lineWidth: 1))
            .shadow(color: Color.brandPurpleDeep.opacity(0.10), radius: 3, y: 1)
            .accessibilityHidden(true)
    }

    // MARK: True empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            ZStack {
                // Restrained memory-light dots around Twinko.
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(Color.accentGold.opacity(0.35))
                        .frame(width: 4, height: 4)
                        .offset(x: [-62.0, 66, -48, 56][index],
                                y: [-38.0, -22, 44, 30][index])
                }
                Image(ChatDayNight.twinkoAssetName())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 116, height: 116)
            }
            .accessibilityHidden(true)
            Text(ChatStrings.emptyHistoryTitle(lang))
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.deepPlum)
            Text(ChatStrings.emptyHistoryBody(lang))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.deepPlum.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                // Existing route: History is pushed from the Chat
                // landing, so popping returns to New Chat.
                dismiss()
            } label: {
                Text(ChatStrings.startChatting(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.textInverseToken)
                    .frame(minWidth: 180, minHeight: 48)
                    .background(
                        LinearGradient(colors: [.brandPurple, .brandPurpleDeep],
                                       startPoint: .top, endPoint: .bottom),
                        in: Capsule())
                    .shadow(color: Color.brandPurpleDeep.opacity(0.3), radius: 6, y: 3)
            }
            .buttonStyle(HistoryCardPressStyle())
            .padding(.top, 6)
            .accessibilityIdentifier("historyStartChatting")
            Spacer()
            Spacer()
        }
    }

    // MARK: Search no-results state (distinct from true empty)

    private var noResultsState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "text.magnifyingglass")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.brandPurpleDeep)
                .frame(width: 56, height: 56)
                .background(Color.brandPurple.opacity(0.16), in: Circle())
                .overlay(Circle().strokeBorder(Color.brandPurple.opacity(0.3),
                                               lineWidth: 1))
                .accessibilityHidden(true)
            Text(ChatStrings.noResultsTitle(lang))
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.deepPlum)
            Text(ChatStrings.noResultsBody(lang))
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Color.deepPlum.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 44)
            Button {
                searchText = ""
            } label: {
                Text(ChatStrings.clearSearch(lang))
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.brandPurpleDeep)
                    .frame(minWidth: 132, minHeight: 44)
                    .background(Color.white.opacity(0.5), in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.brandPurple.opacity(0.4),
                                                    lineWidth: 1))
            }
            .accessibilityIdentifier("historyClearSearch")
            Spacer()
            Spacer()
        }
    }
}

/// Card press: gentle 0.985 scale + slight brighten — no dramatic
/// movement.
private struct HistoryCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? 0.04 : 0)
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Quiet control press for Back and the row menu.
private struct HistoryControlPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Circle()
                    .fill(Color.brandPurple.opacity(configuration.isPressed ? 0.15 : 0))
                    .padding(4)
            )
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct MoreButtonFrameKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

#Preview {
    NavigationStack {
        ChatHistoryView()
            .environmentObject(ChatStore())
            .environmentObject(PrefsStore())
    }
}
