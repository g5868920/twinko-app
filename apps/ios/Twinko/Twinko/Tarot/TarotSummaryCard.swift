import SwiftUI
import Photos

// MARK: - Layout modes

/// The four Summary Card compositions. Guidance is presented as its
/// own emphasized element — never a fourth chronological position.
enum TarotSummaryLayout: Equatable {
    case single, three, singlePlusGuidance, threePlusGuidance

    static func mode(for session: TarotReadingSession) -> TarotSummaryLayout {
        switch (session.spread, session.guidanceCard != nil) {
        case (.single, false): return .single
        case (.single, true): return .singlePlusGuidance
        case (.three, false): return .three
        case (.three, true): return .threePlusGuidance
        }
    }
}

// MARK: - Summary Card V2 (collectible Tarot artifact)

/// Runtime-layered composition over the production
/// `bg_tarot_summary_card_v2` art (midnight plum, antique-gold Tarot
/// frame, magic-circle center): brand/title/date/topic → card artwork
/// (four modes) → one concise 整體訊息 on a Moonlit Ivory panel → an
/// intimate Twinko closing strip → subtle branding. Same export
/// geometry as the Horoscope Summary Card (360×480 design, 3× →
/// 1080×1440). Never a screenshot; no buttons, no disclaimer, no
/// profile data inside the image.
struct TarotSummaryCardView: View {
    let session: TarotReadingSession
    let provider: TarotInterpretationProviding
    let lang: AppLanguage

    /// Matches `HoroscopeSummaryCardView.designSize` exactly.
    static let designSize = CGSize(width: 360, height: 480)

    private var layout: TarotSummaryLayout { TarotSummaryLayout.mode(for: session) }

    var body: some View {
        VStack(spacing: 8) {
            header
            Spacer(minLength: 0)
            cardArtwork
            Spacer(minLength: 0)
            synthesisPanel
            closingStrip
        }
        .padding(.horizontal, 30)
        .padding(.top, 24)
        .padding(.bottom, 26)
        .frame(width: Self.designSize.width, height: Self.designSize.height)
        .background {
            ZStack {
                Image("bg_tarot_summary_card_v2")
                    .resizable()
                    .scaledToFill()
                // Gentle readability pass behind the lower panels.
                LinearGradient(
                    stops: [.init(color: .clear, location: 0.45),
                            .init(color: Color(hex: 0x1E1030).opacity(0.35), location: 1)],
                    startPoint: .top, endPoint: .bottom)
            }
        }
        .clipped()
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 3) {
            Text("TwinkoTalk")
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(TarotCTAPalette.antiqueGold.opacity(0.65))
                .tracking(1.5)
            Text(TarotStrings.summaryCardTitle(lang))
                .font(.system(size: isDense ? 17 : 19, weight: .bold, design: .rounded))
                .foregroundStyle(TarotCTAPalette.antiqueGold)
            Text(localizedDate)
                .font(.system(size: 9.5, design: .rounded))
                .foregroundStyle(TarotCTAPalette.warmLightText.opacity(0.65))
            Text(session.topic.label(lang))
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(TarotCTAPalette.warmLightText.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .overlay(Capsule().strokeBorder(
                    TarotCTAPalette.antiqueGold.opacity(0.45), lineWidth: 0.8))
        }
    }

    private var localizedDate: String {
        session.createdAt.formatted(
            Date.FormatStyle(date: .abbreviated, time: .omitted)
                .locale(Locale(identifier: lang == .english ? "en_US" : "zh_Hant_TW")))
    }

    // MARK: Card artwork (four modes)

