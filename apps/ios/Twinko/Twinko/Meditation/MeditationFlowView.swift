import SwiftUI

/// The Meditation flow as one contained stage machine: compact setup
/// (context card for personalized entries, stable focus/duration
/// selectors, optional note) → generating → one continuous
/// auto-progressing guided session (narration + ambient boundaries) →
/// completion → lightweight reflection. Entered generally from
/// Explore/Home or personalized from Chat / Tarot / check-in; the
/// bottom navigation stays hidden for the whole flow.
struct MeditationFlowView: View {
    enum Stage {
        case setup, generating, session, completion, error
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var prefs: PrefsStore
    @EnvironmentObject private var chrome: ShellChrome
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let sourceContext: MeditationSourceContext
    private let provider: MeditationGenerating = MockMeditationProvider()

    @StateObject private var playback = MeditationPlaybackController()
    @StateObject private var recordStore = MeditationRecordStore()

    @State private var stage: Stage = .setup
    @State private var focus: MeditationFocus = .calmDown
    @State private var duration: MeditationDuration = .five
    @State private var customInput: String = ""
    @State private var result: MeditationGenerationResult?
    @State private var mood: MeditationMood?
    @State private var showingEndConfirm = false
    /// "改用一般冥想": drops the source context for this run.
    @State private var useGeneral = false
    @State private var recordID: UUID?
    @State private var endedEarly = false
    @State private var immersiveToken = UUID()

    init(sourceContext: MeditationSourceContext = .direct) {
        self.sourceContext = sourceContext
        // Preselect Twinko's recommendation when one was handed over;
        // the user can always change it.
        _focus = State(initialValue: sourceContext.recommendedFocus ?? .calmDown)
    }

    /// The context actually used for generation: personalized entries
    /// fall back to a plain general session when the user opts out —
    /// no source summary flows into generation. Pure and testable.
    static func effectiveContext(_ context: MeditationSourceContext,
                                 useGeneral: Bool) -> MeditationSourceContext {
        useGeneral ? .direct : context
    }

    private var effectiveContext: MeditationSourceContext {
        Self.effectiveContext(sourceContext, useGeneral: useGeneral)
    }

    private var isPersonalized: Bool { effectiveContext.sourceType != .direct }

    /// Recommendations exist only for handoff-derived sessions.
    private var recommendedFocus: MeditationFocus? {
        isPersonalized ? sourceContext.recommendedFocus : nil
    }
    private var recommendedDuration: MeditationDuration? {
        recommendedFocus != nil ? .five : nil
    }

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                stageContent
            }

