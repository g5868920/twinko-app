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
    @State private var guidanceHighlight = false

    private var lang: AppLanguage { prefs.language }

    /// Compact Meditation handoff context built by the shared adapter
    /// (question + adapted focus, recommendations — never raw text).
    private var meditationContext: MeditationSourceContext {
        TarotMeditationContextAdapter.context(for: session, provider: provider, lang: lang)
    }

    var body: some View {
        ScrollViewReader { proxy in
        ScrollView {
            VStack(spacing: TwinkoSpacing.m) {
                // Group 0 — reading context: the user's own words plus
                // the selected spread (Task 2 §23.1–6).
                contextSection

                // Group 1 — the reading starts here, in canonical
                // position order, grouped semantically for the
                // five-card spreads. Once a Guidance Card is drawn it
                // joins the reading right after the base cards, whose
                // interpretations are never regenerated.
                baseCardSections
                if let guidance = session.guidanceCard {
                    cardSection(guidance)
                        .id("tarotGuidanceSection")
                        .shadow(color: Color.twinkoGold.opacity(guidanceHighlight ? 0.55 : 0),
                                radius: 12)
                        .animation(.easeInOut(duration: 0.6), value: guidanceHighlight)
                }

                // Group 2 — 整體來看: every completed reading carries
                // one integrated summary (§26); once a Guidance Card
                // exists it expands to read the whole current state.
                synthesisSection

                TarotMagicalDivider()

                // Group 3 — Twinko's emotional closing (reflects the
                // expanded reading once guidance is drawn).
                twinkoMessageSection

                TarotMagicalDivider()

                // Group 4 — one optional Guidance Card draw.
                if session.canDrawGuidance {
                    guidancePromptSection
                    TarotMagicalDivider()
                }

                // Group 5 — Save Guidance Card (single export entry).
                Button {
                    showingSummaryCard = true
                } label: {
                    Label(TarotStrings.saveCard(lang), systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.tarotMagicSecondary)
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
        .onAppear {
            // Returning from the Guidance reveal: bring the newly
            // inserted 指引 section into view with a brief glow — never
            // jump the reader back to the top.
            guard session.guidanceCard != nil else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation(.easeInOut(duration: 0.55)) {
                    proxy.scrollTo("tarotGuidanceSection", anchor: .center)
                }
                guidanceHighlight = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    guidanceHighlight = false
                }
            }
        }
        }
    }

    // MARK: Group 0 — reading context

    /// The user's validated inputs and the selected spread, on one
    /// medium readable surface: question (or decision context + A/B),
    /// optional person label, spread title, short purpose, card count.
    private var contextSection: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            HStack(alignment: .firstTextBaseline) {
                Text(session.spreadID.title(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.deepPlum)
                Spacer()
                Text(session.spreadID.cardCountLabel(lang))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.textSecondaryToken)
            }
            Text(session.spreadID.purpose(lang))
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(Color.textSecondaryToken)
                .fixedSize(horizontal: false, vertical: true)

            if session.spreadID == .twoChoiceFive {
                if let context = session.decisionContext {
                    contextRow(TarotPreReadingStrings.decisionContextLabel(lang), context)
                }
                contextRow(TarotPreReadingStrings.optionALabel(lang),
                           session.optionA ?? "")
                contextRow(TarotPreReadingStrings.optionBLabel(lang),
                           session.optionB ?? "")
            } else {
                if !session.trimmedQuestion.isEmpty {
                    contextRow(TarotPreReadingStrings.reviewQuestion(lang),
                               session.trimmedQuestion)
                }
                if let who = session.relationshipPersonLabel {
                    contextRow(TarotPreReadingStrings.personLabelLabel(lang), who)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tarotReadingCard()
        .accessibilityIdentifier("tarotResultContext")
    }

    private func contextRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(Color.textSecondaryToken)
            Text(value)
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(Color.textPrimaryToken)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Group 1 — base cards (semantic grouping for five-card)

    /// Base sections in canonical order for most spreads; the
    /// five-card spreads group semantically with equal visual weight —
    /// Two-Choice never ranks A over B (§21/§22).
    @ViewBuilder
    private var baseCardSections: some View {
        switch session.spreadID {
        case .twoChoiceFive:
            groupHeader(TarotPreReadingStrings.optionALabel(lang),
                        detail: session.optionA)
            cardSection(session.cards[0])
            cardSection(session.cards[2])
            groupHeader(TarotPreReadingStrings.optionBLabel(lang),
                        detail: session.optionB)
            cardSection(session.cards[1])
            cardSection(session.cards[3])
            groupHeader(TarotPositionID.yourCurrentState.label(lang), detail: nil)
            cardSection(session.cards[4])
        case .relationshipFive:
            groupHeader(lang == .english ? "My Side" : "我這一邊", detail: nil)
            cardSection(session.cards[0])
            cardSection(session.cards[1])
            groupHeader(lang == .english ? "The Other Person's Presented Side"
                                         : "對方呈現的一邊",
                        detail: session.relationshipPersonLabel)
            cardSection(session.cards[2])
            cardSection(session.cards[3])
            groupHeader(TarotPositionID.relationshipDirection.label(lang), detail: nil)
            cardSection(session.cards[4])
        default:
            ForEach(session.cards) { drawn in
                cardSection(drawn)
            }
        }
    }

    /// Quiet semantic group label between base-card sections — equal
    /// treatment for every group, never a winner badge.
    private func groupHeader(_ title: String, detail: String?) -> some View {
        HStack(spacing: 6) {
            Text(detail.map { "\(title)・\($0)" } ?? title)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.textInverseToken)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, TwinkoSpacing.l)
        .padding(.top, TwinkoSpacing.xs)
    }

    // MARK: Group 1/4 — card interpretation (full text by default)

    /// One warm-white matte interpretation card: art, numbered
    /// canonical position, name, orientation, keywords, the complete
    /// position-aware interpretation, and one reflection sentence
    /// (§24). The Guidance Card carries its distinct role label —
    /// never a numbered position.
    private func cardSection(_ drawn: TarotDrawnCard) -> some View {
        let interp = provider.interpretation(for: drawn, in: session, lang: lang)
        return VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            HStack(alignment: .top, spacing: TwinkoSpacing.m) {
                TarotCardFace(drawn: drawn, width: 76)
                VStack(alignment: .leading, spacing: 5) {
                    if drawn.role == .guidance {
                        Text(TarotStrings.guidanceLabel(lang))
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(Color.inkNavy)
                            .padding(.horizontal, TwinkoSpacing.s)
                            .padding(.vertical, 3)
                            .background(Color.twinkoGold, in: Capsule())
                    } else if let position = drawn.positionID {
                        let number = (session.definition.positionIDs
                            .firstIndex(of: position) ?? 0) + 1
                        Text("\(number)・\(position.label(lang))")
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

            // Lead meaning first — emphasized by weight, not size —
            // then the supporting interpretation as regular body.
            Text(interp.core)
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundStyle(Color.textPrimaryToken)
                .lineSpacing(5)

            Text(interp.detail)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textPrimaryToken.opacity(0.88))
                .lineSpacing(5)

            // One reflection sentence per position (§23.13).
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "sparkle")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.accentGold.opacity(0.85))
                    .padding(.top, 3)
                Text(interp.reflectionPrompt)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(Color.textSecondaryToken)
                    .lineSpacing(4)
            }
        }
        .tarotReadingCard()
        .accessibilityIdentifier("tarotCardSection-\(drawn.id)")
    }

    // MARK: Group 2 — Overall Synthesis (three cards only)

    /// Connects the cards as a reflective pattern — always a different
    /// provider field from Twinko's message (§32). Before a Guidance
    /// Card this is the three-card synthesis; afterwards it is the
    /// expanded combined summary of the whole current reading.
    private var synthesisSection: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            // Elevated as the reading's synthesis: one step up from
            // the per-card headers (type scale, not extra container).
            HStack(spacing: 7) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.accentGold)
                Text(TarotStrings.overallTitle(lang))
                    .foregroundStyle(Color.deepPlum)
            }
            .font(.system(.title3, design: .rounded).weight(.semibold))
            Text(session.guidanceCard == nil && session.cards.count > 1
                 ? provider.synthesis(for: session, lang: lang)
                 : provider.combinedSummary(for: session, lang: lang))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textPrimaryToken)
                .lineSpacing(5)
        }
        .tarotReadingCard()
        .accessibilityIdentifier("tarotSynthesis")
    }

    // MARK: Group 3 — Twinko wants to tell you

    /// Companion speech, not another analysis block: star icon (star =
    /// Twinko guidance; moon stays with Meditation), a slightly warmer
    /// tint of the same surface system, roomier conversational line
    /// spacing, and a small star-signature accent under the message.
    private var twinkoMessageSection: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            HStack(spacing: 7) {
                Image(systemName: "star.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.accentGold)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 6))
                            .foregroundStyle(Color.accentGold.opacity(0.8))
                            .offset(x: 4, y: -3)
                    }
                Text(TarotStrings.finalSummaryTitle(lang))
                    .foregroundStyle(Color.deepPlum)
            }
            .font(.system(.headline, design: .rounded))
            Text(provider.twinkoMessage(for: session, lang: lang))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.textPrimaryToken)
                .lineSpacing(7)
            Text(provider.closingLine(lang: lang))
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Color.textSecondaryToken)
            HStack(spacing: 5) {
                Image(systemName: "star.fill").font(.system(size: 6))
                Image(systemName: "star.fill").font(.system(size: 8))
                Image(systemName: "star.fill").font(.system(size: 6))
            }
            .foregroundStyle(Color.accentGold.opacity(0.55))
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
        }
        .tarotReadingCard(.companion)
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
        .tarotReadingCard()
    }

    // MARK: Group 6 — one merged Personalized Meditation section (§35)

    private var meditationSection: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            HStack(spacing: 10) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.accentGold)
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
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.tarotMagicSecondary)
            .accessibilityIdentifier("tarotStartNewReading")

            Button {
                onHome()
            } label: {
                Text(session.source == .chat
                     ? TarotStrings.backToChat(lang)
                     : TarotStrings.backHome(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.85))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(TwinkoHapticPressStyle())
            .accessibilityIdentifier("tarotBackHome")
        }
        .padding(.horizontal, TwinkoSpacing.m)
        .padding(.top, TwinkoSpacing.s)
    }
}
