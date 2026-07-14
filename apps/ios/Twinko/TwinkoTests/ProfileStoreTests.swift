import XCTest
@testable import Twinko

@MainActor
final class ProfileStoreTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("TwinkoTests-\(UUID().uuidString)", isDirectory: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    private var store: JSONStore { JSONStore(directory: tempDirectory) }

    private var sampleProfile: UserProfile {
        UserProfile(
            preferredName: "小星",
            birthday: Calendar.current.date(from: DateComponents(year: 1998, month: 7, day: 15))!,
            gender: .preferNotToSay
        )
    }

    func testProfilePersistsAcrossStoreInstances() {
        let first = ProfileStore(store: store)
        XCTAssertNil(first.profile)
        first.save(sampleProfile)

        let second = ProfileStore(store: store)
        XCTAssertEqual(second.profile, sampleProfile)
    }

    func testClearRemovesPersistedProfile() {
        let first = ProfileStore(store: store)
        first.save(sampleProfile)
        first.clear()
        XCTAssertNil(first.profile)

        let second = ProfileStore(store: store)
        XCTAssertNil(second.profile)
    }

    func testMalformedFileLoadsAsNil() throws {
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: tempDirectory.appendingPathComponent("profile.json"))
        let loaded = ProfileStore(store: store)
        XCTAssertNil(loaded.profile)
    }

    /// A profile persisted before Non-binary was removed from the
    /// active Gender option set must still load safely, mapping the
    /// legacy "非二元" value to `.other` rather than losing the profile.
    func testLegacyNonBinaryGenderMapsToOther() throws {
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        var json = String(data: try encoder.encode(sampleProfile), encoding: .utf8)!
        XCTAssertTrue(json.contains("不方便透露"), "Precondition: sample profile encodes preferNotToSay")
        json = json.replacingOccurrences(of: "不方便透露", with: "非二元")
        try Data(json.utf8).write(to: tempDirectory.appendingPathComponent("profile.json"))

        let loaded = ProfileStore(store: store)
        XCTAssertEqual(loaded.profile?.gender, .other)
        XCTAssertEqual(loaded.profile?.preferredName, sampleProfile.preferredName)
    }
}
