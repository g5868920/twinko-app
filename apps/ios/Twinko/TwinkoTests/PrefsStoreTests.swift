import XCTest
@testable import Twinko

@MainActor
final class PrefsStoreTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("TwinkoPrefsTests-\(UUID().uuidString)", isDirectory: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    private var jsonStore: JSONStore { JSONStore(directory: tempDirectory) }

    func testDefaultLanguageIsTraditionalChinese() {
        let store = PrefsStore(store: jsonStore)
        XCTAssertEqual(store.language, .traditionalChinese)
        XCTAssertEqual(store.locale.identifier, "zh-Hant")
    }

    func testLanguagePersistsAcrossInstances() {
        let first = PrefsStore(store: jsonStore)
        first.language = .english

        let second = PrefsStore(store: jsonStore)
        XCTAssertEqual(second.language, .english)
        XCTAssertEqual(second.locale.identifier, "en")
    }

    func testMalformedPrefsFileFallsBackToDefaults() throws {
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        try Data("nonsense".utf8).write(to: tempDirectory.appendingPathComponent("prefs.json"))
        let store = PrefsStore(store: jsonStore)
        XCTAssertEqual(store.language, .traditionalChinese)
    }

    func testHomeStringsCoverEveryModeInBothLanguages() {
        for mode in HomeMode.allCases {
            for lang in AppLanguage.allCases {
                XCTAssertFalse(HomeStrings.modeLabel(mode, lang).isEmpty)
                XCTAssertFalse(HomeStrings.modeAccessibilityLabel(mode, lang).isEmpty)
            }
        }
        XCTAssertEqual(HomeStrings.modeLabel(.zodiac, .english), "Zodiac",
                       "Home label must be Zodiac, not Horoscope (spec §18)")
        XCTAssertEqual(HomeStrings.modeLabel(.meditate, .traditionalChinese), "冥想")
    }
}
