import XCTest

/// Walks the full prototype flow end-to-end on a clean local state and
/// captures screenshot evidence, including the D-055 Home: 2–2–1 orbit
/// tiles, bilingual labels, Meditate/Music placeholders (no Coming
/// Soon), and the Profile bottom sheet (no Log Out).
final class TwinkoUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testFullPrototypeFlow() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset"]
        app.launch()

        // MARK: Welcome
        let continueButton = app.buttons["welcomeContinueButton"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 10), "Welcome should appear on first launch")
        attach(name: "01-welcome")
        continueButton.tap()

        // MARK: Profile Setup
        let nameField = app.textFields["profileNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("小雅")

        let gender = app.buttons["不方便透露"]
        XCTAssertTrue(gender.waitForExistence(timeout: 3))
        gender.tap()
        attach(name: "02-profile-setup")

        let save = app.buttons["profileSaveButton"]
        XCTAssertTrue(save.isEnabled)
        save.tap()

        // MARK: Home (Traditional Chinese)
        let chatTile = app.buttons["homeTile-chat"]
        XCTAssertTrue(chatTile.waitForExistence(timeout: 5), "Home should appear after saving the profile")
        XCTAssertTrue(app.staticTexts["聊天"].exists)
        XCTAssertTrue(app.staticTexts["塔羅"].exists)
        XCTAssertTrue(app.staticTexts["星座"].exists)
        XCTAssertTrue(app.staticTexts["冥想"].exists)
        XCTAssertTrue(app.staticTexts["音樂"].exists)
        XCTAssertFalse(app.staticTexts["即將推出"].exists, "No Coming Soon state may appear (D-055)")
        XCTAssertFalse(app.staticTexts["Coming Soon"].exists)
        attach(name: "03-home-zh")

        // MARK: Chat — success and error states
        chatTile.tap()
        let input = app.textFields["chatInputField"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        attach(name: "04-chat-empty")

        input.tap()
        input.typeText("我今天有點難過")
        app.buttons["chatSendButton"].tap()
        let reply = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "願意說出來")).firstMatch
        XCTAssertTrue(reply.waitForExistence(timeout: 8), "Scripted success response should appear")

        input.tap()
        input.typeText("測試錯誤")
        app.buttons["chatSendButton"].tap()
        let fallback = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "沒有完全聽懂")).firstMatch
        XCTAssertTrue(fallback.waitForExistence(timeout: 8), "Fallback/error response should appear")
        attach(name: "05-chat-conversation")

        // MARK: Chat History
        app.buttons["聊天紀錄"].tap()
        let historyRow = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "我今天有點難過")).firstMatch
        XCTAssertTrue(historyRow.waitForExistence(timeout: 5), "Saved session should be listed by its title")
        attach(name: "06-chat-history")

        goBack(app) // pop history
        goBack(app) // pop chat
        XCTAssertTrue(chatTile.waitForExistence(timeout: 5))

        // MARK: Tarot — single card
        app.buttons["homeTile-tarot"].tap()
        let next = app.buttons["下一步"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        attach(name: "07-tarot-setup")
        next.tap()

        let singleSpread = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "單張牌")).firstMatch
        XCTAssertTrue(singleSpread.waitForExistence(timeout: 5))
        singleSpread.tap()

        let facedown = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "蓋著的牌")).firstMatch
        XCTAssertTrue(facedown.waitForExistence(timeout: 10), "Shuffle must resolve into face-down cards")
        settleTap(facedown)

        let seeResult = app.buttons["看看牌想說什麼"]
        XCTAssertTrue(seeResult.waitForExistence(timeout: 5))
        seeResult.tap()
        let restart = app.buttons["再抽一次"]
        XCTAssertTrue(restart.waitForExistence(timeout: 5))
        attach(name: "08-tarot-single-result")

        // MARK: Tarot — three cards
        restart.tap()
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        next.tap()
        let threeSpread = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "三張牌")).firstMatch
        XCTAssertTrue(threeSpread.waitForExistence(timeout: 5))
        threeSpread.tap()

        for _ in 0..<3 {
            let card = app.buttons.matching(
                NSPredicate(format: "label CONTAINS %@", "蓋著的牌")).firstMatch
            XCTAssertTrue(card.waitForExistence(timeout: 10))
            settleTap(card)
        }
        XCTAssertTrue(seeResult.waitForExistence(timeout: 5))
        seeResult.tap()
        let situation = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "情境")).firstMatch
        XCTAssertTrue(situation.waitForExistence(timeout: 5))
        attach(name: "09-tarot-three-result")

        let home = app.buttons["回到首頁"]
        XCTAssertTrue(home.waitForExistence(timeout: 5))
        home.tap()

        // MARK: Zodiac (Astrology)
        XCTAssertTrue(chatTile.waitForExistence(timeout: 5))
        app.buttons["homeTile-zodiac"].tap()
        let lucky = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "幸運數字")).firstMatch
        XCTAssertTrue(lucky.waitForExistence(timeout: 5))
        attach(name: "10-astrology")
        goBack(app)

        // MARK: Meditate placeholder
        XCTAssertTrue(chatTile.waitForExistence(timeout: 5))
        app.buttons["homeTile-meditate"].tap()
        let meditateLine = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "深呼吸")).firstMatch
        XCTAssertTrue(meditateLine.waitForExistence(timeout: 5), "Meditate placeholder should open")
        XCTAssertFalse(app.staticTexts["即將推出"].exists)
        attach(name: "11-meditate-placeholder")
        goBack(app)

        // MARK: Music placeholder
        XCTAssertTrue(chatTile.waitForExistence(timeout: 5))
        app.buttons["homeTile-music"].tap()
        let musicLine = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "安靜的片刻")).firstMatch
        XCTAssertTrue(musicLine.waitForExistence(timeout: 5), "Music placeholder should open")
        attach(name: "12-music-placeholder")
        goBack(app)

        // MARK: Profile sheet (no Log Out) and language switch
        XCTAssertTrue(chatTile.waitForExistence(timeout: 5))
        app.buttons["homeProfileButton"].tap()
        let settingsRow = app.buttons["sheetSettingsRow"]
        XCTAssertTrue(settingsRow.waitForExistence(timeout: 5), "Profile sheet should open")
        XCTAssertTrue(app.buttons["sheetProfileRow"].exists)
        XCTAssertTrue(app.buttons["sheetPrivacyRow"].exists)
        XCTAssertFalse(app.staticTexts["登出"].exists, "Log Out must not exist (D-055)")
        XCTAssertFalse(app.staticTexts["Log Out"].exists)
        attach(name: "13-profile-sheet")

        settingsRow.tap()
        let english = app.buttons["language-en"]
        XCTAssertTrue(english.waitForExistence(timeout: 5))
        english.tap()
        dismissSheet(app)

        // MARK: Home (English)
        XCTAssertTrue(app.staticTexts["Chat"].waitForExistence(timeout: 5),
                      "Home should switch to English labels")
        XCTAssertTrue(app.staticTexts["Tarot"].exists)
        XCTAssertTrue(app.staticTexts["Zodiac"].exists)
        XCTAssertTrue(app.staticTexts["Meditate"].exists)
        XCTAssertTrue(app.staticTexts["Music"].exists)
        XCTAssertFalse(app.staticTexts["Coming Soon"].exists)
        attach(name: "14-home-en")
    }

    // MARK: Helpers

    private func goBack(_ app: XCUIApplication) {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    private func dismissSheet(_ app: XCUIApplication) {
        // Drag the sheet down from near its top edge to dismiss.
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.48))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.99))
        start.press(forDuration: 0.05, thenDragTo: end)
    }

    /// Waits out any in-flight transition, then taps via coordinate —
    /// coordinate taps skip the AX scroll-to-visible action that fails
    /// on animating elements.
    private func settleTap(_ element: XCUIElement) {
        Thread.sleep(forTimeInterval: 1.2)
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        Thread.sleep(forTimeInterval: 0.8)
    }

    private func attach(name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
