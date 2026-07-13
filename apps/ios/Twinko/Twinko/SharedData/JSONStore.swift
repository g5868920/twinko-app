import Foundation

/// Minimal Codable-JSON persistence helper for the local prototype
/// (D-054): files live in Application Support, are inspectable and
/// deletable, and carry no durability or encryption claim. Missing or
/// malformed files load as `nil` — never a crash.
struct JSONStore {
    let directory: URL

    /// Default store rooted at Application Support/TwinkoPrototype.
    init(directory: URL? = nil) {
        if let directory {
            self.directory = directory
        } else {
            let base = FileManager.default.urls(for: .applicationSupportDirectory,
                                                in: .userDomainMask).first!
            self.directory = base.appendingPathComponent("TwinkoPrototype", isDirectory: true)
        }
    }

    private func url(for name: String) -> URL {
        directory.appendingPathComponent(name).appendingPathExtension("json")
    }

    func load<T: Decodable>(_ type: T.Type, from name: String) -> T? {
        let url = url(for: name)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    @discardableResult
    func save<T: Encodable>(_ value: T, as name: String) -> Bool {
        do {
            try FileManager.default.createDirectory(at: directory,
                                                    withIntermediateDirectories: true)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(value)
            try data.write(to: url(for: name), options: .atomic)
            return true
        } catch {
            return false
        }
    }

    func delete(_ name: String) {
        try? FileManager.default.removeItem(at: url(for: name))
    }
}
