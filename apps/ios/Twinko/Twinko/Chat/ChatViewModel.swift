import Foundation

enum ChatState: Equatable {
    case idle
    case loading
    case success
    case error
}

/// Drives one Chat session. Messages live in memory while chatting and
/// are persisted through `ChatStore` (Codable JSON, local only) after
/// every exchange, so sessions survive relaunch per D-054.
@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage]
    @Published private(set) var state: ChatState = .idle
    @Published var draftText: String = ""
    /// The single conversation-level meditation confirmation offer —
    /// explicit requests and proactive suggestions share this state,
    /// so two cards can never appear at once.
    @Published private(set) var meditationOffer: ChatMeditationOffer?
    /// The single conversation-level Tarot suggestion (Task 3) — never
    /// shown alongside a meditation offer.
    @Published private(set) var tarotOffer: ChatTarotOffer?

    /// Attached by the view; optional so unit tests can run pure
    /// in-memory conversations.
    weak var store: ChatStore?

    private let service: MockChatServicing
    private let loadingDelayNanoseconds: UInt64
    private let titleGenerator: ChatTitleGenerating = LocalChatTitleGenerator()
    private var session: ChatSession

    nonisolated init(session: ChatSession = ChatSession(),
                     service: MockChatServicing = MockChatService(),
                     loadingDelayNanoseconds: UInt64 = 500_000_000) {
        self.session = session
        self.service = service
        self.loadingDelayNanoseconds = loadingDelayNanoseconds
        _messages = Published(initialValue: session.messages)
    }

    var sessionID: UUID { session.id }

    /// Sends the current draft. `lang` is the app locale at the moment
    /// of sending — newly produced Twinko replies match it; stored
    /// history is never retroactively translated.
    func send(lang: AppLanguage = .traditionalChinese) {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, state != .loading else { return }

        append(ChatMessage(sender: .user, text: trimmed))
        draftText = ""
        state = .loading

        Task {
            try? await Task.sleep(nanoseconds: loadingDelayNanoseconds)
            respond(to: trimmed, lang: lang)
        }
    }

    /// Response routing priority: explicit feature intent (Meditation)
    /// is handled before the generic scripted/fallback responses, so a
    /// clear "我想要冥想" can never be answered with a stale
    /// misunderstanding reply. (The dev-only error triggers contain no
    /// meditation keywords, so they still exercise the fallback path.)
    private func respond(to input: String, lang: AppLanguage) {
        if MeditationIntentDetector.detect(input) == .requestIntent {
            let ack = ChatMessage(sender: .twinko,
                                  text: ChatStrings.meditationAckMessage(for: input))
            append(ack)
            state = .success
            // An explicit request may reopen confirmation even after a
            // declined proactive offer.
            meditationOffer = ChatMeditationOffer(source: .explicitRequest,
                                                  messageID: ack.id)
            maybeGenerateTitle()
            return
        }

        switch service.response(for: input, lang: lang) {
        case .success(let text):
            let reply = ChatMessage(sender: .twinko, text: text)
            append(reply)
            state = .success
            // Deterministic Tarot suggestion first (Task 3): it reacts
            // to this specific message; the proactive meditation offer
            // stays the generic fallback. Never both at once.
            if !maybeOfferTarot(for: input, after: reply, lang: lang) {
                maybeOfferProactiveMeditation(after: reply)
            }
        case .fallback(let text):
            append(ChatMessage(sender: .twinko, text: text))
            state = .error
        }
        maybeGenerateTitle()
    }

    /// Contextual Tarot suggestion: at most once per conversation
    /// (persisted on the session), never while another offer is
    /// visible, keyword-deterministic — no free-text classification.
    private func maybeOfferTarot(for input: String, after reply: ChatMessage,
                                 lang: AppLanguage) -> Bool {
        guard tarotOffer == nil, meditationOffer == nil,
              !session.tarotOfferResolved,
              let context = ChatTarotSuggestor.context(for: input, lang: lang)
        else { return false }
        tarotOffer = ChatTarotOffer(context: context, messageID: reply.id)
        session.tarotOfferResolved = true
        store?.upsert(session)
        return true
    }

    /// Decline: dismiss silently; no further Tarot suggestions this
    /// conversation.
    func declineTarotOffer() {
        tarotOffer = nil
    }

    /// Accept: resolve the offer and hand back the shared entry
    /// context for the Task 1 setup. No draft, session, or cards are
    /// created here.
    func acceptTarotOffer() -> TarotEntryContext? {
        let context = tarotOffer?.context
        tarotOffer = nil
        return context
    }

    /// Proactive suggestion: at most once per conversation (persisted
    /// on the session), only after a meaningful exchange, never while
    /// another offer is visible.
    private func maybeOfferProactiveMeditation(after reply: ChatMessage) {
        guard meditationOffer == nil,
              !session.meditationProactiveOfferResolved,
              messages.filter({ $0.sender == .user }).count >= 1 else { return }
        meditationOffer = ChatMeditationOffer(source: .proactiveSuggestion,
                                              messageID: reply.id)
        session.meditationProactiveOfferResolved = true
        store?.upsert(session)
    }

    /// Decline: dismiss silently — no "好的" reply, no further
    /// proactive offers this conversation; explicit requests stay
    /// available.
    func declineMeditationOffer() {
        meditationOffer = nil
    }

    /// Accept: resolve the offer and hand back the adapted context for
    /// navigation to the Meditation Context Review.
    func acceptMeditationOffer(lang: AppLanguage) -> MeditationSourceContext {
        meditationOffer = nil
        return ChatMeditationContextAdapter.context(for: messages, lang: lang)
    }

    /// Resets this view model to a brand-new empty conversation; all
    /// previous conversations remain persisted untouched.
    func startNewSession() {
        session = ChatSession()
        messages = []
        draftText = ""
        state = .idle
        meditationOffer = nil
        tarotOffer = nil
    }

    /// Automatic topic title once the first exchange exists. Only ever
    /// writes while the title is auto-owned and still empty — a manual
    /// rename (titleSource == .user) is never overwritten.
    private func maybeGenerateTitle() {
        syncTitleFromStore()
        guard session.titleSource == .auto, session.title.isEmpty,
              let generated = titleGenerator.title(for: messages) else { return }
        session.title = generated
        store?.upsert(session)
    }

    private func append(_ message: ChatMessage) {
        messages.append(message)
        syncTitleFromStore()
        session.messages = messages
        session.updatedAt = .now
        store?.upsert(session)
    }

    /// The store owns rename state; refresh before persisting so a
    /// stale local copy never clobbers a user-set title.
    private func syncTitleFromStore() {
        if let stored = store?.session(with: session.id) {
            session.title = stored.title
            session.titleSource = stored.titleSource
        }
    }
}
