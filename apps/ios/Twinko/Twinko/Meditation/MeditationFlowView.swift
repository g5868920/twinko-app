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
            // The v2 moonlit scene is bright; the shared readability
            // veil grounds the white text and lets the night glass
            // read against the moon and clouds (asset untouched).
            TwinkoFullScreenBackground(imageName: "bg_meditation_v2",
                                       topOpacity: 0.45, bottomOpacity: 0.58)
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

    /// Guided setup reads as one scene: at standard Dynamic Type on a
    /// modern iPhone it fits without scrolling; `ViewThatFits` falls
    /// back to a scroll only for small devices, Accessibility Dynamic
    /// Type, or the open keyboard. A greedy outer frame keeps the
    /// stage (and the flow background) full-screen.
    private var setupStage: some View {
        ViewThatFits(in: .vertical) {
            setupContent
            ScrollView {
                setupContent
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // Sticky CTA above the bottom safe area.
        .safeAreaInset(edge: .bottom) {
            Button {
                advance(to: .generating)
                Task { await generate() }
            } label: {
                Text(MeditationStrings.begin(lang))
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

    private var setupContent: some View {
        VStack(spacing: TwinkoSpacing.s) {
            MeditationBreathingTwinko(size: 104)

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

    /// Focus options in a stable 2-column grid: content never changes
    /// with selection (the recommendation sublabel is fixed per option,
    /// never per selection), so choosing any option cannot shift the
    /// layout.
    private var focusSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(MeditationStrings.focusSection(lang))
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.textInverseToken)
            // 2×2 grid + a full-width fifth row — no orphan cell with
            // an empty slot beside it.
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8),
                                GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(Array(MeditationFocus.allCases.prefix(4))) { option in
                    selectableOption(
                        label: option.label(lang),
                        icon: option.icon,
                        selected: focus == option,
                        recommended: option == recommendedFocus,
                        identifier: "meditationFocus-\(option.rawValue)"
                    ) { focus = option }
                }
            }
            if let last = MeditationFocus.allCases.last {
                selectableOption(
                    label: last.label(lang),
                    icon: last.icon,
                    selected: focus == last,
                    recommended: last == recommendedFocus,
                    identifier: "meditationFocus-\(last.rawValue)"
                ) { focus = last }
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

    /// One stable selectable cell. The 建議 / Recommended sublabel
    /// exists only when a real recommendation does — no reserved blank
    /// caption row, no zero-opacity placeholder. Without it the main
    /// label sits vertically centered; the shared `minHeight` keeps
    /// every cell in a row the same height either way.
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
                if recommended {
                    Text(MeditationStrings.recommendedTag(lang))
                        .font(.system(size: 9.5, design: .rounded))
                        .foregroundStyle(selected ? Color(hex: 0xFFF3D6)
                                                  : Color.twinkoGold.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(
                // Night clear glass; selection is "gently illuminated"
                // translucent lavender, never a solid filled block.
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(selected
                          ? AnyShapeStyle(LinearGradient(
                                colors: [Color.brandPurple.opacity(0.55),
                                         Color.brandPurpleDeep.opacity(0.48)],
                                startPoint: .top, endPoint: .bottom))
                          : AnyShapeStyle(LinearGradient(
                                colors: [Color(hex: 0x9C8CD8).opacity(0.42),
                                         Color(hex: 0x6E5FB0).opacity(0.34)],
                                startPoint: .top, endPoint: .bottom)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(LinearGradient(stops: [
                                .init(color: Color.white.opacity(selected ? 0.20 : 0.14),
                                      location: 0),
                                .init(color: Color.white.opacity(0), location: 0.35),
                            ], startPoint: .top, endPoint: .bottom))
                    )
            )
            .foregroundStyle(Color.textInverseToken)
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(
                selected
                    ? AnyShapeStyle(LinearGradient(
                          colors: [Color.twinkoGold.opacity(0.85),
                                   Color.twinkoGold.opacity(0.45)],
                          startPoint: .top, endPoint: .bottom))
                    : AnyShapeStyle(LinearGradient(stops: [
                          .init(color: Color.white.opacity(0.40), location: 0),
                          .init(color: Color(hex: 0xD1C4FF).opacity(0.18), location: 1),
                      ], startPoint: .top, endPoint: .bottom)),
                lineWidth: 1))
            .shadow(color: selected ? Color.twinkoGold.opacity(0.30)
                                    : Color.deepSpace.opacity(0.18),
                    radius: selected ? 9 : 6, y: 3)
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
                .twinkoGlass(cornerRadius: 14, tint: 0.46, night: true)
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
            Label(acknowledgment.label, systemImage: "star.fill")
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
        .twinkoGlass(cornerRadius: TwinkoRadius.card, tint: 0.38,
                     warm: true, night: true)
        .padding(.horizontal, TwinkoSpacing.m)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("meditationSourceCard")
    }

    // MARK: Generating

    private var generatingStage: some View {
        VStack(spacing: TwinkoSpacing.l) {
            Spacer()
            MeditationBreathingTwinko(size: 150)
            VStack(spacing: 6) {
                Text(MeditationStrings.generating(lang))
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.92))
                    .multilineTextAlignment(.center)
                Text(MeditationStrings.generatingSecondary(lang))
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.65))
                    .multilineTextAlignment(.center)
            }
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

    /// The preparation state stays visible at least this long, so the
    /// ritual copy can actually be read — even when content is ready
    /// instantly (mock today, fast generation later). Slower future
    /// generation simply keeps the state up until content arrives.
    static let preparationMinimumSeconds: TimeInterval = 2.8

    /// Remaining hold after generation finished — pure and testable.
    static func remainingPreparationDelay(elapsed: TimeInterval) -> TimeInterval {
        max(0, preparationMinimumSeconds - elapsed)
    }

    private func generate() async {
        let request = MeditationGenerationRequest(
            sourceContext: effectiveContext,
            focusTopic: focus,
            duration: duration,
            customUserInput: customInput.isEmpty ? nil : customInput)
        let preparationStart = Date()
        do {
            let generated = try await provider.generate(request, lang: lang)
            // Respect the minimum preparation display without blocking
            // the main thread; the session only starts afterwards.
            let hold = Self.remainingPreparationDelay(
                elapsed: Date().timeIntervalSince(preparationStart))
            if hold > 0 {
                try? await Task.sleep(nanoseconds: UInt64(hold * 1_000_000_000))
            }
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

    /// A gentle reflection moment, not a compressed form: no normal
    /// scrolling, breathing room between sections, a softly floating
    /// Twinko, and roomy vertically stacked feeling choices in the
    /// same lavender selection family as the setup options.
    private var completionStage: some View {
        VStack(spacing: 0) {
            Spacer(minLength: TwinkoSpacing.s)

            MeditationBreathingTwinko(size: 136)

            Spacer(minLength: TwinkoSpacing.m)

            VStack(spacing: TwinkoSpacing.s) {
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
            }

            Spacer(minLength: TwinkoSpacing.l)

            VStack(spacing: TwinkoSpacing.s) {
                Text(MeditationStrings.moodQuestion(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.textInverseToken)
                    .padding(.bottom, 2)
                ForEach(MeditationMood.allCases) { option in
                    moodChoice(option)
                }
            }
            // Same horizontal inset as the Done CTA below so the
            // feeling choices and the primary button share one width.
            .padding(.horizontal, TwinkoSpacing.m)

            Spacer(minLength: TwinkoSpacing.xl)

            Button {
                dismiss()
            } label: {
                Text(MeditationStrings.done(lang))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.tarotMagicPrimary)
            .padding(.horizontal, TwinkoSpacing.m)
            .padding(.bottom, TwinkoSpacing.l)
            .accessibilityIdentifier("meditationDoneButton")
        }
    }

    /// One roomy feeling choice: full-width, 52 pt tall, lavender
    /// selection treatment matching the setup family — clearly quieter
    /// than the primary CTA, never a flat opaque block.
    private func moodChoice(_ option: MeditationMood) -> some View {
        let selected = mood == option
        return Button {
            mood = option
            if let recordID {
                recordStore.setFinalFeeling(recordID, feeling: option)
            }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: option.icon)
                    .font(.system(size: 13))
                    .foregroundStyle(selected ? Color.twinkoGold
                                             : Color.textInverseToken.opacity(0.7))
                Text(option.label(lang))
                    .font(.system(.subheadline, design: .rounded)
                        .weight(selected ? .semibold : .regular))
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.twinkoGold)
                }
            }
            .padding(.horizontal, TwinkoSpacing.m)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                // Same illuminated night glass as the setup chips.
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(selected
                          ? AnyShapeStyle(LinearGradient(
                                colors: [Color.brandPurple.opacity(0.55),
                                         Color.brandPurpleDeep.opacity(0.48)],
                                startPoint: .top, endPoint: .bottom))
                          : AnyShapeStyle(LinearGradient(
                                colors: [Color(hex: 0x9C8CD8).opacity(0.42),
                                         Color(hex: 0x6E5FB0).opacity(0.34)],
                                startPoint: .top, endPoint: .bottom)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(LinearGradient(stops: [
                                .init(color: Color.white.opacity(selected ? 0.20 : 0.14),
                                      location: 0),
                                .init(color: Color.white.opacity(0), location: 0.35),
                            ], startPoint: .top, endPoint: .bottom))
                    )
            )
            .foregroundStyle(Color.textInverseToken)
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(
                selected
                    ? AnyShapeStyle(LinearGradient(
                          colors: [Color.twinkoGold.opacity(0.85),
                                   Color.twinkoGold.opacity(0.45)],
                          startPoint: .top, endPoint: .bottom))
                    : AnyShapeStyle(LinearGradient(stops: [
                          .init(color: Color.white.opacity(0.40), location: 0),
                          .init(color: Color(hex: 0xD1C4FF).opacity(0.18), location: 1),
                      ], startPoint: .top, endPoint: .bottom)),
                lineWidth: 1))
            .shadow(color: selected ? Color.twinkoGold.opacity(0.30)
                                    : Color.deepSpace.opacity(0.18),
                    radius: selected ? 9 : 6, y: 3)
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .accessibilityAddTraits(selected ? [.isSelected] : [])
        .accessibilityLabel(Text(optionAccessibilityLabel(option.label(lang),
                                                          selected: selected,
                                                          recommended: false)))
        .accessibilityIdentifier("meditationMood-\(option.rawValue)")
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

    /// Ring progress derived purely from the existing session clock —
    /// the playback controller stays the only timer and source of
    /// truth; this is a visual representation only.
    private var countdownProgress: Double {
        let total = result.duration.rawValue * 60
        guard total > 0 else { return 0 }
        return 1 - Double(playback.remainingSeconds) / Double(total)
    }

    var body: some View {
        VStack(spacing: TwinkoSpacing.m) {
            Text(result.title)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.textInverseToken)
                .multilineTextAlignment(.center)
                .padding(.horizontal, TwinkoSpacing.l)

            // Twinko inside the calm countdown ring: soft lavender
            // track, gentle lavender→gold progress, remaining time
            // beneath — one ambient element, not a fitness gauge.
            VStack(spacing: TwinkoSpacing.s) {
                ZStack {
                    Circle()
                        .stroke(Color.textInverseToken.opacity(0.14), lineWidth: 3)
                    Circle()
                        .trim(from: 0, to: countdownProgress)
                        .stroke(
                            AngularGradient(
                                colors: [Color(red: 0.80, green: 0.72, blue: 0.95),
                                         Color.twinkoGold.opacity(0.85)],
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360 * countdownProgress)),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(reduceMotion ? nil : .linear(duration: 1),
                                   value: countdownProgress)
                    MeditationBreathingTwinko(size: 124)
                }
                .frame(width: 186, height: 186)

                Text(remainingLabel)
                    .font(.system(.title3, design: .rounded).weight(.medium))
                    .foregroundStyle(Color.textInverseToken.opacity(0.92))
                    .monospacedDigit()
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(MeditationStrings.remainingAccessible(
                playback.remainingSeconds / 60, playback.remainingSeconds % 60, lang)))

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
            .twinkoGlass(cornerRadius: TwinkoRadius.card, tint: 0.44, night: true)
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
                .background(
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: 0x9C8CD8).opacity(0.42),
                                     Color(hex: 0x6E5FB0).opacity(0.34)],
                            startPoint: .top, endPoint: .bottom))
                        .overlay(
                            Circle().fill(LinearGradient(stops: [
                                .init(color: Color.white.opacity(0.14), location: 0),
                                .init(color: Color.white.opacity(0), location: 0.4),
                            ], startPoint: .top, endPoint: .bottom))
                        )
                )
                .overlay(Circle().strokeBorder(
                    isOn ? AnyShapeStyle(LinearGradient(
                              colors: [Color.twinkoGold.opacity(0.75),
                                       Color.twinkoGold.opacity(0.40)],
                              startPoint: .top, endPoint: .bottom))
                         : AnyShapeStyle(LinearGradient(stops: [
                              .init(color: Color.white.opacity(0.40), location: 0),
                              .init(color: Color(hex: 0xD1C4FF).opacity(0.18), location: 1),
                          ], startPoint: .top, endPoint: .bottom)),
                    lineWidth: 1))
                .shadow(color: Color.deepSpace.opacity(0.18), radius: 6, y: 3)
        }
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text(isOn ? "on" : "off"))
        .accessibilityIdentifier(identifier)
    }
}

// MARK: - Breathing Twinko

/// The canonical Meditation Twinko with a gentle floating-breath
/// cycle: ~6 pt vertical travel over a ~3 s ease-in-out cycle plus a
/// soft lavender glow breath. Used across setup, preparation, session,
/// and completion so Twinko feels alive consistently. Reduce Motion
/// shows the static image (glow fixed, no movement); the repeating
/// animation stops with the view when the screen disappears.
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
                .opacity(reduceMotion ? 0.22 : (breathing ? 0.30 : 0.18))
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
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
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
