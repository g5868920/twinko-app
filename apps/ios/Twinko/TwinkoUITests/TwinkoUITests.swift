import XCTest

/// Walks the full prototype flow end-to-end on a clean local state and
/// captures screenshot evidence for every required screen (D-054 QA).
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
        attach(app, name: "01-welcome")
        continueButton.tap()

        // MARK: Profile Setup
        let nameField = app.textFields["profileNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("小雅")

        let gender = app.buttons["不方便透露"]
        XCTAssertTrue(gender.waitForExistence(timeout: 3))
        gender.tap()
        attach(app, name: "02-profile-setup")

        let save = app.buttons["profileSaveButton"]
        XCTAssertTrue(save.isEnabled)
        save.tap()

        // MARK: Home
        let chatTile = app.buttons["聊聊天"]
        XCTAssertTrue(chatTile.waitForExistence(timeout: 5), "Home should appear after saving the profile")
        XCTAssertTrue(app.staticTexts["即將推出"].firstMatch.exists, "Disabled modes must be labeled 即將推出")
        attach(app, name: "03-home")

        // MARK: Chat — success and error states
        chatTile.tap()
        let input = app.textFields["chatInputField"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        attach(app, name: "04-chat-empty")

        input.tap()
        input.typeText("我今天有點難過")
        app.buttons["chatSendButton"].tap()
        // Deterministic scripted reply after the loading state.
        let reply = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "願意說出來")).firstMatch
        XCTAssertTrue(reply.waitForExistence(timeout: 8), "Scripted success response should appear")

        input.tap()
        input.typeText("測試錯誤")
        app.buttons["chatSendButton"].tap()
        let fallback = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "沒有完全聽懂")).firstMatch
        XCTAssertTrue(fallback.waitForExistence(timeout: 8), "Fallback/error response should appear")
        attach(app, name: "05-chat-conversation")

        // MARK: Chat History
        app.buttons["聊天紀錄"].tap()
        let historyRow = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "我今天有點難過")).firstMatch
        XCTAssertTrue(historyRow.waitForExistence(timeout: 5), "Saved session should be listed by its title")
        attach(app, name: "06-chat-history")

        // Back to Home (pop history, then chat).
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(chatTile.waitForExistence(timeout: 5))

        // MARK: Tarot — single card
        app.buttons["塔羅"].tap()
        let next = app.buttons["下一步"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        attach(app, name: "07-tarot-setup")
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
        attach(app, name: "08-tarot-single-result")

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
        XCTAssertTrue(situation.waitForExistence(timeout: 5), "Three-card result should show position labels")
        attach(app, name: "09-tarot-three-result")

        let home = app.buttons["回到首頁"]
        XCTAssertTrue(home.waitForExistence(timeout: 5))
        home.tap()

        // MARK: Astrology
        XCTAssertTrue(chatTile.waitForExistence(timeout: 5))
        app.buttons["每日星座"].tap()
        let lucky = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "幸運數字")).firstMatch
        XCTAssertTrue(lucky.waitForExistence(timeout: 5), "Astrology should show the lucky fields")
        attach(app, name: "10-astrology")
    }

    /// Waits out any in-flight transition, then taps via coordinate —
    /// coordinate taps skip the AX scroll-to-visible action that fails
    /// on animating elements.
    private func settleTap(_ element: XCUIElement) {
        Thread.sleep(forTimeInterval: 1.2)
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        Thread.sleep(forTimeInterval: 0.8)
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
