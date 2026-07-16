import SwiftUI

/// The Meditation MVP flow as one contained stage machine:
/// setup (focus + duration + optional input, with subtle Chat/Tarot
/// source acknowledgment) → generating → text-guided session →
/// completion. Entered directly from Home or with a prefilled source
/// context from Chat / Tarot; exiting at any point returns safely to
/// the previous flow.
struct MeditationFlowView: View {
    enum Stage {
        case setup, generating, session, completion, error
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var prefs: PrefsStore

    let sourceContext: MeditationSourceContext
    private let provider: MeditationGenerating = MockMeditationProvider()

    @State private var stage: Stage = .setup
    @State private var focus: MeditationFocus = .calmDown
    @State private var duration: MeditationDuration = .five
    @State private var customInput: String = ""
    @State private var result: MeditationGenerationResult?
    @State private var segmentIndex = 0
    @State private var mood: MeditationMood?
    @State private var showingEndConfirm = false

    init(sourceContext: MeditationSourceContext = .direct) {
        self.sourceContext = sourceContext
        // Preselect Twinko's recommendation when one was handed over;
        // the user can always change it.
        _focus = State(initialValue: sourceContext.recommendedFocus ?? .calmDown)
    }

    /// Recommendations exist only for handoff-derived sessions.
    private var recommendedFocus: MeditationFocus? { sourceContext.recommendedFocus }
    private var recommendedDuration: MeditationDuration? {
        sourceContext.recommendedFocus != nil ? .five : nil
    }

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                stageContent
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
        .confirmationDialog(MeditationStrings.endEarlyTitle(lang),
                            isPresented: $showingEndConfirm,
                            titleVisibility: .visible) {
            Button(MeditationStrings.endSession(lang), role: .destructive) {
                advance(to: .completion)
            }
            Button(MeditationStrings.keepGoing(lang), role: .cancel) {}
        } message: {
            Text(MeditationStrings.endEarlyBody(lang))
        }
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
                                           segmentIndex: $segmentIndex,
                                           lang: lang) {
                        advance(to: .completion)
                    }
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
        withAnimation(.easeInOut(duration: 0.3)) { stage = next }
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            Text(MeditationStrings.title(lang))
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.textInverseToken)
            HStack {
                Button {
                    if stage == .session {
                        showingEndConfirm = true
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
        }
        .padding(.horizontal, 8)
        .frame(height: 48)
    }

    // MARK: Setup

    private var setupStage: some View {
        ScrollView {
            VStack(spacing: TwinkoSpacing.m) {
                Image("twinko_meditation_calm_v1_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
                    .padding(.top, TwinkoSpacing.s)
                    .accessibilityHidden(true)

                VStack(spacing: 5) {
                    Text(MeditationStrings.heroTitle(lang))
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color.textInverseToken)
                    Text(MeditationStrings.heroSubtitle(lang))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TwinkoSpacing.l)
                }

                if let acknowledgment = sourceAcknowledgment {
                    sourceCard(acknowledgment)
                }

                // Focus themes (with Twinko's recommendation marked)
                VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                    Text(MeditationStrings.focusSection(lang))
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.textInverseToken)
                    if recommendedFocus != nil {
                        Text(MeditationStrings.twinkoRecommends(lang))
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Color.twinkoGold.opacity(0.85))
                    }
                    FlowHStack(spacing: TwinkoSpacing.s) {
                        ForEach(MeditationFocus.allCases) { option in
                            let selected = focus == option
                            let recommended = option == recommendedFocus
                            Button {
                                focus = option
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: selected ? "checkmark.circle.fill" : option.icon)
                                        .font(.system(size: 13))
                                    Text(recommended
                                         ? "\(option.label(lang)) · \(MeditationStrings.recommendedTag(lang))"
                                         : option.label(lang))
                                        .font(.system(.subheadline, design: .rounded))
                                }
                                .padding(.horizontal, 13)
                                .padding(.vertical, 8)
                                .frame(minHeight: 40)
                                .background(
                                    selected ? AnyShapeStyle(
                                        LinearGradient(colors: [.brandPurple, .brandPurpleDeep],
                                                       startPoint: .top, endPoint: .bottom))
                                             : AnyShapeStyle(Color.deepSpace.opacity(0.4)),
                                    in: Capsule()
                                )
                                .foregroundStyle(Color.textInverseToken)
                                .overlay(Capsule().strokeBorder(
                                    selected ? Color.twinkoGold.opacity(0.6) : Color.clear,
                                    lineWidth: 1))
                            }
                            .accessibilityAddTraits(selected ? [.isSelected] : [])
                            .accessibilityLabel(Text(accessibilityFocusLabel(option,
                                                                              selected: selected,
                                                                              recommended: recommended)))
                            .accessibilityIdentifier("meditationFocus-\(option.rawValue)")
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, TwinkoSpacing.m)

                // Duration (with recommendation marked)
                VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                    Text(MeditationStrings.durationSection(lang))
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.textInverseToken)
                    HStack(spacing: TwinkoSpacing.s) {
                        ForEach(MeditationDuration.allCases) { option in
                            let selected = duration == option
                            let recommended = option == recommendedDuration
                            Button {
                                duration = option
                            } label: {
                                VStack(spacing: 1) {
                                    HStack(spacing: 4) {
                                        if selected {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10, weight: .bold))
                                        }
                                        Text(option.label(lang))
                                            .font(.system(.subheadline, design: .rounded).weight(.medium))
                                    }
                                    if recommended {
                                        Text(MeditationStrings.recommendedTag(lang))
                                            .font(.system(size: 9, design: .rounded))
                                            .foregroundStyle(Color.twinkoGold)
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(
                                    selected ? Color.menuDeep : Color.deepSpace.opacity(0.4),
                                    in: RoundedRectangle(cornerRadius: 14)
                                )
                                .foregroundStyle(Color.textInverseToken)
                                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(
                                    selected ? Color.twinkoGold.opacity(0.6) : Color.clear,
                                    lineWidth: 1))
                            }
                            .accessibilityAddTraits(selected ? [.isSelected] : [])
                            .accessibilityLabel(Text(accessibilityDurationLabel(option,
                                                                                 selected: selected,
                                                                                 recommended: recommended)))
                            .accessibilityIdentifier("meditationDuration-\(option.rawValue)")
                        }
                    }
                }
                .padding(.horizontal, TwinkoSpacing.m)

                // Optional supplemental input — never asks the user to
                // re-explain accepted context.
                VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                    Text(sourceContext.sourceType == .direct
                         ? MeditationStrings.customInputLabel(lang)
                         : MeditationStrings.supplementLabel(lang))
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.textInverseToken)
                    TextField("", text: $customInput,
                              prompt: Text(sourceContext.sourceType == .direct
                                           ? MeditationStrings.customInputPlaceholder(lang)
                                           : MeditationStrings.supplementPlaceholder(lang))
                                  .foregroundStyle(Color.textInverseToken.opacity(0.45)),
                              axis: .vertical)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.textInverseToken)
                        .tint(.twinkoGold)
                        .lineLimit(1...3)
                        .padding(12)
                        .background(Color.deepSpace.opacity(0.4),
                                    in: RoundedRectangle(cornerRadius: 14))
                        .accessibilityIdentifier("meditationCustomInput")
                }
                .padding(.horizontal, TwinkoSpacing.m)
                .padding(.bottom, TwinkoSpacing.m)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        // Sticky generation CTA: content scrolls, the button stays
        // pinned above the bottom safe area (and above the keyboard).
        .safeAreaInset(edge: .bottom) {
            Button {
                advance(to: .generating)
                Task { await generate() }
            } label: {
                Text(MeditationStrings.start(lang))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.twinkoPrimary)
            .padding(.horizontal, TwinkoSpacing.m)
            .padding(.top, TwinkoSpacing.s)
            .padding(.bottom, TwinkoSpacing.s)
            .background(
                LinearGradient(colors: [Color.deepSpace.opacity(0), Color.deepSpace.opacity(0.55)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(edges: .bottom)
                    .allowsHitTesting(false)
            )
            .accessibilityIdentifier("meditationStartButton")
        }
    }

    private func accessibilityFocusLabel(_ option: MeditationFocus, selected: Bool,
                                         recommended: Bool) -> String {
        var parts = [option.label(lang)]
        if recommended {
            parts.append(lang == .english ? "recommended" : "Twinko 建議")
        }
        if selected { parts.append(lang == .english ? "selected" : "已選取") }
        return parts.joined(separator: lang == .english ? ", " : "，")
    }

    private func accessibilityDurationLabel(_ option: MeditationDuration, selected: Bool,
                                            recommended: Bool) -> String {
        var parts = [option.label(lang)]
        if recommended {
            parts.append(lang == .english ? "recommended" : "Twinko 建議")
        }
        if selected { parts.append(lang == .english ? "selected" : "已選取") }
        return parts.joined(separator: lang == .english ? ", " : "，")
    }

    /// Subtle source acknowledgment. For Tarot-derived sessions this is
    /// the adapted focus summary — never a copied or truncated reading
    /// paragraph.
    private var sourceAcknowledgment: (label: String, summary: String?, trust: String?)? {
        switch sourceContext.sourceType {
        case .direct:
            return nil
        case .chat:
            return (MeditationStrings.fromChat(lang),
                    sourceContext.focusSummary ?? sourceContext.recentChatSummary,
                    nil)
        case .tarot:
            return (MeditationStrings.fromTarot(lang),
                    sourceContext.focusSummary ?? sourceContext.tarotQuestion,
                    MeditationStrings.trustNote(lang))
        case .checkIn:
            return (MeditationStrings.fromCheckIn(lang),
                    sourceContext.focusSummary,
                    nil)
        }
    }

    private func sourceCard(_ acknowledgment: (label: String, summary: String?, trust: String?)) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(acknowledgment.label, systemImage: "link")
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.twinkoGold)
            if let summary = acknowledgment.summary, !summary.isEmpty {
                Text(summary)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.9))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let trust = acknowledgment.trust {
                Text(trust)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.55))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(TwinkoSpacing.m)
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
            if let acknowledgment = sourceAcknowledgment {
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
            sourceContext: sourceContext,
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
            segmentIndex = 0
            advance(to: .session)
        } catch {
            advance(to: .error)
        }
    }

    // MARK: Completion

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

                if let result {
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
                            } label: {
                                Text(option.label(lang))
                                    .font(.system(.caption, design: .rounded).weight(.medium))
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .background(
                                        selected ? Color.menuDeep : Color.deepSpace.opacity(0.4),
                                        in: RoundedRectangle(cornerRadius: 14)
                                    )
                                    .foregroundStyle(Color.textInverseToken)
                                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(
                                        selected ? Color.twinkoGold.opacity(0.6) : Color.clear,
                                        lineWidth: 1))
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
                .buttonStyle(.twinkoPrimary)
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
            .buttonStyle(.twinkoPrimary)
            .padding(.horizontal, TwinkoSpacing.xl)
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Session stage

