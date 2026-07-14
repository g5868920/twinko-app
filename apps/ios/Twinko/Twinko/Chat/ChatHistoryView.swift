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

            if let target = renameTarget {
                renameModal(target)
            }
            if let target = deleteTarget {
                deleteModal(target)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .animation(.easeOut(duration: 0.2), value: renameTarget != nil)
        .animation(.easeOut(duration: 0.2), value: deleteTarget != nil)
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
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .background(Color.surfaceInput, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.borderSoft, lineWidth: 1)
                    )
                    .accessibilityIdentifier("renameTitleField")
            },
            cancelTitle: ChatStrings.cancel(lang),
            confirmTitle: ChatStrings.save(lang),
            confirmDisabled: renameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onCancel: { renameTarget = nil },
            onConfirm: {
                chatStore.rename(target.id, to: renameText)
                renameTarget = nil
            }
        )
        .transition(.opacity)
    }

    private func deleteModal(_ target: ChatSession) -> some View {
        BrandedModal(
            icon: "exclamationmark.triangle.fill",
            iconColor: .destructiveToken,
            title: ChatStrings.deleteConfirmTitle(lang),
            content: {
                Text(ChatStrings.deleteConfirmBody(lang))
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.textSecondaryToken)
                    .multilineTextAlignment(.center)
            },
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
            LazyVStack(spacing: 10) {
                ForEach(chatStore.sessions) { session in
                    row(session)
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
                        .background(Color.surfaceSecondary, in: Circle())
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

            Menu {
                Button {
                    renameTarget = session
                    renameText = session.displayTitle(for: lang)
                } label: {
                    Label(ChatStrings.rename(lang), systemImage: "pencil")
                }
                Button(role: .destructive) {
                    deleteTarget = session
                } label: {
                    Label(ChatStrings.delete(lang), systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.textMutedToken)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel(Text(lang == .english
                ? "More options for \(session.displayTitle(for: lang))"
                : "「\(session.displayTitle(for: lang))」的更多選項"))
        }
        .padding(.leading, 12)
        .frame(minHeight: 64)
        .background(Color.surfacePrimary, in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.borderSoft.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: Color(red: 0.06, green: 0.07, blue: 0.15).opacity(0.06),
                radius: 6, y: 2)
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

#Preview {
    NavigationStack {
        ChatHistoryView()
            .environmentObject(ChatStore())
            .environmentObject(PrefsStore())
    }
}
