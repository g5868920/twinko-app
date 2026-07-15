import SwiftUI

/// Runtime-composed Guidance Summary Card (summary-card spec V3): a
/// branded, collectible 4:5 export image — dark-purple Tarot surface,
/// Twinko summary pose, revealed card thumbnails, short synthesis, and
/// low-prominence branding. Supports single, three, and 3+1 variants.
/// This is a generated image, not a screenshot of app UI.
struct TarotSummaryCardView: View {
    let session: TarotReadingSession
    let provider: TarotInterpretationProviding
    let lang: AppLanguage

    /// Fixed design-space size (1080×1350 at 1/3 scale); the exporter
    /// renders at 3× for the final 1080×1350 PNG.
    static let designSize = CGSize(width: 360, height: 450)

    var body: some View {
        VStack(spacing: 12) {
            // Title + date
            VStack(spacing: 2) {
                Text(TarotStrings.summaryCardTitle(lang))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.twinkoGold)
                Text(session.createdAt.formatted(date: .abbreviated, time: .omitted)
                        .description)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.6))
                Text(session.topic.label(lang))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.8))
            }
            .padding(.top, 18)

            if !session.trimmedQuestion.isEmpty {
                Text("「\(session.trimmedQuestion)」")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 24)
            }

            // Cards row
            HStack(spacing: 10) {
                ForEach(session.allCards) { drawn in
                    VStack(spacing: 4) {
                        TarotCardFace(drawn: drawn, width: cardWidth)
                        if let position = drawn.position {
                            Text(position.label(lang))
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.twinkoGold)
                        }
                        Text(drawn.card.displayName(for: lang))
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.textInverseToken)
                            .lineLimit(1)
                        Text(drawn.orientation.label(lang))
                            .font(.system(size: 8, design: .rounded))
                            .foregroundStyle(Color.textInverseToken.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 16)

            // Short synthesis on an ivory reading surface
            Text(provider.combinedSummary(for: session, lang: lang))
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(Color.textPrimaryToken)
                .lineSpacing(2.5)
                .lineLimit(6)
                .multilineTextAlignment(.leading)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.surfacePrimary.opacity(0.95),
                            in: RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 16)

            Spacer(minLength: 0)

            // Twinko + closing line + branding
            HStack(alignment: .center, spacing: 10) {
                Image("twinko_tarot_summary_v1_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                VStack(alignment: .leading, spacing: 3) {
                    Text(provider.closingLine(lang: lang))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textInverseToken)
                    Text("TwinkoTalk")
                        .font(.system(size: 9, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.5))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .frame(width: Self.designSize.width, height: Self.designSize.height)
        .background {
            ZStack {
                LinearGradient(colors: [Color.deepSpace, Color(hex: 0x2A1E52), Color.menuDeep],
                               startPoint: .top, endPoint: .bottom)
                StarFieldView(tint: .twinkoGold)
                    .opacity(0.5)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }

    private var cardWidth: CGFloat {
        session.allCards.count <= 1 ? 96 : (session.allCards.count == 3 ? 72 : 62)
    }
}

// MARK: - Export sheet

/// Preview + export sheet for the summary card. Renders the card at 3×
/// (1080×1350) with ImageRenderer and hands the PNG to the native
/// share sheet — saving to Photos happens through the share sheet, so
/// no separate media-library permission or framework is added.
struct TarotSummaryCardSheet: View {
    let session: TarotReadingSession
    let provider: TarotInterpretationProviding

    @EnvironmentObject private var prefs: PrefsStore
    @Environment(\.dismiss) private var dismiss
    @State private var exportedImage: UIImage?

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        VStack(spacing: TwinkoSpacing.m) {
            TarotSummaryCardView(session: session, provider: provider, lang: lang)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadowFloating()
                .padding(.top, TwinkoSpacing.l)

            if let exportedImage {
                ShareLink(
                    item: Image(uiImage: exportedImage),
                    preview: SharePreview(TarotStrings.summaryCardTitle(lang),
                                          image: Image(uiImage: exportedImage))
                ) {
                    Label(TarotStrings.summaryCardShare(lang),
                          systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.twinkoPrimary)
                .padding(.horizontal, TwinkoSpacing.l)
                .accessibilityIdentifier("tarotSummaryShare")
            }

            Button {
                dismiss()
            } label: {
                Text(TarotStrings.done(lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.85))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .padding(.bottom, TwinkoSpacing.m)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.deepSpace.ignoresSafeArea())
        .onAppear { export() }
    }

    /// 1080×1350 sRGB PNG per the summary-card spec.
    @MainActor
    private func export() {
        let renderer = ImageRenderer(content:
            TarotSummaryCardView(session: session, provider: provider, lang: lang))
        renderer.scale = 3.0
        exportedImage = renderer.uiImage
    }
}
