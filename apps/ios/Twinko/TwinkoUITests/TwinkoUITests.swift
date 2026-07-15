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

        // MARK: Chat — empty state, success and error states
        chatTile.tap()
        let input = app.textFields["chatInputField"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["chatStarter-0"].exists, "Empty state shows conversation starters")
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

        // MARK: Star quick menu and Chat History
        app.buttons["chatMenuButton"].tap()
        let historyRowButton = app.buttons["menuHistoryRow"]
        XCTAssertTrue(historyRowButton.waitForExistence(timeout: 5), "Quick menu should open")
        XCTAssertTrue(app.buttons["menuNewChatRow"].exists)
        attach(name: "05b-quick-menu")
        historyRowButton.tap()

        let historyRow = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "難過")).firstMatch
        XCTAssertTrue(historyRow.waitForExistence(timeout: 5), "Saved session should be listed")
        attach(name: "06-chat-history")

        app.buttons["historyBackButton"].tap() // pop history
        app.buttons["chatBackButton"].tap() // pop chat
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
        let pastBadge = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "過去")).firstMatch
        XCTAssertTrue(pastBadge.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tarotGuidanceAccept"].exists,
                      "Three-card result should offer the optional Guidance Card")
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

        // MARK: Profile sheet (no Log Out), edit flow, language switch
        XCTAssertTrue(chatTile.waitForExistence(timeout: 5))
        app.buttons["homeProfileButton"].tap()
        let settingsRow = app.buttons["sheetSettingsRow"]
        XCTAssertTrue(settingsRow.waitForExistence(timeout: 5), "Profile sheet should open")
        XCTAssertTrue(app.buttons["sheetProfileRow"].exists)
        XCTAssertTrue(app.buttons["sheetPrivacyRow"].exists)
        XCTAssertTrue(app.staticTexts["小雅"].exists, "Header should show the profile name")
        XCTAssertFalse(app.staticTexts["登出"].exists, "Log Out must not exist (D-055)")
        XCTAssertFalse(app.staticTexts["Log Out"].exists)
        attach(name: "13-profile-sheet")

        // Edit Profile: Back with unsaved changes must confirm, and a
        // discard must not leak into the profile summary.
        app.buttons["sheetEditButton"].tap()
        let nameEdit = app.textFields["editNameField"]
        XCTAssertTrue(nameEdit.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["editZodiacValue"].exists, "Zodiac shows as auto-calculated")
        attach(name: "14-edit-profile")
        nameEdit.tap()
        nameEdit.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 8))
        nameEdit.typeText("小小")
        app.buttons["editBackButton"].tap()
        let continueEditing = app.buttons["繼續編輯"]
        XCTAssertTrue(continueEditing.waitForExistence(timeout: 5),
                      "Back with unsaved changes must show the discard confirmation")
        attach(name: "15-discard-confirm")
        continueEditing.tap()
        XCTAssertTrue(nameEdit.waitForExistence(timeout: 5), "Continue Editing stays in the editor")
        app.buttons["editBackButton"].tap()
        XCTAssertTrue(app.buttons["放棄變更"].waitForExistence(timeout: 5))
        app.buttons["放棄變更"].tap()
        XCTAssertTrue(app.staticTexts["小雅"].waitForExistence(timeout: 5),
                      "Discarded edits must not appear in the profile summary")
        XCTAssertFalse(app.staticTexts["小小"].exists)

        // Edit Profile: Save persists and returns; summary updates.
        app.buttons["sheetEditButton"].tap()
        XCTAssertTrue(nameEdit.waitForExistence(timeout: 5))
        nameEdit.tap()
        nameEdit.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 8))
        nameEdit.typeText("小星")
        app.buttons["editSaveButton"].tap()
        XCTAssertTrue(app.staticTexts["小星"].waitForExistence(timeout: 6),
                      "Profile summary should update after save")
        attach(name: "16-profile-after-save")

        settingsRow.tap()
        let english = app.buttons["language-en"]
        XCTAssertTrue(english.waitForExistence(timeout: 5))
        attach(name: "17-settings")
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
        attach(name: "18-home-en-after-edit")
    }

    /// Focused Home + Profile validation (seeded profile, no feature
    /// walkthrough): image Twinko on Home, profile sheet, edit
    /// save/discard behavior, and screenshots.
    func testHomeAndProfileRefinement() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()

        let chatTile = app.buttons["homeTile-chat"]
        XCTAssertTrue(chatTile.waitForExistence(timeout: 10), "Seeded launch should land on Home")
        XCTAssertTrue(app.images["twinko_default_smile_v1_transparent"].exists,
                      "Home must render the derived transparent Twinko image")
        XCTAssertFalse(app.staticTexts["即將推出"].exists)
        attach(name: "R1-home-zh")

        // Profile sheet: minimal header (planet + name only), no Edit,
        // no zodiac summary, no Log Out.
        app.buttons["homeProfileButton"].tap()
        let profileRow = app.buttons["sheetProfileRow"]
        XCTAssertTrue(profileRow.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["sheetEditButton"].exists,
                       "Edit must not be reachable from the sheet root")
        XCTAssertFalse(app.staticTexts["登出"].exists)
        attach(name: "R2-profile-sheet")

        // Edit lives only inside Profile detail, top-right.
        profileRow.tap()
        let editButton = app.buttons["sheetEditButton"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 5),
                      "Edit should be reachable from Profile detail's nav bar")
        attach(name: "R3-profile-detail-zh")

        // Discard path
        editButton.tap()
        let nameEdit = app.textFields["editNameField"]
        XCTAssertTrue(nameEdit.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["editZodiacValue"].exists)
        attach(name: "R4-edit-profile-zh")
        nameEdit.tap()
        nameEdit.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 8))
        nameEdit.typeText("小小")
        app.buttons["editBackButton"].tap()
        XCTAssertTrue(app.buttons["繼續編輯"].waitForExistence(timeout: 5),
                      "Back with unsaved changes must confirm")
        attach(name: "R5-discard-confirm")
        app.buttons["放棄變更"].tap()
        XCTAssertTrue(app.staticTexts["小雅"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["小小"].exists, "Discarded edits must not appear")

        // Save path
        editButton.tap()
        XCTAssertTrue(nameEdit.waitForExistence(timeout: 5))
        nameEdit.tap()
        nameEdit.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 8))
        nameEdit.typeText("小星")
        app.buttons["editSaveButton"].tap()
        XCTAssertTrue(app.staticTexts["小星"].waitForExistence(timeout: 6),
                      "Saved name must appear in the profile summary")
        attach(name: "R6-profile-after-save")

        // No-changes back returns immediately (no dialog)
        editButton.tap()
        XCTAssertTrue(nameEdit.waitForExistence(timeout: 5))
        app.buttons["editBackButton"].tap()
        XCTAssertTrue(editButton.waitForExistence(timeout: 5),
                      "Back without changes should return without a dialog")

        // Switch to English via Settings and verify no mixed-language
        // values anywhere: Home labels, Zodiac, and Gender.
        app.navigationBars.buttons.element(boundBy: 0).tap() // back to sheet root
        app.buttons["sheetSettingsRow"].tap()
        let english = app.buttons["language-en"]
        XCTAssertTrue(english.waitForExistence(timeout: 5))
        english.tap()
        app.navigationBars.buttons.element(boundBy: 0).tap() // back to sheet root
        dismissSheet(app)

        XCTAssertTrue(app.staticTexts["Chat"].waitForExistence(timeout: 5),
                      "Home should switch to English labels")
        XCTAssertFalse(app.staticTexts["聊天"].exists, "No mixed-language Home labels")
        attach(name: "R7-home-en")

        app.buttons["homeProfileButton"].tap()
        app.buttons["sheetProfileRow"].tap()
        XCTAssertTrue(app.buttons["sheetEditButton"].waitForExistence(timeout: 5))
        let zodiacCard = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Capricorn")).firstMatch
        XCTAssertTrue(zodiacCard.waitForExistence(timeout: 5),
                      "English mode must show the English zodiac name, not 摩羯座")
        let genderCard = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Prefer not to say")).firstMatch
        XCTAssertTrue(genderCard.exists,
                      "English mode must show the English gender value, not 不方便透露")
        attach(name: "R8-profile-detail-en")

        app.buttons["sheetEditButton"].tap()
        XCTAssertTrue(nameEdit.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Capricorn")).firstMatch.exists)
        XCTAssertTrue(app.buttons["Prefer not to say"].exists,
                      "Gender chips must be localized in English mode")
        attach(name: "R9-edit-profile-en")
    }

    /// Focused Chat experience validation: day/night empty states,
    /// active conversation, quick menu with dimmed backdrop, history,
    /// rename, and delete confirmation.
    func testChatExperienceStates() {
        // Day empty state
        var app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile", "-uiTestForceDay"]
        app.launch()
        let chatTile = app.buttons["homeTile-chat"]
        XCTAssertTrue(chatTile.waitForExistence(timeout: 10))
        chatTile.tap()
        XCTAssertTrue(app.buttons["chatStarter-0"].waitForExistence(timeout: 5))
        attach(name: "C1-chat-empty-day")

        // Starter inserts text without auto-sending
        app.buttons["chatStarter-0"].tap()
        let input = app.textFields["chatInputField"]
        XCTAssertTrue(input.waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["chatStarter-1"].exists,
                      "Starter tap must not auto-send (still in empty state)")

        // Active conversation
        app.buttons["chatSendButton"].tap()
        let reply = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "陪")).firstMatch
        XCTAssertTrue(reply.waitForExistence(timeout: 8))
        attach(name: "C3-chat-active")

        // Quick menu with dimmed backdrop
        app.buttons["chatMenuButton"].tap()
        XCTAssertTrue(app.buttons["menuNewChatRow"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["menuHistoryRow"].exists)
        attach(name: "C4-quick-menu")

        // History via menu
        app.buttons["menuHistoryRow"].tap()
        let moreButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "更多選項")).firstMatch
        XCTAssertTrue(moreButton.waitForExistence(timeout: 5), "History row should exist")
        attach(name: "C5-history")

        // Rename flow
        moreButton.tap()
        let renameItem = app.buttons["重新命名"]
        XCTAssertTrue(renameItem.waitForExistence(timeout: 5))
        renameItem.tap()
        let renameField = app.textFields.firstMatch
        XCTAssertTrue(renameField.waitForExistence(timeout: 5))
        attach(name: "C6-rename")
        renameField.tap()
        renameField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 20))
        renameField.typeText("我的小標題")
        app.buttons["儲存"].tap()
        XCTAssertTrue(app.staticTexts["我的小標題"].waitForExistence(timeout: 5),
                      "Rename should persist and display")

        // Delete confirmation
        moreButton.tap()
        let deleteItem = app.buttons["刪除"]
        XCTAssertTrue(deleteItem.waitForExistence(timeout: 5))
        deleteItem.tap()
        let confirmBody = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "無法復原")).firstMatch
        XCTAssertTrue(confirmBody.waitForExistence(timeout: 5),
                      "Delete must require confirmation stating it cannot be undone")
        attach(name: "C7-delete-confirm")
        app.buttons["刪除"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["還沒有聊天紀錄"].waitForExistence(timeout: 5),
                      "Deleted conversation should leave history empty")

        // Night empty state (fresh launch)
        app.terminate()
        app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile", "-uiTestForceNight"]
        app.launch()
        XCTAssertTrue(app.buttons["homeTile-chat"].waitForExistence(timeout: 10))
        app.buttons["homeTile-chat"].tap()
        XCTAssertTrue(app.buttons["chatStarter-0"].waitForExistence(timeout: 5))
        attach(name: "C2-chat-empty-night")
    }

    /// Focused Tarot validation: three-card flow with optional
    /// Guidance Card, orientation labels, summary card sheet, share
    /// sheet, and the single-card flow.
    func testTarotExperienceStates() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()

        XCTAssertTrue(app.buttons["homeTile-tarot"].waitForExistence(timeout: 10))
        app.buttons["homeTile-tarot"].tap()

        // Setup: topic + optional question
        let next = app.buttons["下一步"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        attach(name: "T1-tarot-setup")
        next.tap()

        // Spread selection (visual cards)
        let threeSpread = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "三張牌")).firstMatch
        XCTAssertTrue(threeSpread.waitForExistence(timeout: 5))
        attach(name: "T2-tarot-spread")
        threeSpread.tap()

        // Shuffle ritual runs on its own, then manual reveal
        let facedown = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "蓋著的牌")).firstMatch
        XCTAssertTrue(facedown.waitForExistence(timeout: 12), "Shuffle must resolve into face-down cards")
        for _ in 0..<3 {
            let card = app.buttons.matching(
                NSPredicate(format: "label CONTAINS %@", "蓋著的牌")).firstMatch
            XCTAssertTrue(card.waitForExistence(timeout: 8))
            settleTap(card)
        }
        attach(name: "T3-tarot-revealed")

        // Result: Past/Present/Future sections + orientation labels
        let seeResult = app.buttons["看看牌想說什麼"]
        XCTAssertTrue(seeResult.waitForExistence(timeout: 5))
        seeResult.tap()
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "過去")).firstMatch.waitForExistence(timeout: 5))
        let orientationLabel = app.staticTexts.matching(
            NSPredicate(format: "label == %@ OR label == %@", "正位", "逆位")).firstMatch
        XCTAssertTrue(orientationLabel.exists, "Upright/Reversed must be labeled in text")
        attach(name: "T4-tarot-three-result")

        // Optional Guidance Card
        let guidance = app.buttons["tarotGuidanceAccept"]
        XCTAssertTrue(guidance.waitForExistence(timeout: 5))
        scrollTap(guidance, in: app)
        let guidanceCard = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "蓋著的牌")).firstMatch
        XCTAssertTrue(guidanceCard.waitForExistence(timeout: 8))
        settleTap(guidanceCard)
        XCTAssertTrue(seeResult.waitForExistence(timeout: 5))
        seeResult.tap()
        let combined = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "指引")).firstMatch
        XCTAssertTrue(combined.waitForExistence(timeout: 5), "3+1 summary should reference guidance")
        attach(name: "T5-tarot-guidance-result")

        // Summary card sheet
        let saveCard = app.buttons["tarotSaveCardButton"]
        XCTAssertTrue(saveCard.waitForExistence(timeout: 5))
        scrollTap(saveCard, in: app)
        let shareImage = app.buttons["tarotSummaryShare"]
        XCTAssertTrue(shareImage.waitForExistence(timeout: 8), "Summary card should render and offer share")
        attach(name: "T6-tarot-summary-card")
        app.buttons["完成"].tap()

        // Share sheet (native)
        let share = app.buttons["tarotShareButton"]
        XCTAssertTrue(share.waitForExistence(timeout: 5))
        scrollTap(share, in: app)
        let shareSheet = app.otherElements["ActivityListView"]
        if shareSheet.waitForExistence(timeout: 8) {
            attach(name: "T7-tarot-share-sheet")
            app.buttons["Close"].firstMatch.tap()
        } else {
            attach(name: "T7-tarot-share-sheet")
        }

        // Single-card flow via Draw Again
        let again = app.buttons["再抽一次"]
        XCTAssertTrue(again.waitForExistence(timeout: 5))
        scrollTap(again, in: app)
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        next.tap()
        let singleSpread = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "單張牌")).firstMatch
        XCTAssertTrue(singleSpread.waitForExistence(timeout: 5))
        singleSpread.tap()
        let singleCard = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "蓋著的牌")).firstMatch
        XCTAssertTrue(singleCard.waitForExistence(timeout: 12))
        settleTap(singleCard)
        XCTAssertTrue(seeResult.waitForExistence(timeout: 5))
        seeResult.tap()
        XCTAssertTrue(app.buttons["tarotShareButton"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["tarotGuidanceAccept"].exists,
                       "Guidance is offered only after a three-card reading")
        attach(name: "T8-tarot-single-result")
    }

    // MARK: Helpers

    private func goBack(_ app: XCUIApplication) {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    private func dismissSheet(_ app: XCUIApplication) {
        // Drag the sheet down from its grabber area to dismiss.
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.285))
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

    /// Swipes the screen up until the element is hittable (bottom-of-
    /// scroll buttons), then coordinate-taps it.
    private func scrollTap(_ element: XCUIElement, in app: XCUIApplication) {
        var attempts = 0
        while !element.isHittable && attempts < 6 {
            app.swipeUp()
            attempts += 1
        }
        settleTap(element)
    }

    private func attach(name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
