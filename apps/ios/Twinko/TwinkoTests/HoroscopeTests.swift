import XCTest
@testable import Twinko

final class HoroscopeTests: XCTestCase {
    private let referenceDate = Calendar.current.date(
        from: DateComponents(year: 2026, month: 7, day: 16, hour: 10))!

    // MARK: Zodiac identity

    func testCanonicalIDsAreLowercaseEnglishAndRoundTrip() {
        let expected = ["aries", "taurus", "gemini", "cancer", "leo", "virgo",
                        "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces"]
        XCTAssertEqual(ZodiacSign.allCases.map(\.canonicalID), expected)
        for sign in ZodiacSign.allCases {
            XCTAssertEqual(ZodiacSign(canonicalID: sign.canonicalID), sign)
            XCTAssertFalse(sign.symbol.isEmpty, "Code-rendered glyphs use the Unicode symbol")
            XCTAssertFalse(sign.dateRangeText(.english).isEmpty)
        }
        XCTAssertNil(ZodiacSign(canonicalID: "ophiuchus"))
    }

    // MARK: Provider

    func testProviderIsDeterministicPerDateSignAndLocale() async throws {
        let provider = MockHoroscopeProvider()
        let first = try await provider.daily(for: .leo, on: referenceDate, lang: .traditionalChinese)
        let second = try await provider.daily(for: .leo, on: referenceDate, lang: .traditionalChinese)
        XCTAssertEqual(first, second, "Same date + sign + locale must produce the same result")

        let otherSign = try await provider.daily(for: .aries, on: referenceDate,
                                                 lang: .traditionalChinese)
        XCTAssertNotEqual(first, otherSign)
    }

    func testProviderProducesValidResultForAllSignsInBothLocales() async throws {
        let provider = MockHoroscopeProvider()
        for sign in ZodiacSign.allCases {
            for lang in AppLanguage.allCases {
                let result = try await provider.daily(for: sign, on: referenceDate, lang: lang)
                XCTAssertTrue(result.isValid, "\(sign.canonicalID)/\(lang.rawValue) must validate")
                XCTAssertEqual(result.zodiacID, sign.canonicalID)
                XCTAssertEqual(result.locale, lang.rawValue)
            }
        }
    }

    func testEnglishContentContainsNoChineseAndViceVersa() async throws {
        let provider = MockHoroscopeProvider()
        let en = try await provider.daily(for: .virgo, on: referenceDate, lang: .english)
        let containsCJK: (String) -> Bool = {
            $0.unicodeScalars.contains { (0x4E00...0x9FFF).contains($0.value) }
        }
        for text in [en.headline, en.overall.summary, en.overall.detail,
                     en.twinkoMessage, en.lucky.item] {
            XCTAssertFalse(containsCJK(text), "English output must not contain Chinese: \(text)")
        }
        let zh = try await provider.daily(for: .virgo, on: referenceDate, lang: .traditionalChinese)
        XCTAssertTrue(containsCJK(zh.headline))
    }

    // MARK: Cache

    @MainActor
    func testCacheReturnsSavedResultAndPrunesOldDates() async throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("HoroscopeTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = JSONStore(directory: dir)
        let provider = MockHoroscopeProvider()

        let cache = HoroscopeCache(store: store)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: referenceDate)!
        let old = try await provider.daily(for: .leo, on: yesterday, lang: .english)
        cache.save(old, sign: .leo, lang: .english)

        let today = try await provider.daily(for: .leo, on: referenceDate, lang: .english)
        cache.save(today, sign: .leo, lang: .english)

        XCTAssertEqual(cache.cached(dateKey: today.dateKey, sign: .leo, lang: .english), today)
        XCTAssertNil(cache.cached(dateKey: old.dateKey, sign: .leo, lang: .english),
                     "Older dates should be pruned")

        // A fresh cache instance over the same store proves persistence.
        let reloaded = HoroscopeCache(store: store)
        XCTAssertEqual(reloaded.cached(dateKey: today.dateKey, sign: .leo, lang: .english), today)
    }

    // MARK: Share formatter

    func testShareTextIncludesRequiredFieldsAndExcludesDetails() async throws {
        let provider = MockHoroscopeProvider()
        let result = try await provider.daily(for: .leo, on: referenceDate,
                                              lang: .traditionalChinese)
        let text = HoroscopeShareFormatter.text(for: result, sign: .leo,
                                                lang: .traditionalChinese, date: referenceDate)
        XCTAssertTrue(text.contains("獅子座"))
        XCTAssertTrue(text.contains(result.headline))
        XCTAssertTrue(text.contains(result.overall.summary))
        XCTAssertTrue(text.contains(result.twinkoMessage))
        XCTAssertTrue(text.contains("TwinkoTalk"))
        XCTAssertFalse(text.contains(result.love.detail),
                       "Share text must not include the long detail paragraphs")
    }

    // MARK: Summary card renderer

    @MainActor
    func testSummaryCardRendersAt1080x1440InBothLocales() async throws {
        let provider = MockHoroscopeProvider()
        for lang in AppLanguage.allCases {
            let result = try await provider.daily(for: .leo, on: referenceDate, lang: lang)
            let image = HoroscopeSummaryCardRenderer.render(horoscope: result, sign: .leo,
                                                            lang: lang)
            XCTAssertNotNil(image, "Summary card must render for \(lang.rawValue)")
            XCTAssertEqual(image!.size.width * image!.scale, 1080)
            XCTAssertEqual(image!.size.height * image!.scale, 1440,
                           "3:4 canvas matches the background art ratio (clipping fix)")
            // Export for visual review evidence.
            if let data = image!.pngData() {
                let url = FileManager.default.temporaryDirectory
                    .appendingPathComponent("horoscope-summary-card-\(lang.rawValue).png")
                try? data.write(to: url)
            }
        }
    }

    // MARK: Score labels

    func testScoreLabelsCoverAllScoresInBothLanguages() {
        for score in 1...5 {
            XCTAssertFalse(HoroscopeScoreLabel.text(score, .traditionalChinese).isEmpty)
            XCTAssertFalse(HoroscopeScoreLabel.text(score, .english).isEmpty)
            XCTAssertTrue(HoroscopeScoreLabel.accessibilityText(score, .english)
                .contains("\(score) out of 5"))
        }
        XCTAssertEqual(HoroscopeScoreLabel.text(3, .traditionalChinese), "平穩")
    }
}

// MARK: - Approved disclaimer (polish 2026-07-17)

extension HoroscopeTests {
    func testDisclaimerUsesApprovedReflectionWording() {
        XCTAssertEqual(HoroscopeStrings.disclaimer(.traditionalChinese), "內容僅供反思與娛樂")
        XCTAssertEqual(HoroscopeStrings.disclaimer(.english),
                       "For reflection and entertainment only")
    }
}
