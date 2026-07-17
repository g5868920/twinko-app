import SwiftUI

/// Chat History: warm-ivory rows on a pale-lilac surface, one neutral
/// conversation icon per row, title + last-message preview + updated
/// time, and a More menu with Rename / Delete. Localized EN / zh-Hant.
struct ChatHistoryView: View {
    @EnvironmentObject private var chatStore: ChatStore
    @EnvironmentObject private var prefs: PrefsStore
    @Environment(\.dismiss) private var dismiss

    @State private var renameTarget: ChatSession?
    @State private var renameText = ""
    @State private var deleteTarget: ChatSession?
    @FocusState private var renameFieldFocused: Bool
    private static let renameMaxLength = 30
    @State private var actionMenuTarget: ChatSession?
    @State private var moreButtonFrames: [UUID: CGRect] = [:]

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        ZStack {
            Color.surfaceSecondary.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                if chatStore.sessions.isEmpty {
                    emptyState
                } else {
                    sessionList
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
        }
        .coordinateSpace(name: "historyRoot")
        .dockClearance()
        .onPreferenceChange(MoreButtonFrameKey.self) { moreButtonFrames = $0 }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .animation(.easeOut(duration: 0.15), value: actionMenuTarget != nil)
        .animation(.easeOut(duration: 0.2), value: renameTarget != nil)
        .animation(.easeOut(duration: 0.2), value: deleteTarget != nil)
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
                BrandedActionPopoverRow(icon: "trash", label: ChatStrings.delete(lang),
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
            title: ChatStrings.rename(lang),
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
                chatStore.delete(target.id)
                deleteTarget = nil
            }
        )
        .transition(.opacity)
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            Text(ChatStrings.history(lang))
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
                .accessibilityIdentifier("historyBackButton")
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 48)
    }

    // MARK: Rows

    private var sessionList: some View {
        ScrollView {
            LazyVStack(spacing: 8, pinnedViews: []) {
                ForEach(ChatHistoryGroup.grouped(chatStore.sessions), id: \.0) { group, sessions in
                    Text(group.label(lang))
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color.textMutedToken)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                        .padding(.leading, 4)
                        .accessibilityAddTraits(.isHeader)
                    ForEach(sessions) { session in
                        row(session)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func row(_ session: ChatSession) -> some View {
        HStack(spacing: 12) {
            NavigationLink {
                ChatView(session: session)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.linkPurple)
                        .frame(width: 36, height: 36)
                        .background(Color.brandPurple.opacity(0.12), in: Circle())
                    VStack(alignment: .leading, spacing: 3) {
                        Text(session.displayTitle(for: lang))
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .foregroundStyle(Color.deepPlum)
                            .lineLimit(1)
                            .layoutPriority(1)
                        Text(session.lastMessagePreview)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(Color.textSecondaryToken)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 4)
                    Text(session.updatedAt.formatted(
                        .relative(presentation: .named)
                        .locale(prefs.locale)))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.textMutedToken)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .layoutPriority(-1)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                actionMenuTarget = session
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.textMutedToken)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
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
        .padding(.vertical, 4)
        .frame(minHeight: 58)
        // Warm ivory→lavender surface (polish 2026-07-17): softer than
        // a pure white system card, consistent with the Twinko world.
        .background(
            LinearGradient(colors: [Color(hex: 0xFFFBF2), Color(hex: 0xF5EFFA)],
                           startPoint: .top, endPoint: .bottom)
                .opacity(0.92),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.brandPurple.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color.deepPlum.opacity(0.06), radius: 5, y: 2)
    }

    // MARK: Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(ChatDayNight.twinkoAssetName())
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 110)
                .accessibilityHidden(true)
            Text(ChatStrings.emptyHistoryTitle(lang))
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.deepPlum)
            Text(ChatStrings.emptyHistoryBody(lang))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textSecondaryToken)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            Spacer()
        }
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
