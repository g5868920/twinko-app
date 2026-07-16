import XCTest
@testable import Twinko

@MainActor
final class HomeCheckInTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("TwinkoCheckInTests-\(UUID().uuidString)", isDirectory: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    private var jsonStore: JSONStore { JSONStore(directory: tempDirectory) }

    // MARK: Daily Check-in storage

    func testSaveCreatesTodayCheckInAndPersists() {
        let store = CheckInStore(store: jsonStore)
        XCTAssertNil(store.today)

        store.save(mood: .anxious, need: .ground)
        XCTAssertEqual(store.today?.mood, .anxious)
        XCTAssertEqual(store.today?.need, .ground)
        XCTAssertEqual(store.today?.localDate, DailyCheckIn.dateKey())

        let reloaded = CheckInStore(store: jsonStore)
        XCTAssertEqual(reloaded.today?.mood, .anxious)
        XCTAssertEqual(reloaded.today?.need, .ground)
    }

    func testSameDayEditUpdatesRecordInsteadOfCreatingNew() {
        let store = CheckInStore(store: jsonStore)
        store.save(mood: .tired, need: .rest)
        let firstID = store.today?.id

        store.save(mood: .happy, need: .talk)
        XCTAssertEqual(store.today?.id, firstID)
        XCTAssertEqual(store.today?.mood, .happy)
        XCTAssertEqual(store.today?.need, .talk)
    }

    func testYesterdayCheckInDoesNotCountAsToday() {
        let yesterdayKey = DailyCheckIn.dateKey(for: Date(timeIntervalSinceNow: -86_400))
        jsonStore.save(DailyCheckIn(localDate: yesterdayKey, mood: .calm, need: .rest),
                       as: "daily_checkin")
        let store = CheckInStore(store: jsonStore)
        XCTAssertNil(store.today)
    }

    // MARK: Recommendation mapping (need drives primary)

    func testNeedDrivesPrimaryAction() {
        let provider = LocalHomeRecommendationProvider()
        func primary(_ mood: CheckInMood, _ need: CheckInNeed) -> HomeAction {
            provider.recommendation(
                for: DailyCheckIn(localDate: DailyCheckIn.dateKey(), mood: mood, need: need),
                lang: .traditionalChinese).primaryAction
        }

        XCTAssertEqual(primary(.happy, .talk), .chat)
        XCTAssertEqual(primary(.anxious, .ground),
                       .meditation(focus: .releaseAnxiety, duration: .three))
        XCTAssertEqual(primary(.tired, .ground),
                       .meditation(focus: .calmDown, duration: .three))
        XCTAssertEqual(primary(.confused, .direction), .tarot)
        // Music is a placeholder — Rest routes to a sleep meditation.
        XCTAssertEqual(primary(.tired, .rest),
                       .meditation(focus: .sleep, duration: .five))
    }

    func testRecommendationIncludesMessageAndSecondaryAction() {
        let provider = LocalHomeRecommendationProvider()
        let rec = provider.recommendation(
            for: DailyCheckIn(localDate: DailyCheckIn.dateKey(), mood: .anxious, need: .ground),
            lang: .traditionalChinese)
        XCTAssertFalse(rec.message.isEmpty)
        XCTAssertEqual(rec.secondaryAction, .chat)
    }

    // MARK: Check-in → Meditation handoff context

    func testCheckInMeditationSourceContext() {
        XCTAssertEqual(MeditationSourceType.checkIn.rawValue, "check_in")
        let context = MeditationSourceContext(sourceType: .checkIn,
                                              focusSummary: "今天感覺焦慮，想安定下來",
                                              recommendedFocus: .releaseAnxiety)
        XCTAssertEqual(context.recommendedFocus, .releaseAnxiety)
        XCTAssertFalse(MeditationStrings.fromCheckIn(.traditionalChinese).isEmpty)
    }

    // MARK: Tab shell mapping

    func testFourTabsAndSettingsIsNotATab() {
        XCTAssertEqual(AppTab.allCases, [.home, .chat, .explore, .myPlanet])
        // Settings is reached from the Home gear, never from the tab bar.
        XCTAssertFalse(AppTab.allCases.map(\.identifier).contains("tab-settings"))
        for lang in [AppLanguage.traditionalChinese, .english] {
            XCTAssertNotEqual(HomeExperienceStrings.settings(lang),
                              HomeExperienceStrings.tabMyPlanet(lang))
        }
    }
}