/// Text-guided session: one segment at a time (grounding → breathing →
/// reflection → affirmation → closing) with a simple Continue/Finish
/// progression, progress dots, and the session title + duration.
private struct MeditationSessionStage: View {
    let result: MeditationGenerationResult
    @Binding var segmentIndex: Int
    let lang: AppLanguage
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var segment: MeditationSegment { result.segments[segmentIndex] }
    private var isLast: Bool { segmentIndex == result.segments.count - 1 }

    var body: some View {
        VStack(spacing: TwinkoSpacing.m) {
            VStack(spacing: 3) {
                Text(result.title)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.textInverseToken)
                    .multilineTextAlignment(.center)
                Text(result.duration.label(lang))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.65))
            }
            .padding(.horizontal, TwinkoSpacing.l)

            MeditationBreathingTwinko(size: 130)

            // Progress dots
            HStack(spacing: 7) {
                ForEach(Array(result.segments.enumerated()), id: \.element.id) { index, _ in
                    Circle()
                        .fill(index <= segmentIndex
                              ? Color.twinkoGold
                              : Color.textInverseToken.opacity(0.25))
                        .frame(width: 7, height: 7)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(MeditationStrings.segmentProgress(
                segmentIndex + 1, result.segments.count, lang)))

            // Current segment
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
            .accessibilityElement(children: .combine)

            Spacer()

            Button {
                if isLast {
                    onFinished()
                } else {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        segmentIndex += 1
                    }
                }
            } label: {
                Text(isLast ? MeditationStrings.finish(lang) : MeditationStrings.next(lang))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.twinkoPrimary)
            .padding(.horizontal, TwinkoSpacing.m)
            .padding(.bottom, TwinkoSpacing.xl)
            .accessibilityIdentifier("meditationNextButton")
        }
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
    }
}
