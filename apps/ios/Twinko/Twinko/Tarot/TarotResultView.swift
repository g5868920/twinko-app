import SwiftUI

/// Interpretation / result stage. Long reading text sits on warm-ivory
/// surfaces (spec §9.4); each card gets a modular section with
/// position badge, orientation, keywords, interpretation, and a
/// reflection prompt. After a three-card reading the Guidance Card
/// prompt appears; with a guidance card present the combined 3+1
/// summary is shown. Share text and summary-card save live here.
struct TarotResultStage: View {
    @Binding var session: TarotReadingSession
    let provider: TarotInterpretationProviding
    let onDrawGuidance: () -> Void
    let onRestart: () -> Void
    let onHome: () -> Void

    @EnvironmentObject private var prefs: PrefsStore
    @State private var showingSummaryCard = false
    @State private var goToMeditation = false

    private var lang: AppLanguage { prefs.language }

    /// Compact Meditation handoff context: the question plus the
    /// combined synthesis — never the full card-by-card interpretation.
    private var meditationContext: MeditationSourceContext {
        MeditationSourceContext(
            sourceType: .tarot,
            recentChatSummary: nil,
            tarotQuestion: session.trimmedQuestion.isEmpty ? nil : session.trimmedQuestion,
            tarotSummary: provider.combinedSummary(for: session, lang: lang),
            emotionalTone: nil)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: TwinkoSpacing.m) {
                Image("twinko_tarot_interpreting_v1_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .padding(.top, TwinkoSpacing.s)
                    .accessibilityHidden(true)

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

                finalSummarySection

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

    // MARK: Card section

    private func cardSection(_ drawn: TarotDrawnCard) -> some View {
        let interp = provider.interpretation(for: drawn, in: session, lang: lang)
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

            Text(interp.body)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textPrimaryToken)
                .lineSpacing(4)

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
        .padding(TwinkoSpacing.m)
        .background(Color.surfacePrimary.opacity(0.96),
                    in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
        .padding(.horizontal, TwinkoSpacing.m)
    }

    // MARK: Synthesis / guidance / summary

    private var synthesisSection: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            Label(TarotStrings.overallTitle(lang), systemImage: "sparkles")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.twinkoGold)
            Text(provider.synthesis(for: session, lang: lang))
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

    private var finalSummarySection: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            Label(TarotStrings.finalSummaryTitle(lang), systemImage: "moon.stars.fill")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.accentGold)
            Text(provider.combinedSummary(for: session, lang: lang))
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

    // MARK: Actions

    private var actions: some View {
        VStack(spacing: TwinkoSpacing.s) {
            ShareLink(item: TarotShareFormatter.text(for: session, provider: provider,
                                                     lang: lang)) {
                Label(TarotStrings.shareText(lang), systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.twinkoPrimary)
            .accessibilityIdentifier("tarotShareButton")

            Button {
                showingSummaryCard = true
            } label: {
                Label(TarotStrings.saveCard(lang), systemImage: "photo.on.rectangle.angled")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.twinkoGold)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color.deepSpace.opacity(0.5),
                                in: RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.accentGold.opacity(0.5), lineWidth: 1)
                    )
            }
            .accessibilityIdentifier("tarotSaveCardButton")

            // Secondary Meditation handoff (screen spec §11): never
            // overpowers the main result actions.
            Button {
                goToMeditation = true
            } label: {
                Label(MeditationStrings.tarotCTA(lang), systemImage: "moon.stars.fill")
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(Color.textInverseToken.opacity(0.9))
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.deepSpace.opacity(0.4),
                                in: RoundedRectangle(cornerRadius: 22))
            }
            .accessibilityIdentifier("tarotMeditationCTA")

            Button {
                onRestart()
            } label: {
                Text(TarotStrings.drawAgain(lang))
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
