import Foundation

/// Owns the locally persisted profile. Loading happens synchronously at
/// init (a single tiny JSON file) so the router can decide the first
/// screen without a flash of the wrong route.
@MainActor
final class ProfileStore: ObservableObject {
    @Published private(set) var profile: UserProfile?

    private let store: JSONStore
    private static let fileName = "profile"

    nonisolated init(store: JSONStore = JSONStore()) {
        self.store = store
        _profile = Published(initialValue: store.load(UserProfile.self, from: Self.fileName))
    }

    func save(_ profile: UserProfile) {
        self.profile = profile
        store.save(profile, as: Self.fileName)
    }

    /// Prototype-only reset; also used by tests.
    func clear() {
        profile = nil
        store.delete(Self.fileName)
    }
}
