import Foundation

/// Owns locally persisted Chat sessions (D-054). Codable JSON in
/// Application Support only — no cloud, no UserDefaults, no database.
@MainActor
final class ChatStore: ObservableObject {
    @Published private(set) var sessions: [ChatSession] = []

    private let store: JSONStore
    private nonisolated static let fileName = "chat_sessions"

    nonisolated init(store: JSONStore = JSONStore()) {
        self.store = store
        let loaded = store.load([ChatSession].self, from: Self.fileName) ?? []
        _sessions = Published(initialValue: Self.sorted(loaded))
    }

    /// Insert or update a session, keeping the list sorted by recency.
    func upsert(_ session: ChatSession) {
        var updated = sessions.filter { $0.id != session.id }
        updated.append(session)
        sessions = Self.sorted(updated)
        persist()
    }

    func delete(_ id: UUID) {
        sessions.removeAll { $0.id == id }
        persist()
    }

    func session(with id: UUID) -> ChatSession? {
        sessions.first { $0.id == id }
    }

    private func persist() {
        store.save(sessions, as: Self.fileName)
    }

    private nonisolated static func sorted(_ sessions: [ChatSession]) -> [ChatSession] {
        sessions.sorted { $0.updatedAt > $1.updatedAt }
    }
}
