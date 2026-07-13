import SwiftUI

/// Locally saved conversations (S-010): list, reopen, delete, start a
/// new chat. Deletion asks for confirmation and is local-only.
struct ChatHistoryView: View {
    @EnvironmentObject private var chatStore: ChatStore
    @State private var pendingDeletion: ChatSession?

    var body: some View {
        Group {
            if chatStore.sessions.isEmpty {
                emptyState
            } else {
                sessionList
            }
        }
        .background {
            ZStack {
                TwinkoBackground.night.ignoresSafeArea()
                StarFieldView(tint: .twinkoGold.opacity(0.7))
            }
        }
        .navigationTitle("聊天紀錄")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.midnightNavy.opacity(0.6), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ChatView()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(Color.twinkoGold)
                }
                .accessibilityLabel(Text("開始新的對話"))
            }
        }
        .confirmationDialog(
            "刪除這段對話？",
            isPresented: Binding(
                get: { pendingDeletion != nil },
                set: { if !$0 { pendingDeletion = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("刪除", role: .destructive) {
                if let session = pendingDeletion {
                    chatStore.delete(session.id)
                }
                pendingDeletion = nil
            }
            Button("取消", role: .cancel) { pendingDeletion = nil }
        } message: {
            Text("刪除後就找不回來囉。")
        }
    }

    private var sessionList: some View {
        ScrollView {
            LazyVStack(spacing: TwinkoSpacing.s) {
                ForEach(chatStore.sessions) { session in
                    NavigationLink {
                        ChatView(session: session)
                    } label: {
                        sessionRow(session)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            pendingDeletion = session
                        } label: {
                            Label("刪除", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func sessionRow(_ session: ChatSession) -> some View {
        HStack(spacing: TwinkoSpacing.m) {
            TwinkoCharacterView(mood: .neutral, size: 40)
            VStack(alignment: .leading, spacing: 3) {
                Text(session.title)
                    .font(.twinkoHeadline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(session.updatedAt.formatted(
                        .relative(presentation: .named)
                        .locale(Locale(identifier: "zh-Hant")))
                     + "・\(session.messages.count) 則訊息")
                    .font(.twinkoCaption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
            Button {
                pendingDeletion = session
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel(Text("刪除「\(session.title)」"))
        }
        .padding(TwinkoSpacing.m)
        .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
    }

    private var emptyState: some View {
        VStack(spacing: TwinkoSpacing.m) {
            TwinkoCharacterView(mood: .neutral, size: 110)
            Text("還沒有聊天紀錄")
                .font(.twinkoHeadline)
                .foregroundStyle(.white)
            Text("跟 Twinko 聊過的話，會安安靜靜地\n收在這裡，只留在這台裝置上。")
                .font(.twinkoBody)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            NavigationLink {
                ChatView()
            } label: {
                Text("開始新的對話")
            }
            .buttonStyle(.twinkoPrimary)
            .padding(.top, TwinkoSpacing.s)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    NavigationStack {
        ChatHistoryView()
            .environmentObject(ChatStore())
    }
    .environment(\.locale, Locale(identifier: "zh-Hant"))
}
