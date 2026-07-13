import XCTest
@testable import Twinko

final class AstrologyContentTests: XCTestCase {
    private let referenceDate = Calendar.current.date(
        from: DateComponents(year: 2026, month: 7, day: 14, hour: 9))!

    func testDailyContentIsDeterministicForSameSignAndDay() {
        let first = AstrologyContent.daily(for: .leo, on: referenceDate)
        let second = AstrologyContent.daily(for: .leo, on: referenceDate)
        XCTAssertEqual(first, second)
    }

    func testDifferentSignsGetTheirOwnContent() {
        let all = ZodiacSign.allCases.map { AstrologyContent.daily(for: $0, on: referenceDate) }
        let overallVariants = Set(all.map(\.overall))
        XCTAssertTrue(overallVariants.count > 1, "All signs reading identically would be a bug")
    }

    func testAllRequiredFieldsPresent() {
        let daily = AstrologyContent.daily(for: .virgo, on: referenceDate)
        XCTAssertFalse(daily.overall.isEmpty)
        XCTAssertFalse(daily.love.isEmpty)
        XCTAssertFalse(daily.career.isEmpty)
        XCTAssertFalse(daily.finance.isEmpty)
        XCTAssertTrue((1...99).contains(daily.luckyNumber))
        XCTAssertFalse(daily.luckyColor.isEmpty)
        XCTAssertFalse(daily.luckyItem.isEmpty)
    }

    func testContentAvoidsProhibitedCertaintyClaims() {
        // Guardrail check across every pool entry reachable today: no
        // guaranteed-outcome phrasing (safety §5/§11).
        let prohibited = ["保證", "一定會", "絕對", "必定"]
        for sign in ZodiacSign.allCases {
            let daily = AstrologyContent.daily(for: sign, on: referenceDate)
            for text in [daily.overall, daily.love, daily.career, daily.finance] {
                for word in prohibited {
                    XCTAssertFalse(text.contains(word),
                                   "「\(text)」 contains prohibited phrasing 「\(word)」")
                }
            }
        }
    }
}
