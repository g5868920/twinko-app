import XCTest
@testable import Twinko

/// Phase 1 pre-reading protection (nonvisual): canonical spread
/// definitions, deterministic intent→spread mapping, and structured
/// input validation. Draw/reveal/result stay covered by TarotDrawTests.
final class TarotPreReadingTests: XCTestCase {

    // 1 — All ten definitions: card count, ordered stable position IDs,
    //     input kind, layout kind; no premium spreads in the library.
    func testSpreadLibraryDefinitions() {
        XCTAssertEqual(TarotSpreadID.allCases.count, 10)
        XCTAssertEqual(Set(TarotSpreadLibrary.orderedIDs), Set(TarotSpreadID.allCases))
        XCTAssertEqual(TarotSpreadLibrary.orderedIDs.count, 10)

        let expected: [TarotSpreadID: (count: Int, positions: [TarotPositionID],
                                       input: TarotInputKind, layout: TarotSpreadLayoutKind)] = [
            .singleCard: (1, [.momentMessage], .generalQuestion, .single),
            .timelineThree: (3, [.past, .present, .possibleDirection],
                             .generalQuestion, .threeLinear),
            .actionDirectionThree: (3, [.currentSituation, .availableAction, .possibleDirection],
                                    .generalQuestion, .threeLinear),
            .blindSpotThree: (3, [.currentUnderstanding, .unseenPerspective, .possibleReframe],
                              .generalQuestion, .threeLinear),
            .holisticCheckInThree: (3, [.bodySignal, .thoughtsFeelings, .innerCare],
                                    .generalQuestion, .threeLinear),
            .thinkFeelActThree: (3, [.whatIThink, .whatIFeel, .howIRespond],
                                 .generalQuestion, .threeLinear),
            .directionPathThree: (3, [.whereIAmNow, .whereIWantToGo, .howIMoveCloser],
                                  .generalQuestion, .threeLinear),
            .coreClarityFour: (4, [.coreIssue, .currentObstacle, .possibleApproach,
                                   .availableStrength],
                               .generalQuestion, .fourGrid),
            .twoChoiceFive: (5, [.optionAState, .optionBState, .optionADirection,
                                 .optionBDirection, .yourCurrentState],
                             .twoChoice, .twoChoiceFive),
            .relationshipFive: (5, [.myState, .myFeelingsAttitude, .theirPresentedState,
                                    .theirPresentedAttitude, .relationshipDirection],
                                .relationship, .relationshipFive),
        ]

        for id in TarotSpreadID.allCases {
            let definition = TarotSpreadLibrary.definition(for: id)
            guard let expectation = expected[id] else {
                XCTFail("Missing expectation for \(id)"); continue
            }
            XCTAssertEqual(definition.cardCount, expectation.count, "\(id) card count")
            XCTAssertEqual(definition.positionIDs, expectation.positions,
                           "\(id) ordered positions")
            XCTAssertEqual(definition.positionIDs.count, definition.cardCount,
                           "\(id) position count matches card count")
            XCTAssertEqual(Set(definition.positionIDs).count, definition.positionIDs.count,
                           "\(id) has no duplicate positions")
            XCTAssertEqual(definition.inputKind, expectation.input, "\(id) input kind")
            XCTAssertEqual(definition.layoutKind, expectation.layout, "\(id) layout kind")
            XCTAssertTrue(definition.supportsGuidanceCard)
        }

        // Domain eligibility highlights from the usage spec.
        XCTAssertEqual(TarotSpreadLibrary.definition(for: .relationshipFive).supportedDomains,
                       [.romanticRelationship])
        XCTAssertEqual(TarotSpreadLibrary.definition(for: .twoChoiceFive).supportedDomains,
                       TarotDomain.all)
    }

