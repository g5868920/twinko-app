import Foundation

// MARK: - Provider boundary

/// Generation boundary for personalized meditations. The prototype
/// ships a deterministic local mock; a future LLM-backed provider
/// slots in behind the same protocol (context extraction, safety
/// classification, plan and script generation per the AI generation
/// spec) without touching views.
protocol MeditationGenerating: Sendable {
    func generate(_ request: MeditationGenerationRequest,
                  lang: AppLanguage) async throws -> MeditationGenerationResult
}

// MARK: - Mock provider

/// Deterministic local generation: composes a structured, validated
/// session from focus-aware bilingual pools, varied stably by focus +
/// duration + source, and weaves in a short acknowledgment of the
/// Chat/Tarot/custom context (never verbatim transcripts). All copy
/// lives here — none in views.
struct MockMeditationProvider: MeditationGenerating {

    func generate(_ request: MeditationGenerationRequest,
                  lang: AppLanguage) async throws -> MeditationGenerationResult {
        let seedText = "\(request.focusTopic.rawValue)|\(request.duration.rawValue)|"
            + "\(request.sourceContext.sourceType.rawValue)|\(lang.rawValue)"
        func pick<T>(_ pool: [T], _ field: String) -> T {
            pool[Int(stableHash(seedText + "|" + field) % UInt64(pool.count))]
        }

        let lineCount = request.duration.linesPerSegment
        func lines(_ kind: MeditationSegmentKind) -> [String] {
            var pool = Self.segmentPools[kind]![lang]!
            // Stable rotation so different focuses read differently.
            let offset = Int(stableHash(seedText + kind.rawValue) % UInt64(pool.count))
            pool = Array(pool[offset...] + pool[..<offset])
            var chosen = Array(pool.prefix(lineCount))
            // Weave one context-aware line into the reflection segment.
            if kind == .reflection, let contextLine = contextLine(request, lang) {
                chosen[0] = contextLine
            }
            return chosen
        }

        let result = MeditationGenerationResult(
            title: Self.titles[request.focusTopic]![lang]!,
            segments: MeditationSegmentKind.allCases.map {
                MeditationSegment(kind: $0, lines: lines($0))
            },
            closingMessage: pick(Self.closingMessages[lang]!, "closing-message"),
            duration: request.duration,
            sourceType: request.sourceContext.sourceType
        )
        return result
    }

    /// One short line acknowledging where this meditation came from.
    /// Uses only the compact summaries handed across — never raw
    /// content, and degrades gracefully when context is missing.
    private func contextLine(_ request: MeditationGenerationRequest,
                             _ lang: AppLanguage) -> String? {
        let custom = request.customUserInput?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        switch request.sourceContext.sourceType {
        case .checkIn:
            return lang == .english
                ? "Let today's feeling simply be here with you — nothing needs fixing right now."
                : "讓今天的心情陪著你就好，現在不需要修好什麼。"
        case .direct:
            guard !custom.isEmpty else { return nil }
            return lang == .english
                ? "Let what you shared — \u{201C}\(custom.prefix(40))\u{201D} — simply rest here with you for now."
                : "你剛剛寫下的心事，先讓它輕輕放在這裡就好，不用急著處理。"
        case .chat:
            return lang == .english
                ? "Whatever you and Twinko just talked about, it doesn't need solving right now — just let it soften a little."
                : "剛剛跟 Twinko 聊到的那些，現在先不用解決，讓它在心裡輕一點就好。"
        case .tarot:
            return lang == .english
                ? "Let the guidance from your reading settle quietly — it was an angle to think with, not a verdict to carry."
                : "讓剛剛牌面給你的指引慢慢沉澱——它是一個溫柔的角度，不是需要背著走的答案。"
        }
    }

    // MARK: Fixture pools

    private static let titles: [MeditationFocus: [AppLanguage: String]] = [
        .calmDown: [.english: "Coming Back to Calm", .traditionalChinese: "回到平靜的地方"],
        .releaseAnxiety: [.english: "Setting the Worry Down", .traditionalChinese: "把焦慮輕輕放下"],
        .sleep: [.english: "Drifting Toward Rest", .traditionalChinese: "慢慢走向睡意"],
        .selfLove: [.english: "Being Gentle With Yourself", .traditionalChinese: "溫柔地對待自己"],
        .manifest: [.english: "Making Room for What You Want", .traditionalChinese: "為想要的事留出空間"],
    ]

