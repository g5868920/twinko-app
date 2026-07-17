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
            NSPredicate(format: "label CONTAINS %@", "心情低落")).firstMatch
        XCTAssertTrue(historyRow.waitForExistence(timeout: 5),
                      "Saved session should be listed with its topic-style title")
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
        let restart = app.buttons["開始新的占卜"]
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

        // MARK: Zodiac (Horoscope)
        XCTAssertTrue(chatTile.waitForExistence(timeout: 5))
        app.buttons["homeTile-zodiac"].tap()
        XCTAssertTrue(app.buttons["horoscopeDimension-overall"].waitForExistence(timeout: 8),
                      "Horoscope Today should render dimension cards")
        let lucky = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS %@", "幸運數字")).firstMatch
        var luckyScrolls = 0
        while !lucky.exists && luckyScrolls < 5 {
            app.swipeUp()
            luckyScrolls += 1
        }
        XCTAssertTrue(lucky.exists)
        attach(name: "10-horoscope")
        app.buttons["horoscopeBackButton"].tap()

        // MARK: Meditation setup
        XCTAssertTrue(chatTile.waitForExistence(timeout: 5))
        app.buttons["homeTile-meditate"].tap()
        XCTAssertTrue(app.buttons["meditationStartButton"].waitForExistence(timeout: 8),
                      "Meditation setup should open")
        XCTAssertFalse(app.staticTexts["即將推出"].exists)
        attach(name: "11-meditation-setup")
        app.buttons["meditationBackButton"].tap()

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

        // Edit Profile (entered by tapping the Name card directly):
        // Back with unsaved changes must confirm, and a discard must
        // not leak into the profile summary.
        app.buttons["sheetProfileRow"].tap()
        let nameCard = app.buttons["profileCard-name"]
        XCTAssertTrue(nameCard.waitForExistence(timeout: 5),
                      "Profile cards should be directly tappable to edit")
        nameCard.tap()
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
        nameCard.tap()
        XCTAssertTrue(nameEdit.waitForExistence(timeout: 5))
        nameEdit.tap()
        nameEdit.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 8))
        nameEdit.typeText("小星")
        app.buttons["editSaveButton"].tap()
        XCTAssertTrue(app.staticTexts["小星"].waitForExistence(timeout: 6),
                      "Profile summary should update after save")
        attach(name: "16-profile-after-save")

        app.navigationBars.buttons.element(boundBy: 0).tap() // back to My Planet root
        XCTAssertTrue(settingsRow.waitForExistence(timeout: 5))
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

        // Editing is reached by tapping profile cards directly.
        profileRow.tap()
        let editButton = app.buttons["profileCard-name"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 5),
                      "Profile cards should be directly tappable to edit")
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
        XCTAssertTrue(app.buttons["profileCard-name"].waitForExistence(timeout: 5))
        let zodiacCard = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Capricorn")).firstMatch
        XCTAssertTrue(zodiacCard.waitForExistence(timeout: 5),
                      "English mode must show the English zodiac name, not 摩羯座")
        let genderCard = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Prefer not to say")).firstMatch
        XCTAssertTrue(genderCard.exists,
                      "English mode must show the English gender value, not 不方便透露")
        attach(name: "R8-profile-detail-en")

        app.buttons["profileCard-name"].tap()
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

    /// Focused Horoscope validation: entry with default sign from the
    /// seeded birthday, dimension expand/collapse, sign switching,
    /// summary card preview, and text share.
    func testHoroscopeExperienceStates() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()

        // Entry: seeded birthday (2000-01-01) => Capricorn 摩羯座
        XCTAssertTrue(app.buttons["homeTile-zodiac"].waitForExistence(timeout: 10))
        app.buttons["homeTile-zodiac"].tap()
        let mySignBadge = app.staticTexts["我的星座"]
        XCTAssertTrue(mySignBadge.waitForExistence(timeout: 8),
                      "Profile sign should be marked as My Sign")
        XCTAssertTrue(app.staticTexts["摩羯座"].firstMatch.exists,
                      "Seeded birthday must derive Capricorn as the default sign")
        attach(name: "H1-horoscope-today")

        // Dimensions: Overall expanded by default; expanding Love
        // collapses it (one at a time)
        let overall = app.buttons["horoscopeDimension-overall"]
        let love = app.buttons["horoscopeDimension-love"]
        XCTAssertTrue(overall.waitForExistence(timeout: 5))
        XCTAssertTrue(love.exists)
        settleTap(love)
        attach(name: "H2-horoscope-dimensions")

        // Lucky details (LazyVGrid below the fold — scroll into view)
        let lucky = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS %@", "幸運數字")).firstMatch
        var luckyScrolls = 0
        while !lucky.exists && luckyScrolls < 5 {
            app.swipeUp()
            luckyScrolls += 1
        }
        XCTAssertTrue(lucky.exists, "Lucky details should render")
        app.swipeDown()
        app.swipeDown()

        // Sign switching (does not overwrite profile sign)
        settleTap(app.buttons["horoscopeChangeSign"])
        let leoOption = app.buttons["zodiacOption-leo"]
        XCTAssertTrue(leoOption.waitForExistence(timeout: 5))
        attach(name: "H3-zodiac-selector")
        settleTap(leoOption)
        XCTAssertTrue(app.staticTexts["獅子座"].firstMatch.waitForExistence(timeout: 8),
                      "Selector should switch the viewed sign to Leo")
        XCTAssertFalse(app.staticTexts["我的星座"].exists,
                       "Viewing another sign must not mark it as My Sign")
        attach(name: "H4-horoscope-switched")

        // Summary card preview
        let saveCard = app.buttons["horoscopeSaveCardButton"]
        scrollTap(saveCard, in: app)
        let cardSave = app.buttons["horoscopeCardSave"]
        XCTAssertTrue(cardSave.waitForExistence(timeout: 10),
                      "Summary card should render and offer Save to Photos")
        XCTAssertTrue(app.buttons["horoscopeCardShare"].exists)
        attach(name: "H5-summary-card")
        app.buttons["關閉"].tap()

        // Text share sheet
        let share = app.buttons["horoscopeShareButton"]
        scrollTap(share, in: app)
        let shareSheet = app.otherElements["ActivityListView"]
        if shareSheet.waitForExistence(timeout: 8) {
            attach(name: "H6-share-sheet")
            app.buttons["Close"].firstMatch.tap()
        } else {
            attach(name: "H6-share-sheet")
        }
    }

    /// Focused My Planet walkthrough (redesign 2026-07-16): Home entry,
    /// landing, tappable profile cards, birthday wheel, Settings, and
    /// Privacy.
    func testMyPlanetWalkthrough() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()

        // Home entry → My Planet landing
        XCTAssertTrue(app.buttons["homeProfileButton"].waitForExistence(timeout: 10))
        app.buttons["homeProfileButton"].tap()
        XCTAssertTrue(app.buttons["sheetProfileRow"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["sheetSettingsRow"].exists)
        XCTAssertTrue(app.buttons["sheetPrivacyRow"].exists)
        XCTAssertTrue(app.staticTexts["小雅"].exists, "Identity area shows the name")
        attach(name: "MP1-my-planet-landing")

        // Profile: tappable cards, no Edit button
        app.buttons["sheetProfileRow"].tap()
        let nameCard = app.buttons["profileCard-name"]
        XCTAssertTrue(nameCard.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["profileCard-birthday"].exists)
        XCTAssertTrue(app.buttons["profileCard-gender"].exists)
        XCTAssertFalse(app.buttons["sheetEditButton"].exists,
                       "No prominent Edit button — cards are the affordance")
        attach(name: "MP2-profile-cards")

        // Tap birthday card → editor with the wheel picker
        app.buttons["profileCard-birthday"].tap()
        XCTAssertTrue(app.textFields["editNameField"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.datePickers["editBirthdayPicker"].waitForExistence(timeout: 5),
                      "Birthday uses a year/month/day wheel in one flow")
        attach(name: "MP3-edit-birthday-wheel")
        app.buttons["editBackButton"].tap()

        // Settings (Option B)
        XCTAssertTrue(nameCard.waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["sheetSettingsRow"].waitForExistence(timeout: 5))
        app.buttons["sheetSettingsRow"].tap()
        XCTAssertTrue(app.buttons["language-en"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["language-zh-Hant"].exists)
        attach(name: "MP4-settings")

        // Privacy
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["sheetPrivacyRow"].waitForExistence(timeout: 5))
        app.buttons["sheetPrivacyRow"].tap()
        let privacyLine = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "只存在這台裝置")).firstMatch
        XCTAssertTrue(privacyLine.waitForExistence(timeout: 5))
        attach(name: "MP5-privacy")
    }

    /// Focused Chat refinement walkthrough (founder/CPO review
    /// 2026-07-16): quick prompts, meditation intent routing,
    /// confirmation card, handoff, history grouping, and menu toggle.
    func testChatRefinementWalkthrough() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()

        // New Chat: restyled quick prompts with the safe wording
        XCTAssertTrue(app.buttons["homeTile-chat"].waitForExistence(timeout: 10))
        app.buttons["homeTile-chat"].tap()
        let input = app.textFields["chatInputField"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "壓力有點大")).firstMatch.exists,
            "Replaced quick prompt should be present")
        XCTAssertFalse(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "喘不過氣")).firstMatch.exists,
            "Breathing-emergency wording must be gone")
        attach(name: "CR1-new-chat-prompts")

        // Explicit meditation request → confirmation card, no fallback
        input.tap()
        input.typeText("我想要冥想")
        app.buttons["chatSendButton"].tap()
        let offerCard = app.descendants(matching: .any)["chatMeditationOfferCard"]
        XCTAssertTrue(offerCard.waitForExistence(timeout: 8),
                      "Explicit request should show the confirmation card")
        XCTAssertFalse(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "沒有完全聽懂")).firstMatch.exists,
            "Explicit intent must not hit the misunderstanding fallback")
        attach(name: "CR2-meditation-confirmation")

        // Decline dismisses silently (allow the fade-out to finish)
        app.buttons["chatMeditationDecline"].tap()
        Thread.sleep(forTimeInterval: 0.8)
        XCTAssertFalse(offerCard.exists)

        // Topic-only mention does not trigger confirmation
        input.tap()
        input.typeText("你覺得冥想有用嗎")
        app.buttons["chatSendButton"].tap()
        Thread.sleep(forTimeInterval: 2.0)
        XCTAssertFalse(offerCard.exists, "Topic mention must not show the confirmation card")

        // A later explicit request reopens confirmation; accept hands
        // off to the Meditation Context Review with chat context.
        input.tap()
        input.typeText("帶我冥想")
        app.buttons["chatSendButton"].tap()
        XCTAssertTrue(offerCard.waitForExistence(timeout: 8))
        settleTap(app.buttons["chatMeditationAccept"])
        XCTAssertTrue(app.buttons["meditationStartButton"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any)["meditationSourceCard"]
            .waitForExistence(timeout: 5), "Context Review should acknowledge the Chat source")
        attach(name: "CR3-chat-context-review")
        app.buttons["meditationBackButton"].tap()
        XCTAssertTrue(input.waitForExistence(timeout: 5))

        // Star menu: toggle open/closed, no floating X
        settleTap(app.buttons["chatMenuButton"])
        XCTAssertTrue(app.buttons["menuNewChatRow"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["menuCloseButton"].exists, "Floating X is removed")
        attach(name: "CR4-chat-menu")
        settleTap(app.buttons["chatMenuButton"]) // toggle closes
        XCTAssertFalse(app.buttons["menuNewChatRow"].waitForExistence(timeout: 2))

        // History: date grouping + rename lock
        settleTap(app.buttons["chatMenuButton"])
        XCTAssertTrue(app.buttons["menuHistoryRow"].waitForExistence(timeout: 5))
        settleTap(app.buttons["menuHistoryRow"])
        XCTAssertTrue(app.staticTexts["今天"].waitForExistence(timeout: 5),
                      "History should group by date")
        let moreButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "更多選項")).firstMatch
        XCTAssertTrue(moreButton.waitForExistence(timeout: 5))
        settleTap(moreButton)
        let renameItem = app.buttons["重新命名"]
        XCTAssertTrue(renameItem.waitForExistence(timeout: 5))
        settleTap(renameItem)
        let renameField = app.textFields["renameTitleField"]
        XCTAssertTrue(renameField.waitForExistence(timeout: 5))
        renameField.tap()
        renameField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 20))
        renameField.typeText("我的固定標題")
        app.buttons["儲存"].tap()
        XCTAssertTrue(app.staticTexts["我的固定標題"].waitForExistence(timeout: 5),
                      "Manual rename should apply immediately")
        attach(name: "CR5-history-grouped-renamed")
    }

    /// Focused Tarot refinement walkthrough (founder review 2026-07-16):
    /// setup, three-card selection count, expand/collapse, CTA
    /// hierarchy, summary card, meditation context review, and return
    /// navigation back to the Tarot result.
    func testTarotRefinementWalkthrough() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()

        // Setup (idle Twinko, suggestion chips)
        XCTAssertTrue(app.buttons["homeTile-tarot"].waitForExistence(timeout: 10))
        app.buttons["homeTile-tarot"].tap()
        let next = app.buttons["下一步"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        attach(name: "TR1-tarot-setup")
        next.tap()

        // Three-card spread: shuffle must resolve to exactly three
        // face-down cards.
        let threeSpread = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "三張牌")).firstMatch
        XCTAssertTrue(threeSpread.waitForExistence(timeout: 5))
        threeSpread.tap()
        let facedownQuery = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "蓋著的牌"))
        XCTAssertTrue(facedownQuery.firstMatch.waitForExistence(timeout: 12))
        Thread.sleep(forTimeInterval: 0.8)
        XCTAssertEqual(facedownQuery.count, 3,
                       "A Three-Card reading must isolate exactly three cards")
        attach(name: "TR2-three-selected")

        for _ in 0..<3 {
            let card = facedownQuery.firstMatch
            XCTAssertTrue(card.waitForExistence(timeout: 8))
            settleTap(card)
        }
        let seeResult = app.buttons["看看牌想說什麼"]
        XCTAssertTrue(seeResult.waitForExistence(timeout: 5))
        seeResult.tap()

        // Result: expand/collapse the first card's full interpretation
        let expandButtons = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH %@", "tarotExpand-"))
        XCTAssertTrue(expandButtons.firstMatch.waitForExistence(timeout: 5))
        let firstExpand = expandButtons.firstMatch
        settleTap(firstExpand)
        XCTAssertTrue(app.staticTexts["小小的反思"].firstMatch.waitForExistence(timeout: 5),
                      "Expanding should reveal the full interpretation and reflection")
        settleTap(firstExpand)

        // Optional Guidance Card (one only), then the final result
        let saveCard = app.buttons["tarotSaveCardButton"]
        scrollTap(app.buttons["tarotGuidanceAccept"], in: app)
        XCTAssertTrue(facedownQuery.firstMatch.waitForExistence(timeout: 8))
        settleTap(facedownQuery.firstMatch)
        XCTAssertTrue(seeResult.waitForExistence(timeout: 5))
        seeResult.tap()

        var scrolls = 0
        while !app.buttons["回到首頁"].isHittable && scrolls < 6 {
            app.swipeUp()
            scrolls += 1
        }
        XCTAssertTrue(saveCard.exists)
        XCTAssertTrue(app.buttons["tarotMeditationCTA"].exists)
        XCTAssertTrue(app.buttons["tarotShareButton"].exists)
        XCTAssertTrue(app.buttons["開始新的占卜"].exists, "Draw Again is renamed")
        XCTAssertFalse(app.buttons["再抽一次"].exists)
        attach(name: "TR3-result-cta")

        // Summary card (idle character + runtime effects)
        settleTap(saveCard)
        XCTAssertTrue(app.buttons["tarotSummaryShare"].waitForExistence(timeout: 10))
        attach(name: "TR4-summary-card")
        app.buttons["完成"].tap()

        // Meditation handoff → Context Review with recommendations
        let medCTA = app.buttons["tarotMeditationCTA"]
        scrollTap(medCTA, in: app)
        XCTAssertTrue(app.buttons["meditationStartButton"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any)["meditationSourceCard"]
            .waitForExistence(timeout: 5))
        let recommended = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS %@", "建議")).firstMatch
        XCTAssertTrue(recommended.exists, "Twinko's recommendation should be marked")
        attach(name: "TR5-meditation-context-review")

        // Generate → session → completion → Done returns to the
        // original Tarot result with the reading intact.
        settleTap(app.buttons["meditationStartButton"])
        let medNext = app.buttons["meditationNextButton"]
        XCTAssertTrue(medNext.waitForExistence(timeout: 10))
        for _ in 0..<5 { settleTap(medNext) }
        let done = app.buttons["meditationDoneButton"]
        XCTAssertTrue(done.waitForExistence(timeout: 8))
        scrollTap(done, in: app)
        XCTAssertTrue(app.buttons["tarotMeditationCTA"].waitForExistence(timeout: 8),
                      "Done must return to the original Tarot result")
        XCTAssertTrue(app.buttons["tarotSaveCardButton"].exists,
                      "Reading and result actions must be preserved")
    }

    /// Focused Meditation validation: direct setup → generating →
    /// session → completion, then Chat and Tarot handoffs with source
    /// context prefill.
    func testMeditationExperienceStates() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()

        // Direct entry: setup
        XCTAssertTrue(app.buttons["homeTile-meditate"].waitForExistence(timeout: 10))
        app.buttons["homeTile-meditate"].tap()
        let start = app.buttons["meditationStartButton"]
        XCTAssertTrue(start.waitForExistence(timeout: 8), "Setup should open")
        XCTAssertTrue(app.buttons["meditationFocus-release_anxiety"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["meditationSourceCard"].exists,
                       "Direct entry has no source acknowledgment")
        attach(name: "MD1-meditation-setup")

        settleTap(app.buttons["meditationFocus-release_anxiety"])
        scrollTap(start, in: app)
        attach(name: "MD2-meditation-generating")

        // Session: five segments via Continue, then Finish
        let next = app.buttons["meditationNextButton"]
        XCTAssertTrue(next.waitForExistence(timeout: 10), "Session should open after generation")
        attach(name: "MD3-meditation-session")
        for _ in 0..<4 { settleTap(next) }
        XCTAssertTrue(app.buttons["meditationNextButton"].exists)
        settleTap(next) // Finish

        // Completion
        let done = app.buttons["meditationDoneButton"]
        XCTAssertTrue(done.waitForExistence(timeout: 8), "Completion should appear")
        settleTap(app.buttons["meditationMood-calmer"])
        attach(name: "MD4-meditation-completion")
        scrollTap(done, in: app)

        // Chat handoff
        XCTAssertTrue(app.buttons["homeTile-chat"].waitForExistence(timeout: 8))
        app.buttons["homeTile-chat"].tap()
        let input = app.textFields["chatInputField"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.tap()
        input.typeText("最近工作壓力好大")
        app.buttons["chatSendButton"].tap()
        let accept = app.buttons["chatMeditationAccept"]
        XCTAssertTrue(accept.waitForExistence(timeout: 10),
                      "Meditation offer should appear after a Twinko reply")
        attach(name: "MD5-chat-offer")
        settleTap(accept)
        XCTAssertTrue(app.buttons["meditationStartButton"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any)["meditationSourceCard"].waitForExistence(timeout: 5),
                      "Chat-derived setup should acknowledge the source")
        attach(name: "MD5b-chat-handoff-setup")
        app.buttons["meditationBackButton"].tap()
        XCTAssertTrue(input.waitForExistence(timeout: 5), "Back should return to Chat intact")
        app.buttons["chatBackButton"].tap()

        // Tarot handoff
        XCTAssertTrue(app.buttons["homeTile-tarot"].waitForExistence(timeout: 8))
        app.buttons["homeTile-tarot"].tap()
        let tarotNext = app.buttons["下一步"]
        XCTAssertTrue(tarotNext.waitForExistence(timeout: 5))
        tarotNext.tap()
        let singleSpread = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "單張牌")).firstMatch
        XCTAssertTrue(singleSpread.waitForExistence(timeout: 5))
        singleSpread.tap()
        let facedown = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "蓋著的牌")).firstMatch
        XCTAssertTrue(facedown.waitForExistence(timeout: 12))
        settleTap(facedown)
        let seeResult = app.buttons["看看牌想說什麼"]
        XCTAssertTrue(seeResult.waitForExistence(timeout: 5))
        seeResult.tap()
        let tarotCTA = app.buttons["tarotMeditationCTA"]
        XCTAssertTrue(tarotCTA.waitForExistence(timeout: 5))
        scrollTap(tarotCTA, in: app)
        XCTAssertTrue(app.buttons["meditationStartButton"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any)["meditationSourceCard"].waitForExistence(timeout: 5),
                      "Tarot-derived setup should acknowledge the source")
        attach(name: "MD6-tarot-handoff-setup")
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
        let again = app.buttons["開始新的占卜"]
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

    /// Focused Tarot UX-fixes walkthrough (2026-07-17): floating
    /// header, three-card reading, longer sparkle shuffle, Result →
    /// Back revealed-state persistence (the critical bug), and the
    /// concise exit modal. Single-pass — not an end-to-end suite.
    func testTarotUXFixesWalkthrough() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()

        // Open Tarot from the Explore More entry; the setup header
        // floats (Back + X, no bar).
        let tarotEntry = app.descendants(matching: .any)["homeEntry-tarot"]
        XCTAssertTrue(tarotEntry.waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 3.0)
        var entryScrolls = 0
        while !tarotEntry.isHittable && entryScrolls < 6 {
            app.swipeUp()
            entryScrolls += 1
        }
        settleTap(tarotEntry)
        let next = app.buttons["下一步"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tarotBackButton"].exists)
        XCTAssertTrue(app.buttons["tarotExitButton"].exists)
        attach(name: "W1-setup-floating-header")
        next.tap()

        // Three-card spread → longer shuffle with blue sparkles.
        let threeSpread = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "三張牌")).firstMatch
        XCTAssertTrue(threeSpread.waitForExistence(timeout: 5))
        threeSpread.tap()
        Thread.sleep(forTimeInterval: 2.6)
        attach(name: "W2-shuffle-blue-sparkles")

        // Reveal all three cards, then record their identity labels
        // (name ＋ orientation) in layout order.
        let facedownQuery = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "蓋著的牌"))
        XCTAssertTrue(facedownQuery.firstMatch.waitForExistence(timeout: 14),
                      "Shuffle must resolve into face-down cards")
        for _ in 0..<3 {
            let card = facedownQuery.firstMatch
            XCTAssertTrue(card.waitForExistence(timeout: 8))
            settleTap(card)
        }
        let revealedQuery = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@ OR label CONTAINS %@", "正位", "逆位"))
        XCTAssertEqual(revealedQuery.count, 3, "All three cards face-up before the result")
        let labelsBefore = revealedQuery.allElementsBoundByIndex.map(\.label)

        // Open the Result and check the refined reading surfaces.
        let seeResult = app.buttons["看看牌想說什麼"]
        XCTAssertTrue(seeResult.waitForExistence(timeout: 5))
        seeResult.tap()
        XCTAssertTrue(app.descendants(matching: .any)["tarotSynthesis"]
            .waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["tarotTwinkoMessage"].exists)
        attach(name: "W3-result-hierarchy")

        // CRITICAL: Result → Back shows the exact same face-up cards —
        // same names, orientations, and order; never card backs again.
        settleTap(app.buttons["tarotBackButton"])
        XCTAssertTrue(app.staticTexts["這就是你本次抽到的牌"].waitForExistence(timeout: 5),
                      "Back re-enters the completed reveal, not a fresh one")
        XCTAssertEqual(facedownQuery.count, 0, "No card may revert to its back")
        let labelsAfter = revealedQuery.allElementsBoundByIndex.map(\.label)
        XCTAssertEqual(labelsAfter, labelsBefore,
                       "Same cards, orientations, and positions after Back")
        XCTAssertTrue(app.buttons["查看完整解讀"].exists)
        attach(name: "W4-revealed-after-back")

        // Exit confirmation: concise copy, Twinko-world modal actions.
        settleTap(app.buttons["tarotExitButton"])
        XCTAssertTrue(app.staticTexts["要先離開占卜嗎？"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["這次占卜會結束。"].exists)
        XCTAssertTrue(app.buttons["離開占卜"].exists)
        let stay = app.buttons["繼續占卜"]
        XCTAssertTrue(stay.exists)
        stay.tap()
        XCTAssertTrue(app.buttons["查看完整解讀"].waitForExistence(timeout: 5),
                      "Continue Reading stays on the completed reveal")
    }

    /// Focused Meditation UX-refinement walkthrough (2026-07-17):
    /// one personalized (Chat) pass through setup → preparation →
    /// player with countdown → exit modal → completion, plus a
    /// general-mode setup spot check and an English setup spot check.
    func testMeditationUXRefinementWalkthrough() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile", "-uiTestFastMeditation"]
        app.launch()

        // Contextual entry: explicit meditation request in Chat.
        XCTAssertTrue(app.buttons["tab-chat"].waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 3.0)
        app.buttons["tab-chat"].tap()
        settleTap(app.buttons["chatStarter-0"])
        let input = app.textFields["chatInputField"]
        XCTAssertTrue(input.waitForExistence(timeout: 6))
        settleTap(input)
        input.typeText("我想要冥想")
        settleTap(app.buttons["chatSendButton"])
        let accept = app.buttons["chatMeditationAccept"]
        XCTAssertTrue(accept.waitForExistence(timeout: 10))
        settleTap(accept)

        // Setup: context card, unified CTA, real recommendation tag,
        // concise subtitle — one screen, no scrolling expected.
        XCTAssertTrue(app.buttons["meditationStartButton"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any)["meditationSourceCard"].exists,
                      "Contextual entry shows the context card")
        XCTAssertTrue(app.staticTexts["為此刻的你，準備一段專屬冥想"].exists,
                      "Concise setup subtitle")
        XCTAssertTrue(app.buttons["開始冥想"].exists, "Unified main CTA")
        XCTAssertTrue(app.staticTexts["建議"].firstMatch.exists,
                      "Real recommendation shows its sublabel")
        attach(name: "M1-setup-contextual")

        // Preparation: ritual copy, visible for the minimum duration.
        Thread.sleep(forTimeInterval: 1.0)
        app.buttons["meditationStartButton"].tap()
        let preparationTapAt = Date()
        let prepLine = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "收集此刻的星光")).firstMatch
        XCTAssertTrue(prepLine.waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["為此刻的你，準備一段溫柔的旅程"].exists,
                      "Secondary ritual line")
        attach(name: "M2-preparation")

        // Active player: countdown ring time, ticking via the existing
        // playback clock (fast ticks compress wall time only). Mock
        // generation is instant, so the session arriving no earlier
        // than ~2.6 s after the tap proves the minimum hold works.
        let pauseResume = app.buttons["meditationPauseResume"]
        XCTAssertTrue(pauseResume.waitForExistence(timeout: 10))
        XCTAssertGreaterThanOrEqual(Date().timeIntervalSince(preparationTapAt), 2.6,
            "Preparation respects its minimum display duration")
        let timeLabel = app.staticTexts.matching(
            NSPredicate(format: "label MATCHES %@", "\\d:\\d{2}")).firstMatch
        XCTAssertTrue(timeLabel.waitForExistence(timeout: 4), "Ring remaining time visible")
        let firstValue = timeLabel.label
        attach(name: "M3-player-countdown")
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertNotEqual(timeLabel.label, firstValue,
                          "Countdown advances with the existing session clock")

        // Exit modal: concise reassuring copy; continue resumes.
        // Pause first (direct element taps — coordinate taps resolve
        // stale frames on this animated screen) so the compressed
        // fast-tick session cannot complete underneath the modal.
        pauseResume.tap()
        Thread.sleep(forTimeInterval: 0.6)
        app.buttons["meditationBackButton"].tap()
        XCTAssertTrue(app.staticTexts["要先結束冥想嗎？"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["準備好時，隨時都能再回來。"].exists)
        let stay = app.buttons["繼續冥想"]
        XCTAssertTrue(stay.exists)
        stay.tap()
        XCTAssertTrue(pauseResume.waitForExistence(timeout: 4),
                      "Continue returns to the running session")

        // Completion: floating Twinko scene, one roomy feeling choice.
        let done = app.buttons["meditationDoneButton"]
        XCTAssertTrue(done.waitForExistence(timeout: 30), "Session completes on its own")
        let calmer = app.buttons["meditationMood-calmer"]
        XCTAssertTrue(calmer.exists)
        settleTap(calmer)
        XCTAssertTrue(calmer.isSelected, "Selected feeling announces its state")
        attach(name: "M4-completion-selected")
        settleTap(done)

        // General-mode spot check: no context card, no reserved space.
        XCTAssertTrue(app.buttons["chatBackButton"].waitForExistence(timeout: 6))
        settleTap(app.buttons["chatBackButton"])
        XCTAssertTrue(app.buttons["tab-explore"].waitForExistence(timeout: 8))
        settleTap(app.buttons["tab-explore"])
        XCTAssertTrue(app.descendants(matching: .any)["explore-meditation"]
            .waitForExistence(timeout: 5))
        settleTap(app.descendants(matching: .any)["explore-meditation"])
        XCTAssertTrue(app.buttons["meditationStartButton"].waitForExistence(timeout: 6))
        XCTAssertFalse(app.descendants(matching: .any)["meditationSourceCard"].exists,
                       "General entry shows no context card")
        XCTAssertFalse(app.staticTexts["建議"].exists,
                       "General entry has no recommendation tags")
        settleTap(app.buttons["meditationBackButton"])

        // Second-locale spot check on the setup state only.
        XCTAssertTrue(app.buttons["tab-myplanet"].waitForExistence(timeout: 5))
        app.buttons["tab-myplanet"].tap()
        XCTAssertTrue(app.buttons["sheetSettingsRow"].waitForExistence(timeout: 5))
        scrollTap(app.buttons["sheetSettingsRow"], in: app)
        XCTAssertTrue(app.buttons["language-en"].waitForExistence(timeout: 5))
        settleTap(app.buttons["language-en"])
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertTrue(app.buttons["tab-explore"].waitForExistence(timeout: 8))
        settleTap(app.buttons["tab-explore"])
        XCTAssertTrue(app.descendants(matching: .any)["explore-meditation"]
            .waitForExistence(timeout: 5))
        settleTap(app.descendants(matching: .any)["explore-meditation"])
        XCTAssertTrue(app.buttons["meditationStartButton"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.staticTexts["A meditation made for this moment."].exists,
                      "English subtitle, no mixed language")
        XCTAssertTrue(app.buttons["Begin Meditation"].exists, "English unified CTA")
    }

    /// Focused Chat UX-refinement walkthrough (2026-07-17): landing
    /// without scrolling or a header bar, glass prompt cards, send
    /// states, star orb action, dock hiding in an active conversation,
    /// keyboard round-trip, Back restoring the landing + dock, and an
    /// EN-locale landing wrap check.
    func testChatUXRefinementWalkthrough() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()

        // Landing: dock visible, three prompt cards, disabled send.
        XCTAssertTrue(app.buttons["tab-chat"].waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 3.0)
        app.buttons["tab-chat"].tap()
        XCTAssertTrue(app.staticTexts["我在這裡陪你"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tab-home"].exists, "Dock stays on the landing")
        for index in 0..<3 {
            XCTAssertTrue(app.buttons["chatStarter-\(index)"].exists, "Card \(index)")
        }
        let send = app.buttons["chatSendButton"]
        XCTAssertTrue(send.exists)
        XCTAssertFalse(send.isEnabled, "Empty draft disables send")
        attach(name: "C1-landing")

        // Star orb: existing menu action still opens, then closes.
        settleTap(app.buttons["chatMenuButton"])
        XCTAssertTrue(app.buttons["menuNewChatRow"].waitForExistence(timeout: 4))
        settleTap(app.buttons["chatMenuButton"])
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertFalse(app.buttons["menuNewChatRow"].exists)

        // Enabled send state with text present.
        let input = app.textFields["chatInputField"]
        settleTap(input)
        input.typeText("你好")
        XCTAssertTrue(send.isEnabled, "Text enables send")
        attach(name: "C2-send-enabled")
        app.swipeDown()
        Thread.sleep(forTimeInterval: 1.2)

        // Active conversation via a prompt card: dock hides, Back
        // appears; send one message; keyboard round-trip. Direct
        // element tap — the landing reflows after keyboard dismissal,
        // so a coordinate tap could aim at a stale frame.
        let firstStarter = app.buttons["chatStarter-0"]
        XCTAssertTrue(firstStarter.waitForExistence(timeout: 4))
        firstStarter.tap()
        XCTAssertTrue(app.buttons["chatBackButton"].waitForExistence(timeout: 6))
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertFalse(app.buttons["tab-home"].exists,
                       "Active conversation hides the dock")
        settleTap(input)
        input.typeText("測試訊息")
        send.tap()
        XCTAssertTrue(app.staticTexts["測試訊息"].waitForExistence(timeout: 6),
                      "Sending still works")
        settleTap(input)                    // keyboard up once more
        app.swipeDown()                     // dismiss
        Thread.sleep(forTimeInterval: 0.8)
        XCTAssertTrue(input.exists, "Input remains after keyboard dismissal")
        XCTAssertFalse(app.buttons["tab-home"].exists,
                       "Keyboard round-trip must not restore the dock")
        attach(name: "C3-conversation-immersive")

        // Back: landing returns with the dock restored.
        settleTap(app.buttons["chatBackButton"])
        XCTAssertTrue(app.staticTexts["我在這裡陪你"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tab-home"].waitForExistence(timeout: 4),
                      "Dock restored on the landing")

        // EN-locale landing spot check lives in
        // testChatLandingEnglishLocaleSpotCheck (own launch via the
        // -uiTestEnglish hook — in-app settings navigation proved
        // flaky under automation here).
    }

    /// Second-locale spot check for the refined Chat landing only:
    /// English headline and prompt-card wrapping, launched directly in
    /// English via the supported test hook.
    func testChatLandingEnglishLocaleSpotCheck() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile", "-uiTestEnglish"]
        app.launch()
        XCTAssertTrue(app.buttons["tab-chat"].waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 3.0)
        app.buttons["tab-chat"].tap()
        XCTAssertTrue(app.staticTexts["I'm here with you"].waitForExistence(timeout: 6),
                      "EN landing headline")
        for index in 0..<3 {
            XCTAssertTrue(app.buttons["chatStarter-\(index)"].exists,
                          "EN prompt card \(index)")
        }
        attach(name: "C4-landing-english")
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

    /// Focused Home redesign walkthrough (founder/CPO decisions
    /// 2026-07-16): greeting + check-in progressive disclosure,
    /// recommendation, bottom navigation, and Settings vs My Planet.
    func testHomeRedesignWalkthrough() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()

        // Initial Home: greeting, mood question, four tabs, Settings gear
        let firstMood = app.descendants(matching: .any)["mood-happy"]
        XCTAssertTrue(firstMood.waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["homeSettingsButton"].exists,
                       "No Settings icon on Home — Settings lives in My Planet")
        XCTAssertTrue(app.buttons["tab-home"].exists)
        XCTAssertTrue(app.buttons["tab-chat"].exists)
        XCTAssertTrue(app.buttons["tab-explore"].exists)
        XCTAssertTrue(app.buttons["tab-myplanet"].exists)
        attach(name: "H1-home-initial")

        // Progressive disclosure: mood → need question appears
        // (long settle: the very first tap after launch can be dropped
        // while the shell's tab stacks finish attaching)
        Thread.sleep(forTimeInterval: 3.0)
        let moodOrb = app.buttons["mood-anxious"]
        moodOrb.tap()
        if !app.buttons["need-ground"].waitForExistence(timeout: 3) {
            moodOrb.tap()   // one retry for a dropped first tap
        }
        let needChip = app.buttons["need-ground"]
        XCTAssertTrue(needChip.waitForExistence(timeout: 5))
        attach(name: "H2-mood-selected-need-revealed")

        // Need → collapsed summary + one recommendation
        Thread.sleep(forTimeInterval: 0.8)
        needChip.tap()
        XCTAssertTrue(app.descendants(matching: .any)["checkInSummary"]
            .waitForExistence(timeout: 5))
        let recommendation = app.descendants(matching: .any)["homeRecommendationCard"]
        XCTAssertTrue(recommendation.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["homePrimaryAction"].exists)
        attach(name: "H3-checkin-complete-recommendation")

        // Settings is reached through My Planet (no Home gear).
        settleTap(app.buttons["tab-myplanet"])
        XCTAssertTrue(app.buttons["sheetProfileRow"].waitForExistence(timeout: 5))
        settleTap(app.buttons["sheetSettingsRow"])
        XCTAssertTrue(app.buttons["language-zh-Hant"].waitForExistence(timeout: 5))
        attach(name: "H4-settings-station")
        settleTap(app.navigationBars.buttons.firstMatch)

        // Back to Home: check-in stays collapsed (no re-ask same day)
        settleTap(app.buttons["tab-home"])
        XCTAssertTrue(app.descendants(matching: .any)["checkInSummary"]
            .waitForExistence(timeout: 5))
        XCTAssertFalse(app.descendants(matching: .any)["mood-happy"].exists,
                       "Same-day check-in is not re-asked after navigating away")
    }

    /// Focused Tarot redesign walkthrough (founder/CPO decisions
    /// 2026-07-16): immersive shell, six-topic setup, equal spreads,
    /// vortex convergence, reveal glow, restructured result, one
    /// Guidance Card, exits, and edge-swipe back on a pushed page.
    func testTarotRedesignWalkthrough() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()

        // Native edge-swipe back on one other pushed page (Meditation).
        XCTAssertTrue(app.buttons["tab-explore"].waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 3.0)
        app.buttons["tab-explore"].tap()
        XCTAssertTrue(app.buttons["explore-meditate"].waitForExistence(timeout: 5))
        app.buttons["explore-meditate"].tap()
        Thread.sleep(forTimeInterval: 2.0)
        let edge = app.coordinate(withNormalizedOffset: CGVector(dx: 0.002, dy: 0.5))
        edge.press(forDuration: 0.05,
                   thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5)))
        XCTAssertTrue(app.buttons["explore-tarot"].waitForExistence(timeout: 5),
                      "Edge swipe pops the pushed Meditation page back to Explore")

        // Enter Tarot: immersive — the shell tab bar disappears.
        app.buttons["explore-tarot"].tap()
        let firstTopic = app.buttons["tarotTopic-relationships"]
        XCTAssertTrue(firstTopic.waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 0.6)
        XCTAssertFalse(app.buttons["tab-home"].exists,
                       "Bottom navigation is hidden throughout Tarot")
        for topic in ["relationships", "career", "finance", "growth", "lifePath", "other"] {
            XCTAssertTrue(app.buttons["tarotTopic-\(topic)"].exists, topic)
        }
        attach(name: "T1-six-topic-setup")

        // Topic-specific suggestions.
        settleTap(app.buttons["tarotTopic-finance"])
        XCTAssertTrue(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "金錢")).firstMatch
            .waitForExistence(timeout: 4), "Finance-specific suggestion appears")
        scrollTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "下一步")).firstMatch, in: app)

        // Spread selection: both options present and equal-sized.
        let three = app.buttons["tarotSpread-three"]
        XCTAssertTrue(three.waitForExistence(timeout: 5))
        let single = app.buttons["tarotSpread-single"]
        XCTAssertEqual(single.frame.size.width, three.frame.size.width, accuracy: 2)
        XCTAssertEqual(single.frame.size.height, three.frame.size.height, accuracy: 2)
        attach(name: "T2-equal-spread-cards")

        // Three Cards → vortex converges into exactly three cards.
        settleTap(three)
        Thread.sleep(forTimeInterval: 3.0)
        attach(name: "T3-vortex-settled-cards")
        Thread.sleep(forTimeInterval: 1.6)
        let faceDown = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "蓋著的牌"))
        XCTAssertEqual(faceDown.count, 3, "Vortex converges into exactly three cards")

        // Partial reveal: instruction updates, revealed card glows.
        settleTap(faceDown.firstMatch)
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "繼續翻開下一張牌")).firstMatch
            .waitForExistence(timeout: 4))
        settleTap(faceDown.firstMatch)
        settleTap(faceDown.firstMatch)
        scrollTap(app.buttons["tarotSeeReading"], in: app)

        // Result: starts directly with full interpretations.
        XCTAssertTrue(app.descendants(matching: .any)["tarotSynthesis"]
            .waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "展開完整解讀")).firstMatch.exists,
            "No expand controls — full interpretations by default")
        XCTAssertFalse(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "小小的反思")).firstMatch.exists,
            "No per-card mini reflections")

        // Back from Result → completed reveal: faces stay revealed,
        // no card backs, no shuffle replay; View Full Reading returns.
        settleTap(app.buttons["tarotBackButton"])
        let viewFullReading = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "查看完整解讀")).firstMatch
        XCTAssertTrue(viewFullReading.waitForExistence(timeout: 5),
                      "Completed reveal state offers View Full Reading")
        XCTAssertEqual(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "蓋著的牌")).count, 0,
            "No card backs after returning from Result")
        settleTap(viewFullReading)
        XCTAssertTrue(app.descendants(matching: .any)["tarotSynthesis"]
            .waitForExistence(timeout: 5), "Back at the Result")

        // One Guidance Card only; Save stays, Share Result is gone.
        scrollTap(app.buttons["tarotGuidanceAccept"], in: app)
        Thread.sleep(forTimeInterval: 4.6)
        let guidanceCard = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "蓋著的牌")).firstMatch
        settleTap(guidanceCard)
        scrollTap(app.buttons["tarotSeeReading"], in: app)
        XCTAssertTrue(app.descendants(matching: .any)["tarotTwinkoMessage"]
            .waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["tarotGuidanceAccept"].exists,
                       "Guidance Card can be drawn only once")
        XCTAssertTrue(app.descendants(matching: .any)["tarotSynthesis"].exists,
                      "整體來看 present for the expanded reading")
        attach(name: "T4-post-guidance-expanded-result")
        XCTAssertTrue(app.buttons["tarotSaveCardButton"].waitForExistence(timeout: 4))
        XCTAssertFalse(app.buttons["tarotShareButton"].exists,
                       "Result-page Share Result is removed")
        XCTAssertTrue(app.buttons["tarotMeditationCTA"].exists,
                      "Merged personalized Meditation section")

        // Summary Card V2 reflects the current expanded reading state,
        // previews uncropped, with three distinct actions.
        scrollTap(app.buttons["tarotSaveCardButton"], in: app)
        XCTAssertTrue(app.buttons["tarotCardSaveToPhotos"].waitForExistence(timeout: 6),
                      "Save to Photos is its own primary action")
        XCTAssertTrue(app.buttons["tarotCardShare"].exists, "Share is a distinct action")
        XCTAssertTrue(app.buttons["tarotCardClose"].exists, "Close is a distinct action")
        attach(name: "T5-summary-card-expanded")
        settleTap(app.buttons["tarotCardClose"])

        // Exit actions + single short disclaimer at the bottom.
        var attempts = 0
        let newReading = app.buttons["tarotStartNewReading"]
        while !newReading.isHittable && attempts < 8 { app.swipeUp(); attempts += 1 }
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "內容僅供反思與娛樂")).firstMatch.exists)

        // Start a New Reading → back to topic setup, still immersive.
        settleTap(newReading)
        XCTAssertTrue(firstTopic.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["tab-home"].exists,
                       "New reading stays inside immersive Tarot")

        // Quick single-card reading to verify Back to Home.
        scrollTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "下一步")).firstMatch, in: app)
        XCTAssertTrue(app.buttons["tarotSpread-single"].waitForExistence(timeout: 5))
        settleTap(app.buttons["tarotSpread-single"])
        Thread.sleep(forTimeInterval: 4.6)
        settleTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "蓋著的牌")).firstMatch)
        scrollTap(app.buttons["tarotSeeReading"], in: app)
        XCTAssertTrue(app.descendants(matching: .any)["tarotTwinkoMessage"]
            .waitForExistence(timeout: 5))
        scrollTap(app.buttons["tarotBackHome"], in: app)
        XCTAssertTrue(app.buttons["homeSettingsButton"].waitForExistence(timeout: 6),
                      "Back to Home lands on the Home root")
        XCTAssertTrue(app.buttons["tab-home"].waitForExistence(timeout: 4),
                      "Bottom navigation is restored on Home")
    }

    /// Focused Chat polish walkthrough (2026-07-17): landing without
    /// title/overlay, localized welcome + prompts, EN conversation with
    /// EN reply, active-conversation nav hiding, History, delete dialog.
    func testChatPolishWalkthrough() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()

        // zh-Hant landing: welcome copy, prompts, nav visible, no title.
        XCTAssertTrue(app.buttons["tab-chat"].waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 3.0)
        app.buttons["tab-chat"].tap()
        XCTAssertTrue(app.staticTexts["我在這裡陪你"].waitForExistence(timeout: 5),
                      "Approved zh welcome headline, no punctuation")
        // (The bottom tab's 聊天 label remains; only the page title is
        // gone — verified visually via the C1 screenshot.)
        XCTAssertTrue(app.buttons["chatStarter-0"].exists)
        XCTAssertTrue(app.buttons["tab-home"].exists, "Bottom nav visible on landing")
        attach(name: "C1-zh-landing")

        // Switch to English via My Planet settings (no Home gear).
        app.buttons["tab-myplanet"].tap()
        Thread.sleep(forTimeInterval: 1.0)
        settleTap(app.buttons["sheetSettingsRow"])
        XCTAssertTrue(app.buttons["language-en"].waitForExistence(timeout: 5))
        settleTap(app.buttons["language-en"])
        Thread.sleep(forTimeInterval: 0.6)
        app.buttons["tab-chat"].tap()
        XCTAssertTrue(app.staticTexts["I'm here with you"].waitForExistence(timeout: 5),
                      "Approved EN welcome headline")
        XCTAssertTrue(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "under some pressure")).firstMatch.exists,
            "EN prompt shown without clipping")
        attach(name: "C2-en-landing")

        // Start an EN conversation from a quick prompt: prompt becomes
        // the first message, reply is English, bottom nav hides.
        settleTap(app.buttons["chatStarter-0"])
        XCTAssertTrue(app.staticTexts["I want to talk about my day"]
            .waitForExistence(timeout: 5), "Prompt is the first user message")
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "How has your day been")).firstMatch
            .waitForExistence(timeout: 6), "New Twinko reply is English")
        Thread.sleep(forTimeInterval: 0.6)
        XCTAssertFalse(app.buttons["tab-home"].exists,
                       "Active conversation hides the bottom navigation")
        attach(name: "C3-en-active-conversation")

        // Back returns to the landing and restores the bottom nav.
        settleTap(app.buttons["chatBackButton"])
        XCTAssertTrue(app.staticTexts["I'm here with you"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tab-home"].waitForExistence(timeout: 4),
                      "Bottom navigation restored on Chat landing")

        // History: refreshed rows, localized title.
        settleTap(app.buttons["chatMenuButton"])
        XCTAssertTrue(app.buttons["menuHistoryRow"].waitForExistence(timeout: 4))
        settleTap(app.buttons["menuHistoryRow"])
        XCTAssertTrue(app.staticTexts["History"].waitForExistence(timeout: 5),
                      "Localized History title preserved")
        attach(name: "C4-history")

        // Delete dialog: one concise sentence, localized buttons.
        settleTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "More options")).firstMatch)
        settleTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "Delete")).firstMatch)
        XCTAssertTrue(app.staticTexts["Delete this conversation permanently?"]
            .waitForExistence(timeout: 5), "Single-sentence confirmation")
        XCTAssertFalse(app.staticTexts["This can't be undone."].exists,
                       "No separate warning subtitle")
        attach(name: "C5-delete-dialog")
        settleTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "Cancel")).firstMatch)
    }

    /// Focused Meditation walkthrough (2026-07-17): general + Chat +
    /// Tarot entries, auto-progressing session with pause/resume,
    /// branded exit modals, completion reflection, Tarot X.
    /// -uiTestFastMeditation compresses the session clock (40 ms ticks)
    /// without changing the session math.
    func testMeditationImmersiveWalkthrough() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile", "-uiTestFastMeditation"]
        app.launch()

        // --- General entry from Explore: no context card, nav hidden.
        XCTAssertTrue(app.buttons["tab-explore"].waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 3.0)
        app.buttons["tab-explore"].tap()
        XCTAssertTrue(app.buttons["explore-meditate"].waitForExistence(timeout: 5))
        app.buttons["explore-meditate"].tap()
        XCTAssertTrue(app.buttons["meditationStartButton"].waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 0.8)
        XCTAssertFalse(app.descendants(matching: .any)["meditationSourceCard"].exists,
                       "General entry has no source context card")
        XCTAssertFalse(app.buttons["tab-home"].exists,
                       "Bottom navigation hidden throughout Meditation")
        XCTAssertTrue(app.buttons["meditationFocus-sleep"].exists)
        attach(name: "M1-general-setup")

        // Start a three-minute session (fast clock in UI tests).
        settleTap(app.buttons["meditationDuration-3"])
        settleTap(app.buttons["meditationStartButton"])
        let pauseResume = app.buttons["meditationPauseResume"]
        XCTAssertTrue(pauseResume.waitForExistence(timeout: 8),
                      "Session begins after generation")
        attach(name: "M2-active-session")

        // Pause / resume once.
        settleTap(pauseResume)
        Thread.sleep(forTimeInterval: 0.6)
        settleTap(pauseResume)

        // Exit once: branded modal appears; continue resumes.
        settleTap(app.buttons["meditationBackButton"])
        XCTAssertTrue(app.staticTexts["要先結束這段冥想嗎？"].waitForExistence(timeout: 4),
                      "Branded Meditation exit modal")
        attach(name: "M3-meditation-exit-modal")
        settleTap(app.buttons["繼續冥想"])

        // Auto progression completes on its own (fast clock ≈ 8 s).
        XCTAssertTrue(app.staticTexts["你剛剛為自己留了一點空間"]
            .waitForExistence(timeout: 30),
            "Session auto-progresses to completion without Continue taps")
        settleTap(app.buttons["meditationMood-calmer"])
        settleTap(app.buttons["meditationDoneButton"])
        XCTAssertTrue(app.buttons["tab-home"].waitForExistence(timeout: 5),
                      "Bottom navigation restored after leaving Meditation")

        // --- Chat-derived personalized entry.
        app.buttons["tab-chat"].tap()
        XCTAssertTrue(app.buttons["chatStarter-1"].waitForExistence(timeout: 5))
        settleTap(app.buttons["chatStarter-1"])
        let accept = app.buttons["chatMeditationAccept"]
        XCTAssertTrue(accept.waitForExistence(timeout: 8),
                      "Meditation offer follows the pressure prompt")
        settleTap(accept)
        XCTAssertTrue(app.descendants(matching: .any)["meditationSourceCard"]
            .waitForExistence(timeout: 5), "Chat context card on personalized setup")
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "根據你剛剛的聊天")).firstMatch.exists)
        XCTAssertTrue(app.buttons["meditationUseGeneral"].exists,
                      "Quiet general-mode switch available")
        XCTAssertFalse(app.buttons["tab-home"].exists,
                       "Bottom navigation hidden on Chat-derived setup too")
        attach(name: "M4-chat-personalized-setup")
        settleTap(app.buttons["meditationBackButton"])
        XCTAssertTrue(app.buttons["chatBackButton"].waitForExistence(timeout: 5))
        settleTap(app.buttons["chatBackButton"])

        // --- Tarot-derived personalized entry + Tarot X confirmation.
        app.buttons["tab-explore"].tap()
        XCTAssertTrue(app.buttons["explore-tarot"].waitForExistence(timeout: 5))
        app.buttons["explore-tarot"].tap()
        XCTAssertTrue(app.buttons["tarotTopic-relationships"].waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 0.8)
        scrollTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "下一步")).firstMatch, in: app)
        XCTAssertTrue(app.buttons["tarotSpread-single"].waitForExistence(timeout: 5))
        settleTap(app.buttons["tarotSpread-single"])
        Thread.sleep(forTimeInterval: 4.6)
        settleTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "蓋著的牌")).firstMatch)
        scrollTap(app.buttons["tarotSeeReading"], in: app)
        XCTAssertTrue(app.descendants(matching: .any)["tarotTwinkoMessage"]
            .waitForExistence(timeout: 5))
        scrollTap(app.buttons["tarotMeditationCTA"], in: app)
        XCTAssertTrue(app.descendants(matching: .any)["meditationSourceCard"]
            .waitForExistence(timeout: 5), "Tarot context card on personalized setup")
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "根據你剛剛的塔羅解讀")).firstMatch.exists)
        settleTap(app.buttons["meditationBackButton"])

        // In-progress Tarot X: branded confirmation, then exit to the
        // original source (Explore) with the tab bar restored.
        XCTAssertTrue(app.buttons["tarotExitButton"].waitForExistence(timeout: 5))
        settleTap(app.buttons["tarotExitButton"])
        XCTAssertTrue(app.staticTexts["要先離開這次占卜嗎？"].waitForExistence(timeout: 4),
                      "Branded Tarot exit confirmation after meaningful progress")
        attach(name: "M5-tarot-exit-modal")
        settleTap(app.buttons["離開占卜"])
        XCTAssertTrue(app.buttons["explore-tarot"].waitForExistence(timeout: 5),
                      "Tarot X returns to its original source (Explore)")
        XCTAssertTrue(app.buttons["tab-home"].waitForExistence(timeout: 4),
                      "Bottom navigation restored after leaving Tarot")
    }

    /// Smallest targeted check for the derived tab-visibility change:
    /// an in-progress Tarot X exit restores the bar at its source.
    func testTarotExitRestoresTabBar() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()
        XCTAssertTrue(app.buttons["tab-explore"].waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 3.0)
        app.buttons["tab-explore"].tap()
        XCTAssertTrue(app.buttons["explore-tarot"].waitForExistence(timeout: 5))
        app.buttons["explore-tarot"].tap()
        XCTAssertTrue(app.buttons["tarotTopic-relationships"].waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 0.8)
        XCTAssertFalse(app.buttons["tab-home"].exists, "Tarot hides the tab bar")
        scrollTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "下一步")).firstMatch, in: app)
        XCTAssertTrue(app.buttons["tarotSpread-single"].waitForExistence(timeout: 5))
        settleTap(app.buttons["tarotSpread-single"])
        Thread.sleep(forTimeInterval: 5.0)
        // In-progress: X requires the branded confirmation, then exits
        // to the original source with the tab bar restored.
        settleTap(app.buttons["tarotExitButton"])
        XCTAssertTrue(app.staticTexts["要先離開這次占卜嗎？"].waitForExistence(timeout: 4))
        settleTap(app.buttons["離開占卜"])
        XCTAssertTrue(app.buttons["explore-tarot"].waitForExistence(timeout: 5),
                      "X returns to Explore")
        XCTAssertTrue(app.buttons["tab-home"].waitForExistence(timeout: 4),
                      "Tab bar restored after leaving Tarot")
    }

    /// Focused companion-universe walkthrough (2026-07-17): one-screen
    /// Home with journey, cosmic Explore map, My Planet hubs, floating
    /// dock, and second-locale spot check.
    func testCompanionUniverseWalkthrough() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()

        // --- Home: initial check-in, complete it, journey appears.
        let firstMood = app.descendants(matching: .any)["mood-calm"]
        XCTAssertTrue(firstMood.waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 3.0)
        XCTAssertFalse(app.buttons["homeSettingsButton"].exists,
                       "No Settings icon on Home")
        XCTAssertTrue(app.buttons["tab-home"].exists, "Floating dock visible")
        settleTap(app.descendants(matching: .any)["mood-calm"])
        let need = app.descendants(matching: .any)["need-direction"]
        XCTAssertTrue(need.waitForExistence(timeout: 4))
        settleTap(need)
        XCTAssertTrue(app.descendants(matching: .any)["checkInSummary"]
            .waitForExistence(timeout: 5), "Check-in collapses after completion")
        XCTAssertTrue(app.descendants(matching: .any)["homePrimaryAction"].exists,
                      "One personalized recommendation")
        XCTAssertTrue(app.descendants(matching: .any)["journeyStep-1"].exists
                      && app.descendants(matching: .any)["journeyStep-3"].exists,
                      "Three-step Companion Journey")
        XCTAssertTrue(app.descendants(matching: .any)["homeEntry-tarot"].exists,
                      "Explore More entries present")
        attach(name: "U1-home-completed")

        // Edit reopens the selectors, then completes again.
        settleTap(app.descendants(matching: .any)["checkInEditButton"])
        if !app.descendants(matching: .any)["need-direction"].waitForExistence(timeout: 3) {
            settleTap(app.descendants(matching: .any)["checkInEditButton"]) // dropped-tap retry
        }
        XCTAssertTrue(app.descendants(matching: .any)["need-direction"]
            .waitForExistence(timeout: 4), "Edit re-expands the check-in")
        settleTap(app.descendants(matching: .any)["need-direction"])
        XCTAssertTrue(app.descendants(matching: .any)["checkInSummary"]
            .waitForExistence(timeout: 4))

        // --- Explore: cosmic map, one real planet, Activities.
        app.buttons["tab-explore"].tap()
        XCTAssertTrue(app.staticTexts["探索宇宙"].waitForExistence(timeout: 5))
        for planet in ["tarot", "horoscope", "meditation", "music", "activities"] {
            XCTAssertTrue(app.descendants(matching: .any)["explore-\(planet)"].exists,
                          planet)
        }
        attach(name: "U2-explore-map")
        settleTap(app.descendants(matching: .any)["explore-meditation"])
        XCTAssertTrue(app.buttons["meditationStartButton"].waitForExistence(timeout: 6))
        Thread.sleep(forTimeInterval: 0.8)
        XCTAssertFalse(app.buttons["tab-home"].exists,
                       "Immersive flow hides the dock")
        settleTap(app.buttons["meditationBackButton"])
        XCTAssertTrue(app.staticTexts["探索宇宙"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tab-home"].waitForExistence(timeout: 4),
                      "Dock restored on the Explore map")
        settleTap(app.descendants(matching: .any)["explore-activities"])
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "附近的療癒活動")).firstMatch
            .waitForExistence(timeout: 5), "Honest Activities coming-soon state")
        settleTap(app.buttons["activitiesBackButton"])
        XCTAssertTrue(app.staticTexts["探索宇宙"].waitForExistence(timeout: 5))

        // --- My Planet: hero, six hubs, Profile, Settings, one record hub.
        app.buttons["tab-myplanet"].tap()
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "小雅 的星球")).firstMatch
            .waitForExistence(timeout: 5), "Personal planet hero")
        for hub in ["hubJournal", "hubMeditation", "hubTarot", "hubCards",
                    "sheetProfileRow", "sheetSettingsRow"] {
            XCTAssertTrue(app.descendants(matching: .any)[hub].exists, hub)
        }
        attach(name: "U3-my-planet-hubs")
        settleTap(app.buttons["sheetProfileRow"])
        XCTAssertTrue(app.buttons["profileCard-name"].waitForExistence(timeout: 5),
                      "Existing Profile destination")
        settleTap(app.navigationBars.buttons.firstMatch)
        XCTAssertTrue(app.buttons["sheetSettingsRow"].waitForExistence(timeout: 5))
        scrollTap(app.buttons["hubJournal"], in: app)
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "還在建造中")).firstMatch
            .waitForExistence(timeout: 5), "Honest coming-soon record station")
        settleTap(app.navigationBars.buttons.firstMatch)

    }

    /// Second-locale top-level spot check (own launch: the locale
    /// switch re-renders every tab, which is cleanest from a fresh
    /// session).
    func testCompanionUniverseEnglishLocale() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()
        XCTAssertTrue(app.buttons["tab-myplanet"].waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 3.0)

        // Complete a check-in first (zh), so the EN summary state shows.
        settleTap(app.descendants(matching: .any)["mood-calm"])
        settleTap(app.descendants(matching: .any)["need-direction"])
        XCTAssertTrue(app.descendants(matching: .any)["checkInSummary"]
            .waitForExistence(timeout: 5))

        app.buttons["tab-myplanet"].tap()
        XCTAssertTrue(app.buttons["sheetSettingsRow"].waitForExistence(timeout: 5))
        scrollTap(app.buttons["sheetSettingsRow"], in: app)
        XCTAssertTrue(app.buttons["language-en"].waitForExistence(timeout: 5))
        settleTap(app.buttons["language-en"])
        Thread.sleep(forTimeInterval: 1.0)
        settleTap(app.buttons["tab-home"])
        XCTAssertTrue(app.staticTexts["Today's Companion Journey"]
            .waitForExistence(timeout: 6), "EN journey title, no mixed language")
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "Feeling today")).firstMatch.exists,
            "EN check-in summary")
        attach(name: "U4-home-english")
    }

    /// Focused Chat/Horoscope/Tarot polish walkthrough (2026-07-17).
    func testThreeFeaturePolishWalkthrough() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset", "-uiTestSeedProfile"]
        app.launch()

        // --- Chat landing: no overlay, prompts, tab visible.
        XCTAssertTrue(app.buttons["tab-chat"].waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 3.0)
        app.buttons["tab-chat"].tap()
        XCTAssertTrue(app.staticTexts["我在這裡陪你"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tab-home"].exists, "Landing keeps the tab bar")
        attach(name: "P1-chat-landing")

        // Active conversation: hidden tab bar + stable keyboard.
        settleTap(app.buttons["chatStarter-0"])
        XCTAssertTrue(app.staticTexts["我想聊聊今天發生的事"].waitForExistence(timeout: 6))
        Thread.sleep(forTimeInterval: 1.2)
        XCTAssertFalse(app.buttons["tab-home"].exists, "Conversation hides the tab bar")
        settleTap(app.textFields["chatInputField"])
        Thread.sleep(forTimeInterval: 1.2)
        XCTAssertTrue(app.buttons["chatSendButton"].exists,
                      "Composer/send stay present with the keyboard open")
        attach(name: "P2-chat-conversation-keyboard")
        app.swipeDown()
        Thread.sleep(forTimeInterval: 0.8)

        // History + delete modal typography.
        settleTap(app.buttons["chatBackButton"])
        XCTAssertTrue(app.buttons["tab-home"].waitForExistence(timeout: 4))
        settleTap(app.buttons["chatMenuButton"])
        settleTap(app.buttons["menuHistoryRow"])
        XCTAssertTrue(app.staticTexts["聊天紀錄"].waitForExistence(timeout: 5))
        settleTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "更多選項")).firstMatch)
        settleTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "刪除")).firstMatch)
        XCTAssertTrue(app.staticTexts["確定要永久刪除這段對話嗎？"]
            .waitForExistence(timeout: 4))
        attach(name: "P3-chat-delete-modal")
        settleTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "取消")).firstMatch)
        settleTap(app.buttons["historyBackButton"])

        // --- Horoscope detail: hidden tab bar, grape CTA, disclaimer.
        app.buttons["tab-explore"].tap()
        XCTAssertTrue(app.buttons["explore-zodiac"].waitForExistence(timeout: 5))
        app.buttons["explore-zodiac"].tap()
        XCTAssertTrue(app.buttons["horoscopeSaveCardButton"].waitForExistence(timeout: 8))
        Thread.sleep(forTimeInterval: 0.8)
        XCTAssertFalse(app.buttons["tab-home"].exists,
                       "Horoscope detail hides the tab bar")
        var attempts = 0
        while !app.staticTexts["內容僅供反思與娛樂"].isHittable && attempts < 8 {
            app.swipeUp(); attempts += 1
        }
        XCTAssertTrue(app.staticTexts["內容僅供反思與娛樂"].exists,
                      "Approved disclaimer wording")
        attach(name: "P4-horoscope-cta-hierarchy")
        settleTap(app.buttons["horoscopeBackButton"])
        XCTAssertTrue(app.buttons["tab-home"].waitForExistence(timeout: 4),
                      "Tab bar restored on the outer entry")

        // --- Tarot: Result → Back keeps revealed faces + opacity check.
        app.buttons["explore-tarot"].tap()
        XCTAssertTrue(app.buttons["tarotTopic-relationships"].waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 0.8)
        scrollTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "下一步")).firstMatch, in: app)
        XCTAssertTrue(app.buttons["tarotSpread-single"].waitForExistence(timeout: 5))
        settleTap(app.buttons["tarotSpread-single"])
        Thread.sleep(forTimeInterval: 4.6)
        settleTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "蓋著的牌")).firstMatch)
        scrollTap(app.buttons["tarotSeeReading"], in: app)
        XCTAssertTrue(app.descendants(matching: .any)["tarotTwinkoMessage"]
            .waitForExistence(timeout: 5))
        settleTap(app.buttons["tarotBackButton"])
        XCTAssertTrue(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "查看完整解讀")).firstMatch
            .waitForExistence(timeout: 5), "Completed-state CTA after Back")
        XCTAssertEqual(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "蓋著的牌")).count, 0,
            "Revealed faces preserved — no card backs, no re-flip")
        settleTap(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "查看完整解讀")).firstMatch)
        XCTAssertTrue(app.descendants(matching: .any)["tarotTwinkoMessage"]
            .waitForExistence(timeout: 5), "Full reading remains accessible")
        attach(name: "P5-tarot-result-surfaces")
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