    @ViewBuilder
    private var cardArtwork: some View {
        switch layout {
        case .single:
            summaryCard(session.cards[0], width: 108, showPosition: false)
        case .three:
            HStack(alignment: .top, spacing: 14) {
                ForEach(session.cards) { drawn in
                    summaryCard(drawn, width: 70, showPosition: true)
                }
            }
        case .singlePlusGuidance:
            HStack(alignment: .top, spacing: 22) {
                summaryCard(session.cards[0], width: 84, showPosition: false,
                            overrideLabel: TarotStrings.mainMessageLabel(lang))
                summaryCard(session.guidanceCard!, width: 84, showPosition: false,
                            overrideLabel: TarotPositionType.guidance.label(lang),
                            guidanceGlow: true)
            }
        case .threePlusGuidance:
            VStack(spacing: 3) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(session.cards) { drawn in
                        summaryCard(drawn, width: 46, showPosition: true, dense: true)
                    }
                }
                // Small connector spark — Guidance is its own element,
                // not a fourth chronological position.
                Image(systemName: "sparkle")
                    .font(.system(size: 8))
                    .foregroundStyle(TarotCTAPalette.antiqueGold.opacity(0.8))
                summaryCard(session.guidanceCard!, width: 50, showPosition: true,
                            guidanceGlow: true, dense: true)
            }
        }
    }

    /// The densest mode trades a little text room so the synthesis
    /// never visually clips (spec: 3–5 short lines, no truncated look).
    private var isDense: Bool { layout == .threePlusGuidance }

    /// One registered card at its true identity/orientation (canonical
    /// card ratio, no distortion), with restrained gold border, subtle
    /// glow, and labels. Guidance carries a distinct gold glow.
    private func summaryCard(_ drawn: TarotDrawnCard, width: CGFloat,
                             showPosition: Bool, overrideLabel: String? = nil,
                             guidanceGlow: Bool = false,
                             dense: Bool = false) -> some View {
        VStack(spacing: dense ? 2 : 3) {
            TarotCardFace(drawn: drawn, width: width)
                .shadow(color: guidanceGlow
                            ? Color.twinkoGold.opacity(0.55)
                            : TarotCTAPalette.violetGlow.opacity(0.35),
                        radius: guidanceGlow ? 9 : 6)
            if let overrideLabel {
                Text(overrideLabel)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(TarotCTAPalette.antiqueGold)
            } else if showPosition, let position = drawn.position {
                Text(position.label(lang))
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(TarotCTAPalette.antiqueGold)
            }
            if dense {
                // Compact one-line name · orientation keeps the dense
                // 3+1 mode within the fixed export height.
                Text("\(drawn.card.displayName(for: lang))・\(drawn.orientation.label(lang))")
                    .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(TarotCTAPalette.warmLightText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            } else {
                Text(drawn.card.displayName(for: lang))
                    .font(.system(size: 10.5, weight: .bold, design: .rounded))
                    .foregroundStyle(TarotCTAPalette.warmLightText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(drawn.orientation.label(lang))
                    .font(.system(size: 8.5, design: .rounded))
                    .foregroundStyle(TarotCTAPalette.warmLightText.opacity(0.7))
            }
        }
        .frame(maxWidth: width + 26)
    }

    // MARK: 整體訊息 (always the current reading state)

    private var synthesisPanel: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(TarotStrings.overallMessage(lang))
                .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: 0x8A6FD0))
                .tracking(0.5)
            Text(provider.combinedSummary(for: session, lang: lang))
                .font(.system(size: isDense ? 10 : 11, design: .rounded))
                .foregroundStyle(Color.deepPlum)
                .lineSpacing(isDense ? 1.5 : 2.5)
                .lineLimit(isDense ? 4 : 5)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, isDense ? 7 : 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .layoutPriority(1)
        .background(
            LinearGradient(colors: [Color(hex: 0xFFF9EE), Color(hex: 0xF4EDF6)],
                           startPoint: .top, endPoint: .bottom)
                .opacity(0.92),
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay(RoundedRectangle(cornerRadius: 12)
            .strokeBorder(TarotCTAPalette.antiqueGold.opacity(0.4), lineWidth: 0.8))
        .shadow(color: Color.deepPlum.opacity(0.3), radius: 5, y: 2)
    }

    // MARK: Twinko closing strip

    private var closingStrip: some View {
        VStack(spacing: 6) {
            LinearGradient(colors: [TarotCTAPalette.antiqueGold.opacity(0.02),
                                    TarotCTAPalette.antiqueGold.opacity(0.5),
                                    TarotCTAPalette.antiqueGold.opacity(0.02)],
                           startPoint: .leading, endPoint: .trailing)
                .frame(height: 0.8)
            HStack(alignment: .center, spacing: 10) {
                Image(TarotTwinkoState.idle.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: isDense ? 44 : 52, height: isDense ? 44 : 52)
                VStack(alignment: .leading, spacing: 2) {
                    Text(provider.twinkoMessage(for: session, lang: lang))
                        .font(.system(size: 10.5, weight: .medium, design: .rounded))
                        .foregroundStyle(TarotCTAPalette.warmLightText)
                        .lineSpacing(1.5)
                        .lineLimit(isDense ? 2 : 3)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("TwinkoTalk")
                        .font(.system(size: 8, design: .rounded))
                        .foregroundStyle(TarotCTAPalette.warmLightText.opacity(0.45))
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color(hex: 0x241238).opacity(0.55),
                        in: RoundedRectangle(cornerRadius: 12))
        }
        .layoutPriority(1)
    }
}