    private static let segmentPools: [MeditationSegmentKind: [AppLanguage: [String]]] = [
        .grounding: [
            .traditionalChinese: [
                "找一個讓你覺得穩穩的姿勢，坐著或躺著都可以。",
                "讓肩膀輕輕垂下來，感覺身體被支撐著。",
                "如果願意，可以輕輕閉上眼睛，或讓視線變得柔軟。",
                "注意一下身體和椅子、地板接觸的地方，那裡很安全。",
            ],
            .english: [
                "Find a position that feels steady — sitting or lying down are both fine.",
                "Let your shoulders drop softly, and feel your body being supported.",
                "If you like, gently close your eyes, or simply let your gaze soften.",
                "Notice where your body meets the chair or floor. That place is safe.",
            ],
        ],
        .breathing: [
            .traditionalChinese: [
                "讓呼吸保持自然，不用刻意變深或變慢。",
                "吸氣的時候，感覺空氣輕輕進來；吐氣的時候，讓身體再放鬆一點。",
                "如果思緒飄走了，沒關係，注意到了就輕輕回到呼吸上。",
                "再給自己幾次這樣的呼吸，每一次吐氣都放掉一點點緊繃。",
            ],
            .english: [
                "Let your breath stay natural — no need to make it deeper or slower.",
                "As you breathe in, feel the air arrive gently; as you breathe out, let your body soften a little more.",
                "If your mind wanders, that's okay. Just notice, and gently return to the breath.",
                "Give yourself a few more breaths like this, releasing a little tension with each exhale.",
            ],
        ],
        .reflection: [
            .traditionalChinese: [
                "現在，讓心裡掛著的事浮現一下，不用抓住它，只是看著。",
                "你不需要現在就有答案，允許事情暫時停在「還不知道」。",
                "注意一下心裡最需要被照顧的那個部分，對它點個頭。",
                "那些放不下的，先讓它們待在旁邊，陪你一起呼吸。",
            ],
            .english: [
                "Now, let whatever has been on your mind surface for a moment — no need to grab it, just watch.",
                "You don't need an answer right now. Let things rest in \u{201C}not knowing yet.\u{201D}",
                "Notice the part of you that most needs care today, and give it a small nod.",
                "The things you can't put down — let them sit beside you and breathe with you.",
            ],
        ],
        .affirmation: [
            .traditionalChinese: [
                "跟自己說：我已經在盡力了，這樣就很好。",
                "你值得被溫柔對待，包括被你自己。",
                "慢慢來沒有關係，你的步調就是對的步調。",
                "今天的你，已經比自己以為的更勇敢了一點。",
            ],
            .english: [
                "Tell yourself: I am already doing my best, and that is enough.",
                "You deserve gentleness — including from yourself.",
                "It's okay to go slowly. Your pace is the right pace.",
                "You have already been a little braver today than you think.",
            ],
        ],
        .closing: [
            .traditionalChinese: [
                "慢慢把注意力帶回身體，動一動手指和腳趾。",
                "帶著這份平靜，輕輕回到現在的空間。",
                "準備好了，就睜開眼睛。Twinko 一直都在。",
                "接下來的時間，記得你隨時可以回到這裡。",
            ],
            .english: [
                "Slowly bring your attention back to your body — wiggle your fingers and toes.",
                "Carry this calm gently back into the space around you.",
                "When you're ready, open your eyes. Twinko is always here.",
                "Remember — you can come back to this place whenever you need.",
            ],
        ],
    ]

    private static let closingMessages: [AppLanguage: [String]] = [
        .traditionalChinese: [
            "你剛剛為自己留了一點空間，這件事本身就很溫柔。",
            "不用急著變好，此刻的你已經足夠。",
            "把這份安穩帶著走，需要的時候隨時回來。",
        ],
        .english: [
            "You just made a little space for yourself — that alone is a gentle thing.",
            "There's no rush to feel better. Who you are right now is enough.",
            "Take this steadiness with you, and come back whenever you need.",
        ],
    ]
}
