import AVFoundation
import Foundation

// MARK: - Narration boundary (temporary, replaceable)

/// Small replaceable narration boundary. The prototype speaks with the
/// built-in `AVSpeechSynthesizer`; a produced-voice or server TTS
/// provider can slot in later without touching the session controller
/// or views. The voice script stays outside the provider.
protocol MeditationNarrating: AnyObject {
    func speak(_ text: String, lang: AppLanguage)
    func pause()
    func resume()
    func stop()
}

/// Built-in iOS speech narration with a locale-appropriate voice and a
/// slow, calm rate. No external TTS dependency.
final class SpeechNarrationProvider: MeditationNarrating {
    private let synthesizer = AVSpeechSynthesizer()

    /// Locale-aware voice selection — never one hardcoded voice for
    /// both languages.
    static func voiceLanguage(for lang: AppLanguage) -> String {
        lang == .english ? "en-US" : "zh-TW"
    }

    func speak(_ text: String, lang: AppLanguage) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: Self.voiceLanguage(for: lang))
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.82
        utterance.pitchMultiplier = 1.02
        utterance.postUtteranceDelay = 0.4
        synthesizer.speak(utterance)
    }

    func pause() {
        synthesizer.pauseSpeaking(at: .word)
    }

    func resume() {
        synthesizer.continueSpeaking()
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

// MARK: - Ambient audio boundary (temporary, replaceable)

/// Replaceable ambient-audio boundary. No approved ambient tracks are
/// bundled in the repo today, so the default provider resolves to a
/// documented silent fallback: `isAvailable == false`, every call is a
/// safe no-op, and session progression never blocks on audio. When an
/// approved track lands in the bundle (`ambient_meditation_v1`), this
/// same provider loops it quietly with no view changes.
protocol MeditationAmbientPlaying: AnyObject {
    var isAvailable: Bool { get }
    func play()
    func pause()
    func resume()
    func stop()
    func setEnabled(_ enabled: Bool)
}

final class BundledAmbientAudioProvider: MeditationAmbientPlaying {
    /// Expected approved asset name once delivered.
    static let approvedTrackName = "ambient_meditation_v1"

    private var player: AVAudioPlayer?
    private var enabled = true

    init() {
        for ext in ["m4a", "mp3", "caf"] {
            if let url = Bundle.main.url(forResource: Self.approvedTrackName,
                                         withExtension: ext),
               let loaded = try? AVAudioPlayer(contentsOf: url) {
                loaded.numberOfLoops = -1
                loaded.volume = 0.25
                player = loaded
                break
            }
        }
    }

    var isAvailable: Bool { player != nil }

    func play() {
        guard enabled else { return }
        player?.play()
    }

    func pause() { player?.pause() }

    func resume() {
        guard enabled else { return }
        player?.play()
    }

    func stop() { player?.stop() }

    func setEnabled(_ isEnabled: Bool) {
        enabled = isEnabled
        if isEnabled { player?.play() } else { player?.pause() }
    }
}

// MARK: - Session playback controller

/// The single source of truth for an active meditation session: one
/// clock, automatic segment progression, pause/resume, and exactly one
/// completion. Narration and ambient audio hang off the clock but
/// never drive it — the session progresses correctly with either or
/// both disabled.
@MainActor
final class MeditationPlaybackController: ObservableObject {
    @Published private(set) var segmentIndex = 0
    @Published private(set) var remainingSeconds = 0
    @Published private(set) var isPaused = false
    @Published private(set) var isCompleted = false
    @Published var narrationEnabled = true {
        didSet {
            guard oldValue != narrationEnabled else { return }
            if narrationEnabled { speakCurrentSegment() } else { narrator.stop() }
        }
    }
    @Published var ambientEnabled = true {
        didSet { ambient.setEnabled(ambientEnabled) }
    }

    var ambientAvailable: Bool { ambient.isAvailable }
    var onComplete: (() -> Void)?

    private let narrator: MeditationNarrating
    private let ambient: MeditationAmbientPlaying
    private let tickNanoseconds: UInt64
    private var ticker: Task<Void, Never>?
    private var elapsedSeconds = 0
    private var totalSeconds = 0
    private var segmentEnds: [Int] = []
    private var result: MeditationGenerationResult?
    private var lang: AppLanguage = .traditionalChinese

    init(narrator: MeditationNarrating = SpeechNarrationProvider(),
         ambient: MeditationAmbientPlaying = BundledAmbientAudioProvider(),
         tickNanoseconds: UInt64? = nil) {
        self.narrator = narrator
        self.ambient = ambient
        // UI-test hook: compresses the wall-clock without touching the
        // session math (one tick still advances one session-second).
        if let tickNanoseconds {
            self.tickNanoseconds = tickNanoseconds
        } else if ProcessInfo.processInfo.arguments.contains("-uiTestFastMeditation") {
            self.tickNanoseconds = 40_000_000
        } else {
            self.tickNanoseconds = 1_000_000_000
        }
    }

    /// Cumulative per-segment end times: the total duration weighted by
    /// each segment's line count — pure and testable.
    static func segmentEndSeconds(for result: MeditationGenerationResult) -> [Int] {
        let total = result.duration.rawValue * 60
        let weights = result.segments.map { max($0.lines.count, 1) }
        let weightSum = weights.reduce(0, +)
        var ends: [Int] = []
        var acc = 0.0
        for weight in weights {
            acc += Double(total) * Double(weight) / Double(weightSum)
            ends.append(Int(acc.rounded()))
        }
        // The final boundary is exactly the session length.
        if !ends.isEmpty { ends[ends.count - 1] = total }
        return ends
    }

    func start(result: MeditationGenerationResult, lang: AppLanguage) {
        stopTicker()
        self.result = result
        self.lang = lang
        segmentIndex = 0
        elapsedSeconds = 0
        totalSeconds = result.duration.rawValue * 60
        segmentEnds = Self.segmentEndSeconds(for: result)
        remainingSeconds = totalSeconds
        isPaused = false
        isCompleted = false
        if ambientEnabled { ambient.play() }
        speakCurrentSegment()
        runTicker()
    }

    func pause() {
        guard !isPaused, !isCompleted else { return }
        isPaused = true
        stopTicker()
        narrator.pause()
        ambient.pause()
    }

    func resume() {
        guard isPaused, !isCompleted else { return }
        isPaused = false
        narrator.resume()
        if ambientEnabled { ambient.resume() }
        runTicker()
    }

    /// Ends the session (early exit or teardown) — audio and the clock
    /// stop; no completion fires.
    func stop() {
        stopTicker()
        narrator.stop()
        ambient.stop()
    }

    // MARK: Clock

    private func runTicker() {
        stopTicker()
        ticker = Task { [weak self] in
            while let self, !Task.isCancelled, !self.isCompleted, !self.isPaused {
                try? await Task.sleep(nanoseconds: self.tickNanoseconds)
                guard !Task.isCancelled, !self.isPaused, !self.isCompleted else { return }
                self.tick()
            }
        }
    }

    private func stopTicker() {
        ticker?.cancel()
        ticker = nil
    }

    private func tick() {
        elapsedSeconds += 1
        remainingSeconds = max(totalSeconds - elapsedSeconds, 0)

        if elapsedSeconds >= totalSeconds {
            complete()
            return
        }
        // Automatic segment progression from the session clock.
        if segmentIndex < segmentEnds.count - 1,
           elapsedSeconds >= segmentEnds[segmentIndex] {
            segmentIndex += 1
            speakCurrentSegment()
        }
    }

    /// Completes exactly once: the guard makes duplicate transitions
    /// impossible even if a stray tick lands.
    private func complete() {
        guard !isCompleted else { return }
        isCompleted = true
        stopTicker()
        narrator.stop()
        ambient.stop()
        onComplete?()
    }

    private func speakCurrentSegment() {
        guard narrationEnabled, let result, !isCompleted,
              result.segments.indices.contains(segmentIndex) else { return }
        narrator.speak(result.segments[segmentIndex].lines.joined(separator: " "),
                       lang: lang)
    }
}
