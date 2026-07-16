import XCTest
@testable import Twinko

// MARK: - Test doubles

private final class SpyNarrator: MeditationNarrating {
    var spoken: [String] = []
    var paused = 0, resumed = 0, stopped = 0
    func speak(_ text: String, lang: AppLanguage) { spoken.append(text) }
    func pause() { paused += 1 }
    func resume() { resumed += 1 }
    func stop() { stopped += 1 }
}

private final class SpyAmbient: MeditationAmbientPlaying {
    var isAvailable = false
    var played = 0, stopped = 0
    func play() { played += 1 }
    func pause() {}
    func resume() {}
    func stop() { stopped += 1 }
    func setEnabled(_ enabled: Bool) {}
}

@MainActor
final class MeditationPlaybackTests: XCTestCase {

    private func makeResult(duration: MeditationDuration = .three) async throws
        -> MeditationGenerationResult {
        let request = MeditationGenerationRequest(sourceContext: .direct,
                                                  focusTopic: .calmDown,
                                                  duration: duration,
                                                  customUserInput: nil)
        return try await MockMeditationProvider().generate(request, lang: .traditionalChinese)
    }

    func testSegmentEndSecondsCoverTheFullSessionOnce() async throws {
        let result = try await makeResult(duration: .three)
        let ends = MeditationPlaybackController.segmentEndSeconds(for: result)
        XCTAssertEqual(ends.count, result.segments.count)
        XCTAssertEqual(ends.last, 180, "Final boundary is exactly the session length")
        XCTAssertEqual(ends, ends.sorted(), "Boundaries are monotonic")
    }

    func testAutomaticProgressionCompletesExactlyOnce() async throws {
        let result = try await makeResult(duration: .three)
        let narrator = SpyNarrator()
        let controller = MeditationPlaybackController(narrator: narrator,
                                                      ambient: SpyAmbient(),
                                                      tickNanoseconds: 200_000)
        var completions = 0
        controller.onComplete = { completions += 1 }
        controller.start(result: result, lang: .traditionalChinese)

        // 180 fast ticks at 0.2 ms — allow generous wall time.
        for _ in 0..<300 where !controller.isCompleted {
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        XCTAssertTrue(controller.isCompleted)
        XCTAssertEqual(completions, 1, "Completion fires exactly once")
        XCTAssertEqual(controller.segmentIndex, result.segments.count - 1,
                       "The clock walked through every segment")
        XCTAssertEqual(narrator.spoken.count, result.segments.count,
                       "Each segment narrated once, no duplicates")
        XCTAssertEqual(controller.remainingSeconds, 0)
    }

    func testPauseFreezesTheClockAndResumePreservesTheSegment() async throws {
        let result = try await makeResult(duration: .three)
        let controller = MeditationPlaybackController(narrator: SpyNarrator(),
                                                      ambient: SpyAmbient(),
                                                      tickNanoseconds: 1_000_000)
        controller.start(result: result, lang: .traditionalChinese)
        try await Task.sleep(nanoseconds: 40_000_000)
        controller.pause()
        let segmentAtPause = controller.segmentIndex
        let remainingAtPause = controller.remainingSeconds
        XCTAssertTrue(controller.isPaused)

        try await Task.sleep(nanoseconds: 60_000_000)
        XCTAssertEqual(controller.remainingSeconds, remainingAtPause,
                       "Paused clock does not advance")

        controller.resume()
        XCTAssertFalse(controller.isPaused)
        XCTAssertEqual(controller.segmentIndex, segmentAtPause,
                       "Resume continues from the same segment — no restart")
        try await Task.sleep(nanoseconds: 60_000_000)
        XCTAssertLessThan(controller.remainingSeconds, remainingAtPause,
                          "Clock advances again after resume")
        controller.stop()
    }

    func testNarrationVoiceFollowsLocale() {
        XCTAssertEqual(SpeechNarrationProvider.voiceLanguage(for: .english), "en-US")
        XCTAssertEqual(SpeechNarrationProvider.voiceLanguage(for: .traditionalChinese), "zh-TW")
    }

    // MARK: Source-mode mapping

    func testEffectiveContextMapsGeneralChatAndTarot() {
        let chat = MeditationSourceContext(sourceType: .chat, focusSummary: "摘要")
        let tarot = MeditationSourceContext(sourceType: .tarot, focusSummary: "摘要")
        XCTAssertEqual(MeditationFlowView.effectiveContext(chat, useGeneral: false).sourceType, .chat)
        XCTAssertEqual(MeditationFlowView.effectiveContext(tarot, useGeneral: false).sourceType, .tarot)
        XCTAssertEqual(MeditationFlowView.effectiveContext(.direct, useGeneral: false).sourceType, .direct)
        // "改用一般冥想" drops the source and its summary entirely.
        let generalized = MeditationFlowView.effectiveContext(chat, useGeneral: true)
        XCTAssertEqual(generalized.sourceType, .direct)
        XCTAssertNil(generalized.focusSummary)
    }

    // MARK: Records

    func testRecordDistinguishesCompletedFromEarlyEndAndKeepsFeeling() {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("TwinkoMeditationRecords-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = MeditationRecordStore(store: JSONStore(directory: directory))

        let completed = store.beginSession(source: .chat, sourceSummary: "摘要",
                                           focus: .releaseAnxiety, duration: .three,
                                           optionalNote: nil)
        let early = store.beginSession(source: .direct, sourceSummary: nil,
                                       focus: .sleep, duration: .ten,
                                       optionalNote: "note")
        store.endSession(completed, completed: true)
        store.endSession(early, completed: false)
        store.setFinalFeeling(completed, feeling: .calmer)

        let reloaded = MeditationRecordStore(store: JSONStore(directory: directory))
        let done = reloaded.records.first { $0.id == completed }
        let ended = reloaded.records.first { $0.id == early }
        XCTAssertEqual(done?.completed, true)
        XCTAssertEqual(done?.finalFeeling, MeditationMood.calmer.rawValue)
        XCTAssertNotNil(done?.endedAt)
        XCTAssertEqual(ended?.completed, false)
        XCTAssertNil(ended?.finalFeeling)
        XCTAssertNotNil(ended?.endedAt)
    }

    // MARK: Tarot exit threshold

    func testTarotExitConfirmationThreshold() {
        XCTAssertFalse(TarotFlowView.requiresExitConfirmation(stage: .setup))
        XCTAssertFalse(TarotFlowView.requiresExitConfirmation(stage: .spread))
        XCTAssertTrue(TarotFlowView.requiresExitConfirmation(stage: .shuffle))
        XCTAssertTrue(TarotFlowView.requiresExitConfirmation(stage: .reveal))
        XCTAssertTrue(TarotFlowView.requiresExitConfirmation(stage: .result))
        XCTAssertTrue(TarotFlowView.requiresExitConfirmation(stage: .guidanceReveal))
    }
}
