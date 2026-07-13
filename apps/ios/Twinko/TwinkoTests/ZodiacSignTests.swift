import XCTest
@testable import Twinko

final class ZodiacSignTests: XCTestCase {
    func testBoundaryDates() {
        XCTAssertEqual(ZodiacSign.from(month: 3, day: 21), .aries)
        XCTAssertEqual(ZodiacSign.from(month: 4, day: 19), .aries)
        XCTAssertEqual(ZodiacSign.from(month: 4, day: 20), .taurus)
        XCTAssertEqual(ZodiacSign.from(month: 12, day: 21), .sagittarius)
        XCTAssertEqual(ZodiacSign.from(month: 12, day: 22), .capricorn)
        XCTAssertEqual(ZodiacSign.from(month: 1, day: 19), .capricorn)
        XCTAssertEqual(ZodiacSign.from(month: 1, day: 20), .aquarius)
        XCTAssertEqual(ZodiacSign.from(month: 2, day: 19), .pisces)
        XCTAssertEqual(ZodiacSign.from(month: 3, day: 20), .pisces)
    }

    func testFromDate() {
        let date = Calendar.current.date(from: DateComponents(year: 1995, month: 8, day: 1))!
        XCTAssertEqual(ZodiacSign.from(date: date), .leo)
    }

    func testAllTwelveSignsReachable() {
        let months: [(Int, Int)] = [(1, 1), (2, 1), (3, 1), (4, 1), (5, 1), (6, 1),
                                    (7, 1), (8, 1), (9, 1), (10, 1), (11, 1), (12, 1)]
        let signs = Set(months.map { ZodiacSign.from(month: $0.0, day: $0.1) })
        XCTAssertEqual(signs.count, 12)
    }
}
