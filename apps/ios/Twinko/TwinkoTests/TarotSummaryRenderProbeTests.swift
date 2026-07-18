import XCTest
@testable import Twinko

private struct ProbeRNG: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

/// Scratch visual probe: renders the four Summary Card modes to PNG
/// for inspection. Not part of the behavioral suite.
@MainActor
final class TarotSummaryRenderProbeTests: XCTestCase {
    func testRenderAllModesToScratchpad() throws {
        let provider = MockTarotInterpretationProvider()
        let out = URL(fileURLWithPath: "/tmp/twinko_summary_probe", isDirectory: true)
        try? FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
        for (name, spreadID, guidance) in [("single", TarotSpreadID.singleCard, false),
                                           ("three", .timelineThree, false),
                                           ("single_guidance", .singleCard, true),
                                           ("three_guidance", .timelineThree, true)] {
            var engine = TarotDrawEngine(rng: ProbeRNG(state: 7))
            var session = TarotReadingSession(spreadID: spreadID, topic: .finance,
                                              question: "測試")
            session.cards = engine.draw(spreadID: spreadID)
            if guidance { session.guidanceCard = engine.drawGuidance(excluding: session.cards) }
            let image = TarotSummaryCardRenderer.render(session: session,
                                                        provider: provider,
                                                        lang: .traditionalChinese)
            XCTAssertNotNil(image, name)
            XCTAssertEqual(image!.size.width * image!.scale, 1080, name)
            XCTAssertEqual(image!.size.height * image!.scale, 1440, name)
            try image!.pngData()!.write(to: out.appendingPathComponent("\(name).png"))
        }
    }
}
