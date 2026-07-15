import XCTest
@testable import Twinko

final class MeditationTests: XCTestCase {

    private func request(source: MeditationSourceContext = .direct,
                         focus: MeditationFocus = .calmDown,
                         duration: MeditationDuration = .five,
                         input: String? = nil) -> MeditationGenerationRequest {
        MeditationGenerationRequest(sourceContext: source, focusTopic: focus,
                                    duration: duration, customUserInput: input)
    }

    func testGenerationIsDeterministicAndValid() async throws {
        let provider = MockMeditationProvider()
        let first = try await provider.generate(request(), lang: .traditionalChinese)
        let second = try await provider.generate(request(), lang: .traditionalChinese)
        XCTAssertEqual(first, second, "Same request must generate the same session")
        XCTAssertTrue(first.isValid)
        XCTAssertEqual(first.segments.map(\.kind), MeditationSegmentKind.allCases,
                       "Session must contain grounding→breathing→reflection→affirmation→closing")
    }

    func testAllFocusDurationSourceCombinationsValidateInBothLocales() async throws {
        let provider = MockMeditationProvider()
        let sources: [MeditationSourceContext] = [
            .direct,
            MeditationSourceContext(sourceType: .chat, recentChatSummary: "工作壓力",
                                    tarotQuestion: nil, tarotSummary: nil, emotionalTone: nil),
            MeditationSourceContext(sourceType: .tarot, recentChatSummary: nil,
                                    tarotQuestion: "該怎麼安排步調？",
                                    tarotSummary: "把注意力放回自己身上", emotionalTone: nil),
        ]
        for focus in MeditationFocus.allCases {
            for duration in MeditationDuration.allCases {
                for source in sources {
                    for lang in AppLanguage.allCases {
                        let result = try await provider.generate(
                            request(source: source, focus: focus, duration: duration), lang: lang)
                        XCTAssertTrue(result.isValid,
                                      "\(focus.rawValue)/\(duration.rawValue)/\(source.sourceType.rawValue)/\(lang.rawValue)")
                        XCTAssertEqual(result.sourceType, source.sourceType)
                        XCTAssertEqual(result.duration, duration)
                    }
                }
            }
        }
    }

    func testDurationScalesSegmentLength() async throws {
        let provider = MockMeditationProvider()
        let short = try await provider.generate(request(duration: .three), lang: .english)
        let long = try await provider.generate(request(duration: .ten), lang: .english)
        XCTAssertEqual(short.segments[0].lines.count, 2)
        XCTAssertEqual(long.segments[0].lines.count, 4)
    }

    func testChatAndTarotContextAcknowledgedInReflection() async throws {
        let provider = MockMeditationProvider()
        let chat = MeditationSourceContext(sourceType: .chat, recentChatSummary: "面試好緊張",
                                           tarotQuestion: nil, tarotSummary: nil,
                                           emotionalTone: nil)
        let chatResult = try await provider.generate(request(source: chat),
                                                     lang: .traditionalChinese)
        let chatReflection = chatResult.segments.first { $0.kind == .reflection }!
        XCTAssertTrue(chatReflection.lines.contains { $0.contains("Twinko 聊到") },
                      "Chat-derived sessions should gently acknowledge the conversation")
        XCTAssertFalse(chatReflection.lines.contains { $0.contains("面試好緊張") },
                       "Raw chat text must not be quoted verbatim")

        let tarot = MeditationSourceContext(sourceType: .tarot, recentChatSummary: nil,
                                            tarotQuestion: "問題", tarotSummary: "指引",
                                            emotionalTone: nil)
        let tarotResult = try await provider.generate(request(source: tarot),
                                                      lang: .traditionalChinese)
        let tarotReflection = tarotResult.segments.first { $0.kind == .reflection }!
        XCTAssertTrue(tarotReflection.lines.contains { $0.contains("牌面") || $0.contains("指引") },
                      "Tarot-derived sessions should acknowledge the reading")
    }

    func testMissingOptionalContextDoesNotBreakGeneration() async throws {
        let provider = MockMeditationProvider()
        // Chat/Tarot sources with all-nil context must still generate.
        for sourceType in [MeditationSourceType.chat, .tarot] {
            let source = MeditationSourceContext(sourceType: sourceType,
                                                 recentChatSummary: nil, tarotQuestion: nil,
                                                 tarotSummary: nil, emotionalTone: nil)
            let result = try await provider.generate(request(source: source), lang: .english)
            XCTAssertTrue(result.isValid)
        }
    }

    func testEnglishOutputContainsNoChinese() async throws {
        let provider = MockMeditationProvider()
        let result = try await provider.generate(request(focus: .sleep), lang: .english)
        let containsCJK: (String) -> Bool = {
            $0.unicodeScalars.contains { (0x4E00...0x9FFF).contains($0.value) }
        }
        XCTAssertFalse(containsCJK(result.title))
        for segment in result.segments {
            for line in segment.lines {
                XCTAssertFalse(containsCJK(line), "English session must not mix Chinese: \(line)")
            }
        }
        XCTAssertFalse(containsCJK(result.closingMessage))
    }

    func testValidationRejectsMalformedResults() {
        let good = MeditationSegmentKind.allCases.map {
            MeditationSegment(kind: $0, lines: ["line"])
        }
        XCTAssertTrue(MeditationGenerationResult(title: "t", segments: good,
                                                 closingMessage: "c", duration: .five,
                                                 sourceType: .direct).isValid)
        XCTAssertFalse(MeditationGenerationResult(title: "", segments: good,
                                                  closingMessage: "c", duration: .five,
                                                  sourceType: .direct).isValid)
        XCTAssertFalse(MeditationGenerationResult(title: "t",
                                                  segments: Array(good.dropLast()),
                                                  closingMessage: "c", duration: .five,
                                                  sourceType: .direct).isValid,
                       "Missing segments must fail validation")
    }
}