            if showingEndConfirm {
                endConfirmModal
            }
        }
        .background {
            GeometryReader { geo in
                Image("bg_meditation_cosmic_calm_v1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .accessibilityHidden(true)
            }
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Immersive Meditation: registers its token so the bottom
            // navigation stays hidden while this flow is on screen.
            chrome.setImmersive(immersiveToken, active: true)
        }
        .onDisappear {
            chrome.setImmersive(immersiveToken, active: false)
            playback.stop()
        }
        .animation(.easeOut(duration: 0.2), value: showingEndConfirm)
    }

    @ViewBuilder
    private var stageContent: some View {
        Group {
            switch stage {
            case .setup:
                setupStage
            case .generating:
                generatingStage
            case .session:
                if let result {
                    MeditationSessionStage(result: result,
                                           playback: playback,
                                           lang: lang)
                }
            case .completion:
                completionStage
            case .error:
                errorStage
            }
        }
        .transition(.opacity)
    }

    private func advance(to next: Stage) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) { stage = next }
    }

    // MARK: Header (no page title — Back, or a quiet session close)

    private var header: some View {
        HStack {
            Button {
                if stage == .session {
                    playback.pause()
                    showingEndConfirm = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: stage == .session ? "xmark" : "chevron.backward")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.textInverseToken.opacity(0.9))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel(Text(stage == .session
                ? MeditationStrings.endSession(lang)
                : (lang == .english ? "Back" : "返回")))
            .accessibilityIdentifier("meditationBackButton")
            Spacer()
        }
        .padding(.horizontal, 8)
        .frame(height: 44)
    }

    // MARK: Setup (compact — fits without scrolling on standard phones)

    private var setupStage: some View {
        ScrollView {
            VStack(spacing: TwinkoSpacing.s) {
                MeditationBreathingTwinko(size: 92)

                VStack(spacing: 4) {
                    Text(MeditationStrings.heroTitle(lang))
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color.textInverseToken)
                    Text(MeditationStrings.heroSubtitle(lang))
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TwinkoSpacing.l)
                }

                if isPersonalized, let acknowledgment = sourceAcknowledgment {
                    sourceCard(acknowledgment)
                    Button {
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
                            useGeneral = true
                            focus = .calmDown
                        }
                    } label: {
                        Text(MeditationStrings.useGeneralInstead(lang))
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(Color.textInverseToken.opacity(0.7))
                            .underline()
                            .frame(minHeight: 32)
                    }
                    .accessibilityIdentifier("meditationUseGeneral")
                }

                focusSection
                durationSection
                noteSection
            }
            .padding(.top, 2)
        }
        .scrollDismissesKeyboard(.interactively)
        // Sticky CTA above the bottom safe area.
        .safeAreaInset(edge: .bottom) {
            Button {
                advance(to: .generating)
                Task { await generate() }
            } label: {
                Text(isPersonalized ? MeditationStrings.startPersonalized(lang)
                                    : MeditationStrings.startGeneral(lang))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.tarotMagicPrimary)
            .padding(.horizontal, TwinkoSpacing.m)
            .padding(.vertical, TwinkoSpacing.s)
            .background(
                LinearGradient(colors: [Color.deepSpace.opacity(0), Color.deepSpace.opacity(0.55)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(edges: .bottom)
                    .allowsHitTesting(false)
            )
            .accessibilityIdentifier("meditationStartButton")
        }
    }

    /// Focus options in a stable 2-column grid: content never changes
    /// with selection, and every cell reserves the caption line, so
    /// choosing any option (準備入睡 included) cannot shift the layout.
    private var focusSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(MeditationStrings.focusSection(lang))
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.textInverseToken)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8),
                                GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(MeditationFocus.allCases) { option in
                    selectableOption(
                        label: option.label(lang),
                        icon: option.icon,
                        selected: focus == option,
                        recommended: option == recommendedFocus,
                        identifier: "meditationFocus-\(option.rawValue)"
                    ) { focus = option }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, TwinkoSpacing.m)
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(MeditationStrings.durationSection(lang))
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.textInverseToken)
            HStack(spacing: 8) {
                ForEach(MeditationDuration.allCases) { option in
                    selectableOption(
                        label: option.label(lang),
                        icon: nil,
                        selected: duration == option,
                        recommended: option == recommendedDuration,
                        identifier: "meditationDuration-\(option.rawValue)"
                    ) { duration = option }
                }
            }
        }
        .padding(.horizontal, TwinkoSpacing.m)
    }

    /// One stable selectable cell: fixed content, a reserved secondary
    /// caption row (建議 / blank), selection expressed by fill + border
    /// + weight — never by inserting elements that move the frame.
    private func selectableOption(label: String, icon: String?, selected: Bool,
                                  recommended: Bool, identifier: String,
                                  action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 1) {
                HStack(spacing: 5) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 12))
                            .foregroundStyle(selected ? Color.twinkoGold
                                                      : Color.textInverseToken.opacity(0.8))
                    }
                    Text(label)
                        .font(.system(.subheadline, design: .rounded)
                            .weight(selected ? .semibold : .regular))
                }
                // Reserved caption region keeps every cell's height
                // identical whether or not it is recommended.
                Text(recommended ? MeditationStrings.recommendedTag(lang) : " ")
                    .font(.system(size: 9.5, design: .rounded))
                    .foregroundStyle(Color.twinkoGold.opacity(recommended ? 0.9 : 0))
            }
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(
                selected ? AnyShapeStyle(
                    LinearGradient(colors: [.brandPurple, .brandPurpleDeep],
                                   startPoint: .top, endPoint: .bottom))
                         : AnyShapeStyle(Color.deepSpace.opacity(0.4)),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .foregroundStyle(Color.textInverseToken)
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(
                selected ? Color.twinkoGold.opacity(0.6)
                         : Color.textInverseToken.opacity(0.12),
                lineWidth: 1))
            .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .accessibilityAddTraits(selected ? [.isSelected] : [])
        .accessibilityLabel(Text(optionAccessibilityLabel(label, selected: selected,
                                                          recommended: recommended)))
        .accessibilityIdentifier(identifier)
    }

    private func optionAccessibilityLabel(_ label: String, selected: Bool,
                                          recommended: Bool) -> String {
        var parts = [label]
        if recommended { parts.append(lang == .english ? "recommended" : "Twinko 建議") }
        if selected { parts.append(lang == .english ? "selected" : "已選取") }
        return parts.joined(separator: lang == .english ? ", " : "，")
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(MeditationStrings.supplementLabel(lang))
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.textInverseToken)
            TextField("", text: $customInput,
                      prompt: Text(MeditationStrings.supplementPlaceholder(lang))
                          .foregroundStyle(Color.textInverseToken.opacity(0.45)),
                      axis: .vertical)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textInverseToken)
                .tint(.twinkoGold)
                .lineLimit(1...3)
                .padding(10)
                .background(Color.deepSpace.opacity(0.4),
                            in: RoundedRectangle(cornerRadius: 14))
                .accessibilityIdentifier("meditationCustomInput")
        }
        .padding(.horizontal, TwinkoSpacing.m)
        .padding(.bottom, TwinkoSpacing.s)
    }

    /// Concise source context: label + one short emotional summary —
    /// no raw source content, no processing explanation.
    private var sourceAcknowledgment: (label: String, summary: String?)? {
        switch sourceContext.sourceType {
        case .direct:
            return nil
        case .chat:
            return (MeditationStrings.fromChat(lang),
                    sourceContext.focusSummary ?? sourceContext.recentChatSummary)
        case .tarot:
            return (MeditationStrings.fromTarot(lang),
                    sourceContext.focusSummary)
        case .checkIn:
            return (MeditationStrings.fromCheckIn(lang),
                    sourceContext.focusSummary)
        }
    }

    private func sourceCard(_ acknowledgment: (label: String, summary: String?)) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(acknowledgment.label, systemImage: "link")
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.twinkoGold)
            if let summary = acknowledgment.summary, !summary.isEmpty {
                Text(summary)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.9))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.menuDeep.opacity(0.5),
                    in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
        .overlay(RoundedRectangle(cornerRadius: TwinkoRadius.card)
            .strokeBorder(Color.twinkoGold.opacity(0.3), lineWidth: 1))
        .padding(.horizontal, TwinkoSpacing.m)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("meditationSourceCard")
    }

    // MARK: Generating

    private var generatingStage: some View {
        VStack(spacing: TwinkoSpacing.l) {
            Spacer()
            MeditationBreathingTwinko(size: 150)
            Text(MeditationStrings.generating(lang))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, TwinkoSpacing.xl)
            if isPersonalized, let acknowledgment = sourceAcknowledgment {
                Text(acknowledgment.label)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.twinkoGold.opacity(0.8))
            }
            Spacer()
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }

    private func generate() async {
        let request = MeditationGenerationRequest(
            sourceContext: effectiveContext,
            focusTopic: focus,
            duration: duration,
            customUserInput: customInput.isEmpty ? nil : customInput)
        // Brief deterministic beat so the preparation state reads
        // calmly (mock generation itself is instant).
        try? await Task.sleep(nanoseconds: 900_000_000)
        do {
            let generated = try await provider.generate(request, lang: lang)
            guard generated.isValid else {
                advance(to: .error)
                return
            }
            result = generated
            beginSession(with: generated)
        } catch {
            advance(to: .error)
        }
    }

    /// Starts playback and registers the session record.
    private func beginSession(with generated: MeditationGenerationResult) {
        endedEarly = false
        mood = nil
        recordID = recordStore.beginSession(
            source: effectiveContext.sourceType,
            sourceSummary: effectiveContext.focusSummary,
            focus: focus, duration: duration,
            optionalNote: customInput.isEmpty ? nil : customInput)
        playback.onComplete = { finishSession(completed: true) }
        playback.start(result: generated, lang: lang)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        advance(to: .session)
    }

    /// One shared exit point for natural completion and early end.
    private func finishSession(completed: Bool) {
        endedEarly = !completed
        if let recordID { recordStore.endSession(recordID, completed: completed) }
        if completed {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        advance(to: .completion)
    }

    // MARK: Exit confirmation (branded — never a system action sheet)

    private var endConfirmModal: some View {
        BrandedModal(
            icon: "moon.stars.fill",
            iconColor: .brandPurpleDeep,
            title: MeditationStrings.endEarlyTitle(lang),
            content: {
                Text(MeditationStrings.endEarlyBody(lang))
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.textSecondaryToken)
                    .multilineTextAlignment(.center)
            },
            cancelTitle: MeditationStrings.keepGoing(lang),
            confirmTitle: MeditationStrings.endSession(lang),
            isDestructive: true,
            onCancel: {
                showingEndConfirm = false
                playback.resume()
            },
            onConfirm: {
                showingEndConfirm = false
                playback.stop()
                finishSession(completed: false)
            }
        )
        .transition(.opacity)
    }

    // MARK: Completion + reflection

    private var completionStage: some View {
        ScrollView {
            VStack(spacing: TwinkoSpacing.m) {
                Spacer(minLength: TwinkoSpacing.xl)
                Image("twinko_meditation_calm_v1_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .accessibilityHidden(true)

                Text(MeditationStrings.completionTitle(lang))
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.textInverseToken)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TwinkoSpacing.l)

                if !endedEarly, let result {
                    Text(result.closingMessage)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TwinkoSpacing.l)
                }

                VStack(spacing: TwinkoSpacing.s) {
                    Text(MeditationStrings.moodQuestion(lang))
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.textInverseToken)
                    HStack(spacing: TwinkoSpacing.s) {
                        ForEach(MeditationMood.allCases) { option in
                            let selected = mood == option
                            Button {
                                mood = option
                                if let recordID {
                                    recordStore.setFinalFeeling(recordID, feeling: option)
                                }
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            } label: {
                                HStack(spacing: 4) {
                                    if selected {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(Color.twinkoGold)
                                    }
                                    Text(option.label(lang))
                                        .font(.system(.caption, design: .rounded)
                                            .weight(selected ? .semibold : .medium))
                                }
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(
                                    selected ? Color.menuDeep : Color.deepSpace.opacity(0.4),
                                    in: RoundedRectangle(cornerRadius: 14)
                                )
                                .foregroundStyle(Color.textInverseToken)
                                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(
                                    selected ? Color.twinkoGold.opacity(0.7)
                                             : Color.textInverseToken.opacity(0.12),
                                    lineWidth: selected ? 1.4 : 1))
                            }
                            .accessibilityAddTraits(selected ? [.isSelected] : [])
                            .accessibilityIdentifier("meditationMood-\(option.rawValue)")
                        }
                    }
                }
                .padding(.horizontal, TwinkoSpacing.m)
                .padding(.top, TwinkoSpacing.s)

                Button {
                    dismiss()
                } label: {
                    Text(MeditationStrings.done(lang))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.tarotMagicPrimary)
                .padding(.horizontal, TwinkoSpacing.m)
                .padding(.bottom, TwinkoSpacing.xl)
                .accessibilityIdentifier("meditationDoneButton")
            }
        }
    }

    // MARK: Error

    private var errorStage: some View {
        VStack(spacing: TwinkoSpacing.m) {
            Spacer()
            Image("twinko_meditation_calm_v1_transparent")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .accessibilityHidden(true)
            Text(MeditationStrings.generationFailed(lang))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, TwinkoSpacing.l)
            Button {
                advance(to: .generating)
                Task { await generate() }
            } label: {
                Text(MeditationStrings.retry(lang)).frame(maxWidth: .infinity)
            }
            .buttonStyle(.tarotMagicPrimary)
            .padding(.horizontal, TwinkoSpacing.xl)
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Session stage (auto-progressing)

/// One continuous guided session: the playback controller's clock
/// advances segments automatically, so the user can close their eyes
/// after starting. Controls are limited to pause/resume, narration,
/// ambient sound (when an approved track exists), and the header exit.
private struct MeditationSessionStage: View {
    let result: MeditationGenerationResult
    @ObservedObject var playback: MeditationPlaybackController
    let lang: AppLanguage

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var segment: MeditationSegment {
        result.segments[min(playback.segmentIndex, result.segments.count - 1)]
    }

    private var remainingLabel: String {
        let minutes = playback.remainingSeconds / 60
        let seconds = playback.remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: TwinkoSpacing.m) {
            VStack(spacing: 3) {
                Text(result.title)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.textInverseToken)
                    .multilineTextAlignment(.center)
                Text(MeditationStrings.remaining(remainingLabel, lang))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.65))
                    .monospacedDigit()
                    .accessibilityLabel(Text(MeditationStrings.remaining(remainingLabel, lang)))
            }
            .padding(.horizontal, TwinkoSpacing.l)

            MeditationBreathingTwinko(size: 130)

            // Progress dots
            HStack(spacing: 7) {
                ForEach(Array(result.segments.enumerated()), id: \.element.id) { index, _ in
                    Circle()
                        .fill(index <= playback.segmentIndex
                              ? Color.twinkoGold
                              : Color.textInverseToken.opacity(0.25))
                        .frame(width: 7, height: 7)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(MeditationStrings.segmentProgress(
                playback.segmentIndex + 1, result.segments.count, lang)))

            // Current segment — fades as the clock advances.
            VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                Label(segment.kind.label(lang), systemImage: segment.kind.icon)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.twinkoGold)
                ForEach(segment.lines, id: \.self) { line in
                    Text(line)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.94))
                        .lineSpacing(5)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(TwinkoSpacing.m)
            .background(Color.deepSpace.opacity(0.45),
                        in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
            .padding(.horizontal, TwinkoSpacing.m)
            .id(segment.id)
            .transition(reduceMotion ? .identity : .opacity)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.5),
                       value: playback.segmentIndex)
            .accessibilityElement(children: .combine)

            Spacer()

            controls
        }
    }

    /// Quiet control row: pause/resume is the primary act; narration
    /// and ambient toggles stay independent of the session clock.
    private var controls: some View {
        HStack(spacing: TwinkoSpacing.l) {
            toggleControl(icon: playback.narrationEnabled
                              ? "speaker.wave.2.fill" : "speaker.slash.fill",
                          label: MeditationStrings.narration(lang),
                          isOn: playback.narrationEnabled,
                          identifier: "meditationNarrationToggle") {
                playback.narrationEnabled.toggle()
            }

            Button {
                if playback.isPaused {
                    playback.resume()
                } else {
                    playback.pause()
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: playback.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.textInverseToken)
                    .frame(width: 64, height: 64)
                    .background(
                        LinearGradient(colors: [.brandPurple, .brandPurpleDeep],
                                       startPoint: .top, endPoint: .bottom),
                        in: Circle())
                    .overlay(Circle().strokeBorder(Color.twinkoGold.opacity(0.4),
                                                   lineWidth: 1))
                    .shadow(color: Color.brandPurpleDeep.opacity(0.4), radius: 8, y: 3)
            }
            .accessibilityLabel(Text(playback.isPaused
                ? MeditationStrings.resume(lang) : MeditationStrings.pause(lang)))
            .accessibilityIdentifier("meditationPauseResume")

            if playback.ambientAvailable {
                toggleControl(icon: playback.ambientEnabled
                                  ? "music.note" : "music.note.list",
                              label: MeditationStrings.ambientSound(lang),
                              isOn: playback.ambientEnabled,
                              identifier: "meditationAmbientToggle") {
                    playback.ambientEnabled.toggle()
                }
            } else {
                // Silent fallback: no approved ambient track is bundled
                // yet, so the control is absent and the session flows on.
                Color.clear.frame(width: 52, height: 52)
            }
        }
        .padding(.bottom, TwinkoSpacing.xl)
    }

    private func toggleControl(icon: String, label: String, isOn: Bool,
                               identifier: String,
                               action: @escaping () -> Void) -> some View {
        Button {
            action()
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isOn ? Color.twinkoGold
                                      : Color.textInverseToken.opacity(0.55))
                .frame(width: 52, height: 52)
                .background(Color.deepSpace.opacity(0.5), in: Circle())
                .overlay(Circle().strokeBorder(
                    isOn ? Color.twinkoGold.opacity(0.45)
                         : Color.textInverseToken.opacity(0.15), lineWidth: 1))
        }
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text(isOn ? "on" : "off"))
        .accessibilityIdentifier(identifier)
    }
}

// MARK: - Breathing Twinko

/// The canonical Meditation Twinko with a gentle 4–6 s breathing scale
/// cycle; Reduce Motion shows the static image.
struct MeditationBreathingTwinko: View {
    let size: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathing = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.80, green: 0.72, blue: 0.95))
                .frame(width: size * 1.15, height: size * 1.15)
                .blur(radius: 26)
                .opacity(breathing ? 0.30 : 0.18)
            Image("twinko_meditation_calm_v1_transparent")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .scaleEffect(reduceMotion ? 1.0 : (breathing ? 1.03 : 0.99))
                .offset(y: reduceMotion ? 0 : (breathing ? -3 : 3))
        }
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                breathing = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        MeditationFlowView()
            .environmentObject(PrefsStore())
            .environmentObject(ShellChrome())
    }
}