// MARK: - Renderer

/// Renders the Summary Card to a 1080×1440 sRGB UIImage — identical
/// geometry to `HoroscopeSummaryCardRenderer`. The preview, the saved
/// image, and the shared image are always this one render.
enum TarotSummaryCardRenderer {
    @MainActor
    static func render(session: TarotReadingSession,
                       provider: TarotInterpretationProviding,
                       lang: AppLanguage) -> UIImage? {
        let renderer = ImageRenderer(content:
            TarotSummaryCardView(session: session, provider: provider, lang: lang))
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

// MARK: - Preview / save / share sheet

/// Branded preview: the exact final render shown aspect-fit with no
/// cropping, then three distinct actions in the Tarot CTA family —
/// Save to Photos (primary, add-only permission on demand), Share
/// (secondary, native sheet with the same rendered image), Close
/// (tertiary).
struct TarotSummaryCardSheet: View {
    let session: TarotReadingSession
    let provider: TarotInterpretationProviding

    @EnvironmentObject private var prefs: PrefsStore
    @Environment(\.dismiss) private var dismiss
    @State private var rendered: UIImage?
    @State private var renderFailed = false
    @State private var toast: String?

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        ZStack {
            Color.deepSpace.ignoresSafeArea()
            StarFieldView().opacity(0.35)

            VStack(spacing: TwinkoSpacing.m) {
                if let rendered {
                    Image(uiImage: rendered)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadowFloating()
                        .padding(.top, TwinkoSpacing.l)
                        .padding(.horizontal, TwinkoSpacing.xl)
                        .accessibilityLabel(Text(TarotStrings.summaryCardTitle(lang)))

                    Button {
                        saveToPhotos(rendered)
                    } label: {
                        Label(TarotStrings.saveToPhotos(lang),
                              systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.tarotMagicPrimary)
                    .padding(.horizontal, TwinkoSpacing.l)
                    .accessibilityIdentifier("tarotCardSaveToPhotos")

                    ShareLink(
                        item: Image(uiImage: rendered),
                        preview: SharePreview(TarotStrings.summaryCardTitle(lang),
                                              image: Image(uiImage: rendered))
                    ) {
                        Label(TarotStrings.shareImage(lang),
                              systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.tarotMagicSecondary)
                    .padding(.horizontal, TwinkoSpacing.l)
                    .accessibilityIdentifier("tarotCardShare")
                } else if renderFailed {
                    Spacer()
                    Text(TarotStrings.renderFailed(lang))
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TwinkoSpacing.l)
                    Button {
                        render()
                    } label: {
                        Text(TarotStrings.retry(lang)).frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.tarotMagicPrimary)
                    .padding(.horizontal, TwinkoSpacing.xl)
                    Spacer()
                } else {
                    Spacer()
                    ProgressView().tint(.twinkoGold)
                    Spacer()
                }

                Button {
                    dismiss()
                } label: {
                    Text(TarotStrings.close(lang))
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.85))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(TwinkoHapticPressStyle())
                .padding(.bottom, TwinkoSpacing.m)
                .accessibilityIdentifier("tarotCardClose")
            }

            if let toast {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(Color.deepPlum)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.surfacePrimary, in: Capsule())
                        .shadowMedium()
                        .padding(.bottom, 90)
                }
                .transition(.opacity)
                .accessibilityIdentifier("tarotCardToast")
            }
        }
        .onAppear { render() }
        .animation(.easeOut(duration: 0.2), value: toast != nil)
    }

    private func render() {
        renderFailed = false
        rendered = TarotSummaryCardRenderer.render(session: session,
                                                   provider: provider, lang: lang)
        if rendered == nil { renderFailed = true }
    }

    private func saveToPhotos(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                guard status == .authorized || status == .limited else {
                    showToast(TarotStrings.saveDenied(lang))
                    return
                }
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, _ in
                    DispatchQueue.main.async {
                        showToast(success ? TarotStrings.savedToast(lang)
                                          : TarotStrings.renderFailed(lang))
                    }
                }
            }
        }
    }

    private func showToast(_ message: String) {
        toast = message
        Task {
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            toast = nil
        }
    }
}
