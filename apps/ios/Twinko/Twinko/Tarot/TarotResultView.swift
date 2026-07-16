import SwiftUI

/// Interpretation / result stage. Each card shows a compact core
/// (position, art, name, orientation, keywords, 2–3 sentences) with
/// the full interpretation behind an expand control; the three-card
/// synthesis and Twinko's short closing message are distinct sections
/// fed by different provider fields. CTA order: Save Guidance Card
/// (primary) → meditation handoff (secondary) → Share (tertiary) →
/// Start a New Reading / Back to Home (text).
struct TarotResultStage: View {
    @Binding var session: TarotReadingSession
    let provider: TarotInterpretationProviding
    let onDrawGuidance: () -> Void
    let onRestart: () -> Void
    let onHome: () -> Void

    @EnvironmentObject private var prefs: PrefsStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showingSummaryCard = false
    @State private var goToMeditation = false
    @State private var expandedCardID: String?

    private var lang: AppLanguage { prefs.language }

    /// Compact Meditation handoff context built by the shared adapter
    /// (question + adapted focus, recommendations — never raw text).
    private var meditationContext: MeditationSourceContext {
        TarotMeditationContextAdapter.context(for: session, provider: provider, lang: lang)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: TwinkoSpacing.m) {
                TarotTwinkoView(state: .idle, size: 96, effect: .summaryAura)
                    .padding(.top, TwinkoSpacing.s)

                if !session.trimmedQuestion.isEmpty {
                    Text(session.trimmedQuestion)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TwinkoSpacing.l)
                }

                ForEach(session.allCards) { drawn in
                    cardSection(drawn)
                }

                if session.spread == .three {
                    synthesisSection
                }

                if session.spread == .three && session.guidanceCard == nil {
                    guidancePromptSection
                }

                twinkoMessageSection

