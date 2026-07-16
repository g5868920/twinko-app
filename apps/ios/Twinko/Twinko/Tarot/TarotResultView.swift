import SwiftUI

/// Interpretation / result stage (redesign 2026-07-16). The page
/// begins directly with the interpretation — no repeated result hero —
/// and reads as one warm-white matte editorial system separated by
/// magical dividers:
///   Group 1  individual card interpretations (full text by default)
///   Group 2  Overall Synthesis (three-card readings only)
///   Group 3  Twinko wants to tell you (distinct provider field)
///   Group 4  Guidance Card (one optional draw, then its reading)
///   Group 5  Save Guidance Card
///   Group 6  Personalized Meditation (one merged section)
///   Group 7  exit actions, then the single final disclaimer.
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

    /// Compact Meditation handoff context built by the shared adapter
    /// (question + adapted focus, recommendations — never raw text).
    private var meditationContext: MeditationSourceContext {
        TarotMeditationContextAdapter.context(for: session, provider: provider, lang: lang)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: TwinkoSpacing.m) {
                // Group 1 — the reading starts here, directly.
                ForEach(session.cards) { drawn in
                    cardSection(drawn)
                }

                // Group 2 — Overall Synthesis belongs to the same
                // interpretation group (three-card readings only).
                if session.spread == .three {
                    synthesisSection
                }

                TarotMagicalDivider()

                // Group 3 — Twinko's emotional closing.
                twinkoMessageSection

                TarotMagicalDivider()

                // Group 4 — one optional Guidance Card.
                if let guidance = session.guidanceCard {
                    cardSection(guidance)
                } else if session.canDrawGuidance {
                    guidancePromptSection
                }

                TarotMagicalDivider()

                // Group 5 — Save Guidance Card (single export entry).
                Button {
                    showingSummaryCard = true
                } label: {
                    Label(TarotStrings.saveCard(lang), systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.tarotMagicPrimary)
                .padding(.horizontal, TwinkoSpacing.m)
                .accessibilityIdentifier("tarotSaveCardButton")

                TarotMagicalDivider()

                // Group 6 — one merged Personalized Meditation section.
                meditationSection

                // Group 7 — quiet exit actions + single disclaimer.
                exitActions

                Text(TarotDisclaimer.text(lang))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TwinkoSpacing.l)
                    .padding(.bottom, TwinkoSpacing.xl)
            }
            .padding(.top, TwinkoSpacing.s)
        }
        .sheet(isPresented: $showingSummaryCard) {
            TarotSummaryCardSheet(session: session, provider: provider)
        }
        .navigationDestination(isPresented: $goToMeditation) {
            MeditationFlowView(sourceContext: meditationContext)
        }
    }

    // MARK: Group 1/4 — card interpretation (full text by default)

    /// One warm-white matte interpretation card: art, position, name,
    /// orientation, keywords, and the complete interpretation — no
    /// expand control, no per-card mini reflection (§26–27).
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

            Text(interp.core)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textPrimaryToken)
                .lineSpacing(5)

            Text(interp.detail)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textPrimaryToken.opacity(0.9))
                .lineSpacing(5)
        }
        .tarotReadingCard()
        .accessibilityIdentifier("tarotCardSection-\(drawn.id)")
    }

    // MARK: Group 2 — Overall Synthesis (three cards only)

    /// Connects Past / Present / Future as a reflective pattern —
    /// always a different provider field from Twinko's message (§32).
    private var synthesisSection: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            Label(TarotStrings.overallTitle(lang), systemImage: "sparkles")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.deepPlum)
            Text(provider.synthesis(for: session, lang: lang))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textPrimaryToken)
                .lineSpacing(5)
        }
        .tarotReadingCard()
        .accessibilityIdentifier("tarotSynthesis")
    }

    // MARK: Group 3 — Twinko wants to tell you

    private var twinkoMessageSection: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            Label(TarotStrings.finalSummaryTitle(lang), systemImage: "moon.stars.fill")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.deepPlum)
            Text(provider.twinkoMessage(for: session, lang: lang))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textPrimaryToken)
                .lineSpacing(5)
            Text(provider.closingLine(lang: lang))
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Color.textSecondaryToken)
        }
        .tarotReadingCard()
        .accessibilityIdentifier("tarotTwinkoMessage")
    }

    // MARK: Group 4 — optional Guidance Card prompt (one draw, §33)

    private var guidancePromptSection: some View {
        VStack(spacing: TwinkoSpacing.s) {
            Text(TarotStrings.guidancePrompt(lang))
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.deepPlum)
                .multilineTextAlignment(.center)
            Text(TarotStrings.guidancePromptBody(lang))
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Color.textSecondaryToken)
                .multilineTextAlignment(.center)
            Button {
                onDrawGuidance()
            } label: {
                Text(TarotStrings.guidanceAccept(lang))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.tarotMagicPrimary)
            .accessibilityIdentifier("tarotGuidanceAccept")
        }
        .frame(maxWidth: .infinity)
        .padding(TwinkoSpacing.m)
        .background(Color.surfacePrimary.opacity(0.97),
                    in: RoundedRectangle(cornerRadius: TwinkoRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: TwinkoRadius.card)
                .strokeBorder(Color.accentGold.opacity(0.55), lineWidth: 1)
        )
        .padding(.horizontal, TwinkoSpacing.m)
    }

    // MARK: Group 6 — one merged Personalized Meditation section (§35)

    private var meditationSection: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            HStack(spacing: 10) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.brandPurpleDeep)
                Text(TarotStrings.meditationSectionTitle(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.deepPlum)
            }
            Text(TarotStrings.meditationSectionBody(lang))
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Color.textSecondaryToken)
                .lineSpacing(4)
            Button {
                goToMeditation = true
            } label: {
                Text(TarotStrings.meditationSectionCTA(lang))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.tarotMagicPrimary)
            .accessibilityIdentifier("tarotMeditationCTA")
        }
        .tarotReadingCard()
    }

    // MARK: Group 7 — exit actions (§37)

    /// Both exits are quieter than the reading's meaningful actions:
    /// Start a New Reading gets a restrained secondary treatment and
    /// Back to Home is a text action (standard pressed feedback).
    private var exitActions: some View {
        VStack(spacing: TwinkoSpacing.s) {
            Button {
                onRestart()
            } label: {
                Text(TarotStrings.startNewReading(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.textInverseToken)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(Color.deepSpace.opacity(0.5),
                                in: RoundedRectangle(cornerRadius: 23))
                    .overlay(
                        RoundedRectangle(cornerRadius: 23)
                            .strokeBorder(Color.textInverseToken.opacity(0.3), lineWidth: 1)
                    )
            }
            .accessibilityIdentifier("tarotStartNewReading")

            Button {
                onHome()
            } label: {
                Text(TarotStrings.backHome(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.85))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .accessibilityIdentifier("tarotBackHome")
        }
        .padding(.horizontal, TwinkoSpacing.m)
        .padding(.top, TwinkoSpacing.s)
    }
}
