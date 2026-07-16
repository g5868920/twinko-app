import Foundation

/// One lightweight local meditation record — future My Planet /
/// reflection input. Deliberately compact: a short derived source
/// summary at most, never a Chat transcript or a full Tarot
/// interpretation, and nothing here is ever logged to analytics.
struct MeditationSessionRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let startedAt: Date
    var endedAt: Date?
    let source: String            // MeditationSourceType.rawValue
    let sourceSummary: String?
    let focus: MeditationFocus
    let duration: MeditationDuration
    let optionalNote: String?
    var completed: Bool
    var finalFeeling: String?     // MeditationMood.rawValue

    init(id: UUID = UUID(), startedAt: Date = .now, endedAt: Date? = nil,
         source: MeditationSourceType, sourceSummary: String?,
         focus: MeditationFocus, duration: MeditationDuration,
         optionalNote: String?, completed: Bool = false,
         finalFeeling: MeditationMood? = nil) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.source = source.rawValue
        self.sourceSummary = sourceSummary
        self.focus = focus
        self.duration = duration
        self.optionalNote = optionalNote
        self.completed = completed
        self.finalFeeling = finalFeeling?.rawValue
    }
}

/// Persists meditation records through the existing JSONStore pattern
/// (one local Codable file, no database framework). Completed and
/// early-ended sessions are recorded distinctly.
@MainActor
final class MeditationRecordStore: ObservableObject {
    @Published private(set) var records: [MeditationSessionRecord]

    private let store: JSONStore
    private nonisolated static let fileName = "meditation_records"

    nonisolated init(store: JSONStore = JSONStore()) {
        self.store = store
        _records = Published(initialValue:
            store.load([MeditationSessionRecord].self, from: Self.fileName) ?? [])
    }

    /// Registers a just-started session and returns its record id.
    func beginSession(source: MeditationSourceType, sourceSummary: String?,
                      focus: MeditationFocus, duration: MeditationDuration,
                      optionalNote: String?) -> UUID {
        let record = MeditationSessionRecord(source: source,
                                             sourceSummary: sourceSummary,
                                             focus: focus, duration: duration,
                                             optionalNote: optionalNote)
        records.append(record)
        persist()
        return record.id
    }

    /// Marks the session ended — `completed` distinguishes a finished
    /// session from an early exit.
    func endSession(_ id: UUID, completed: Bool) {
        guard let index = records.firstIndex(where: { $0.id == id }) else { return }
        records[index].endedAt = .now
        records[index].completed = completed
        persist()
    }

    /// Persists the post-session reflection when the user selects one.
    func setFinalFeeling(_ id: UUID, feeling: MeditationMood) {
        guard let index = records.firstIndex(where: { $0.id == id }) else { return }
        records[index].finalFeeling = feeling.rawValue
        persist()
    }

    private func persist() {
        store.save(records, as: Self.fileName)
    }
}