                Text(TarotDisclaimer.text(lang))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TwinkoSpacing.l)

                actions
            }
        }
        .sheet(isPresented: $showingSummaryCard) {
            TarotSummaryCardSheet(session: session, provider: provider)
        }
        .navigationDestination(isPresented: $goToMeditation) {
            MeditationFlowView(sourceContext: meditationContext)
        }
    }

    // MARK: Card section (collapsed core + expandable detail)

    private func cardSection(_ drawn: TarotDrawnCard) -> some View {
        let interp = provider.interpretation(for: drawn, in: session, lang: lang)
        let expanded = expandedCardID == drawn.id
        return VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            HStack(alignment: .top, spacing: TwinkoSpacing.m) {
                TarotCardFace(drawn: drawn, width: 76)
                VStack(alignment: .leading, spacing: 5) {
                    if let position = drawn.position {
                        Text(position.label(lang))
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(Color.inkNavy)
                            .padding(.horizontal, TwinkoSpacing.s)
                            .padding(.vertical, 3)
                            .background(Color.twinkoGold, in: Capsule())
                    }
                    Text(drawn.card.displayName(for: lang))
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(Color.deepPlum)
                    Text(drawn.orientation.label(lang))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.textSecondaryToken)
                    Text(interp.keywords.joined(separator: " · "))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.brandPurpleDeep)
                }
                Spacer(minLength: 0)
            }

            Text(interp.core)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textPrimaryToken)
                .lineSpacing(4)

            if expanded {
                Text(interp.detail)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.textPrimaryToken.opacity(0.9))
                    .lineSpacing(4)
                    .transition(reduceMotion ? .identity : .opacity)

                Divider().overlay(Color.borderSoft)

                VStack(alignment: .leading, spacing: 3) {
                    Text(TarotStrings.reflectionLabel(lang))
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color.accentGold)
                    Text(interp.reflectionPrompt)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.textSecondaryToken)
                }
            }

            Button {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.22)) {
                    expandedCardID = expanded ? nil : drawn.id
                }
            } label: {
                HStack(spacing: 4) {
                    Text(expanded ? TarotStrings.hideFullInterpretation(lang)
                                  : TarotStrings.showFullInterpretation(lang))
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                }
                .foregroundStyle(Color.linkPurple)
                .frame(minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
            }
            .accessibilityIdentifier("tarotExpand-\(drawn.id)")
            .accessibilityLabel(Text(expanded
                ? TarotStrings.hideFullInterpretation(lang)
                : TarotStrings.showFullInterpretation(lang)))
            .accessibilityValue(Text(expanded
                ? (lang == .english ? "expanded" : "已展開")
                : (lang == .english ? "collapsed" : "已收合")))
        }
        .padding(TwinkoSpacing.m)
        .background(Color.surfacePrimary.opacity(0.96),
                    in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
        .padding(.horizontal, TwinkoSpacing.m)
    }

    // MARK: Synthesis / guidance / Twinko message

    private var synthesisSection: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            Label(TarotStrings.overallTitle(lang), systemImage: "sparkles")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.twinkoGold)
            Text(session.guidanceCard == nil
                 ? provider.synthesis(for: session, lang: lang)
                 : provider.combinedSummary(for: session, lang: lang))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.92))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(TwinkoSpacing.m)
        .background(Color.deepSpace.opacity(0.5),
                    in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
        .padding(.horizontal, TwinkoSpacing.m)
    }

    private var guidancePromptSection: some View {
        VStack(spacing: TwinkoSpacing.s) {
            Text(TarotStrings.guidancePrompt(lang))
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.textInverseToken)
            Text(TarotStrings.guidancePromptBody(lang))
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.75))
                .multilineTextAlignment(.center)
            Button {
                onDrawGuidance()
            } label: {
                Text(TarotStrings.guidanceAccept(lang))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.twinkoPrimary)
            .accessibilityIdentifier("tarotGuidanceAccept")
        }
        .padding(TwinkoSpacing.m)
        .background(Color.deepSpace.opacity(0.5),
                    in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: TwinkoRadius.card)
                .strokeBorder(Color.accentGold.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, TwinkoSpacing.m)
    }

    /// Twinko's short emotional closing — a separate provider field,
    /// never the synthesis paragraph again (spec §10).
    private var twinkoMessageSection: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            Label(TarotStrings.finalSummaryTitle(lang), systemImage: "moon.stars.fill")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.accentGold)
            Text(provider.twinkoMessage(for: session, lang: lang))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textPrimaryToken)
                .lineSpacing(4)
            Text(provider.closingLine(lang: lang))
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Color.textSecondaryToken)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(TwinkoSpacing.m)
        .background(Color.surfacePrimary.opacity(0.96),
                    in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
        .padding(.horizontal, TwinkoSpacing.m)
    }

    // MARK: Actions (spec §12 hierarchy)

    private var actions: some View {
        VStack(spacing: TwinkoSpacing.s) {
            // Primary: Save Guidance Card
            Button {
                showingSummaryCard = true
            } label: {
                Label(TarotStrings.saveCard(lang), systemImage: "photo.on.rectangle.angled")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.twinkoPrimary)
            .accessibilityIdentifier("tarotSaveCardButton")

            // Secondary: meditation handoff (dark glass, full width)
            Button {
                goToMeditation = true
            } label: {
                Label(MeditationStrings.tarotCTA(lang), systemImage: "moon.stars.fill")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.textInverseToken)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color.deepSpace.opacity(0.55),
                                in: RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.textInverseToken.opacity(0.35), lineWidth: 1)
                    )
            }
            .accessibilityIdentifier("tarotMeditationCTA")

            Text(TarotStrings.meditationHelper(lang))
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, TwinkoSpacing.l)

            // Tertiary: share
            ShareLink(item: TarotShareFormatter.text(for: session, provider: provider,
                                                     lang: lang)) {
                Label(TarotStrings.shareText(lang), systemImage: "square.and.arrow.up")
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(Color.twinkoGold)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.deepSpace.opacity(0.4),
                                in: RoundedRectangle(cornerRadius: 22))
            }
            .accessibilityIdentifier("tarotShareButton")

            // Text actions
            Button {
                onRestart()
            } label: {
                Text(TarotStrings.startNewReading(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.textInverseToken)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }

            Button {
                onHome()
            } label: {
                Text(TarotStrings.backHome(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.85))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
        }
        .padding(.horizontal, TwinkoSpacing.m)
        .padding(.bottom, TwinkoSpacing.xl)
    }
}