    // 2 — Intent and refinement mappings are deterministic and exact.
    func testIntentAndRefinementMapping() {
        XCTAssertEqual(TarotSpreadLibrary.recommendedSpread(for: .quickReflection,
                                                            refinement: nil), .singleCard)
        XCTAssertEqual(TarotSpreadLibrary.recommendedSpread(for: .understandProgression,
                                                            refinement: nil), .timelineThree)
        XCTAssertEqual(TarotSpreadLibrary.recommendedSpread(for: .missingPerspective,
                                                            refinement: nil), .blindSpotThree)
        XCTAssertEqual(TarotSpreadLibrary.recommendedSpread(for: .compareTwoChoices,
                                                            refinement: nil), .twoChoiceFive)
        XCTAssertEqual(TarotSpreadLibrary.recommendedSpread(for: .romanticRelationship,
                                                            refinement: nil), .relationshipFive)

        XCTAssertEqual(TarotSpreadLibrary.recommendedSpread(for: .nextStepOrDirection,
                                                            refinement: .practicalNextAction),
                       .actionDirectionThree)
        XCTAssertEqual(TarotSpreadLibrary.recommendedSpread(for: .nextStepOrDirection,
                                                            refinement: .understandWhyStuck),
                       .coreClarityFour)
        XCTAssertEqual(TarotSpreadLibrary.recommendedSpread(for: .nextStepOrDirection,
                                                            refinement: .knownDirectionUnknownPath),
                       .directionPathThree)
        XCTAssertEqual(TarotSpreadLibrary.recommendedSpread(for: .understandMyself,
                                                            refinement: .wholePersonCheckIn),
                       .holisticCheckInThree)
        XCTAssertEqual(TarotSpreadLibrary.recommendedSpread(for: .understandMyself,
                                                            refinement: .specificSituationReflection),
                       .thinkFeelActThree)

        // Refinement-requiring intents do not resolve without one.
        XCTAssertNil(TarotSpreadLibrary.recommendedSpread(for: .nextStepOrDirection,
                                                          refinement: nil))
        XCTAssertNil(TarotSpreadLibrary.recommendedSpread(for: .understandMyself,
                                                          refinement: nil))

        // Refinement structure matches the flow (three + two options).
        XCTAssertEqual(TarotIntent.nextStepOrDirection.refinements,
                       [.practicalNextAction, .understandWhyStuck, .knownDirectionUnknownPath])
        XCTAssertEqual(TarotIntent.understandMyself.refinements,
                       [.wholePersonCheckIn, .specificSituationReflection])
        XCTAssertTrue(TarotIntent.quickReflection.refinements.isEmpty)
    }

    // 3 — Structured input validation blocks empty required fields
    //     after trimming; nothing is invented.
    func testDraftValidation() {
        // Two-Choice: whitespace-only options are invalid.
        var twoChoice = TarotReadingDraft(intent: .compareTwoChoices,
                                          refinement: nil, spreadID: .twoChoiceFive)
        twoChoice.decisionContext = "我正在比較兩個工作選擇"
        twoChoice.optionA = "   "
        twoChoice.optionB = "接受新的工作邀請"
        XCTAssertFalse(twoChoice.isLaunchable)
        XCTAssertEqual(twoChoice.missingRequiredFields, [.optionA])

        twoChoice.optionA = "留在目前公司"
        XCTAssertTrue(twoChoice.isLaunchable)
        XCTAssertTrue(twoChoice.missingRequiredFields.isEmpty)

        twoChoice.decisionContext = "\n "
        XCTAssertEqual(twoChoice.missingRequiredFields, [.decisionContext])

        // Relationship: question required, person label optional.
        var relationship = TarotReadingDraft(intent: .romanticRelationship,
                                             refinement: nil, spreadID: .relationshipFive)
        XCTAssertEqual(relationship.missingRequiredFields, [.question])
        relationship.question = "我和對方目前的關係處於什麼狀態？"
        XCTAssertTrue(relationship.isLaunchable)
        XCTAssertTrue(relationship.trimmedPersonLabel.isEmpty)

        // General spreads keep the existing optional-question behavior.
        let general = TarotReadingDraft(intent: .quickReflection,
                                        refinement: nil, spreadID: .singleCard)
        XCTAssertTrue(general.isLaunchable)

        // The launch request carries the same validated draft.
        let request = TarotReadingLaunchRequest(draft: twoChoiceValid())
        XCTAssertEqual(request.draft.selectedSpreadID, .twoChoiceFive)
        XCTAssertEqual(request.draft.trimmedOptionA, "留在目前公司")
    }

    private func twoChoiceValid() -> TarotReadingDraft {
        var draft = TarotReadingDraft(intent: .compareTwoChoices,
                                      refinement: nil, spreadID: .twoChoiceFive)
        draft.decisionContext = "我正在比較兩個工作選擇"
        draft.optionA = " 留在目前公司 "
        draft.optionB = "接受新的工作邀請"
        return draft
    }
}
