import SwiftUI
import Photos

// MARK: - Summary card composition

/// Runtime-composed Horoscope Summary Card: a 3:4 branded export over
/// `bg_horoscope_summary_card_v1` (canvas matches the art's native
/// ratio so the decorative frame is never cropped) with zodiac
/// identity, overall score + summary, the Twinko message, the four
/// lucky details, and the canonical Horoscope Twinko. One locale at a
/// time; never a screenshot of the app screen.
struct HoroscopeSummaryCardView: View {
    let horoscope: DailyHoroscope
    let sign: ZodiacSign
    let lang: AppLanguage

    /// 1080×1440 (3:4, the background art's native ratio) at 1/3
    /// scale; the renderer exports at 3×. Matching the art ratio is
    /// the root fix for the previously clipped top/bottom frame.
    static let designSize = CGSize(width: 360, height: 480)

    var body: some View {
        VStack(spacing: 10) {
            // Branding + date
            VStack(spacing: 2) {
                Text("TwinkoTalk")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.twinkoGold.opacity(0.9))
                Text(HoroscopeStrings.cardBrandTitle(lang))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.softWhite)
                Text(Date.now.formatted(
                    Date.FormatStyle(locale: Locale(identifier: lang.rawValue))
                        .year().month().day()))
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(Color.softWhite.opacity(0.65))
            }
            .padding(.top, 34)

            // Zodiac identity + Twinko
            HStack(spacing: 14) {
                VStack(spacing: 4) {
                    ZodiacGlyphView(sign: sign, size: 56)
                    Text(sign.displayName(for: lang))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.softWhite)
                }
                Image("twinko_horoscope_default_v1_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 78, height: 78)
            }

            // Overall score + summary
            VStack(spacing: 5) {
                HStack(spacing: 4) {
                    Text(HoroscopeDimensionKind.overall.title(lang))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.twinkoGold)
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= horoscope.overall.score ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundStyle(index <= horoscope.overall.score
                                ? Color.twinkoGold : Color.softWhite.opacity(0.35))
                    }
                }
                Text(horoscope.overall.summary)
                    .font(.system(size: 11.5, design: .rounded))
                    .foregroundStyle(Color.softWhite.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(Color.deepSpace.opacity(0.5), in: RoundedRectangle(cornerRadius: 13))
            .padding(.horizontal, 26)

            // Twinko message
            VStack(alignment: .leading, spacing: 3) {
                Text(HoroscopeStrings.twinkoSays(lang))
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.twinkoGold)
                Text(horoscope.twinkoMessage)
                    .font(.system(size: 11.5, design: .rounded))
                    .foregroundStyle(Color.softWhite.opacity(0.94))
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.menuDeep.opacity(0.55), in: RoundedRectangle(cornerRadius: 13))
            .overlay(
                RoundedRectangle(cornerRadius: 13)
                    .strokeBorder(Color.twinkoGold.opacity(0.28), lineWidth: 0.8)
            )
            .padding(.horizontal, 24)

            // Lucky details 2×2
            let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
            LazyVGrid(columns: columns, spacing: 8) {
                luckyCell(HoroscopeStrings.luckyNumber(lang), "\(horoscope.lucky.number)")
                luckyCell(HoroscopeStrings.luckyColor(lang),
                          horoscope.lucky.color.displayName(lang),
                          swatchHex: horoscope.lucky.color.hex)
                luckyCell(HoroscopeStrings.luckyZodiac(lang),
                          horoscope.lucky.luckySign?.displayName(for: lang) ?? "—",
                          zodiacSign: horoscope.lucky.luckySign)
                luckyCell(HoroscopeStrings.luckyItem(lang), horoscope.lucky.item)
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 0)
        }
        .frame(width: Self.designSize.width, height: Self.designSize.height)
        .background {
            Image("bg_horoscope_summary_card_v1")
                .resizable()
                .scaledToFill()
                .frame(width: Self.designSize.width, height: Self.designSize.height)
                .clipped()
        }
    }

    private func luckyCell(_ label: String, _ value: String,
                           swatchHex: String? = nil, zodiacSign: ZodiacSign? = nil) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(Color.softWhite.opacity(0.6))
            HStack(spacing: 4) {
                if let zodiacSign {
                    ZodiacGlyphView(sign: zodiacSign, size: 14, emphasized: false)
                }
                if let swatchHex, let color = Color(horoscopeHex: swatchHex) {
                    Circle()
                        .fill(color)
                        .frame(width: 9, height: 9)
                        .overlay(Circle().strokeBorder(Color.softWhite.opacity(0.4),
                                                       lineWidth: 0.5))
                }
                Text(value)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.twinkoGold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 40)
        .padding(.vertical, 5)
        .background(Color.deepSpace.opacity(0.45), in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Renderer

/// Renders the summary card to a 1080×1440 sRGB PNG-backed UIImage.
enum HoroscopeSummaryCardRenderer {
    @MainActor
    static func render(horoscope: DailyHoroscope, sign: ZodiacSign,
                       lang: AppLanguage) -> UIImage? {
        let renderer = ImageRenderer(content:
            HoroscopeSummaryCardView(horoscope: horoscope, sign: sign, lang: lang))
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

// MARK: - Preview / save / share sheet

/// Branded preview sheet: exact final render, Save to Photos (add-only
/// permission requested on demand), native image share, Close. Render
/// failure keeps the horoscope intact and offers Retry plus a
/// share-text fallback.
struct HoroscopeSummaryCardPreviewSheet: View {
    let horoscope: DailyHoroscope
    let sign: ZodiacSign

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
                        .accessibilityLabel(Text(accessibilitySummary))

                    Button {
                        saveToPhotos(rendered)
                    } label: {
                        Label(HoroscopeStrings.saveToPhotos(lang), systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.horoscopeGrapePrimary)
                    .padding(.horizontal, TwinkoSpacing.l)
                    .accessibilityIdentifier("horoscopeCardSave")

                    ShareLink(
                        item: Image(uiImage: rendered),
                        preview: SharePreview(HoroscopeStrings.cardBrandTitle(lang),
                                              image: Image(uiImage: rendered))
                    ) {
                        Label(HoroscopeStrings.shareImage(lang), systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.horoscopeGrapeSecondary)
                    .padding(.horizontal, TwinkoSpacing.l)
                    .accessibilityIdentifier("horoscopeCardShare")
                } else if renderFailed {
                    Spacer()
                    Text(HoroscopeStrings.renderFailed(lang))
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TwinkoSpacing.l)
                    Button {
                        render()
                    } label: {
                        Text(HoroscopeStrings.retry(lang)).frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.horoscopeGrapePrimary)
                    .padding(.horizontal, TwinkoSpacing.xl)
                    ShareLink(item: HoroscopeShareFormatter.text(for: horoscope, sign: sign,
                                                                 lang: lang)) {
                        Text(HoroscopeStrings.shareTextFallback(lang))
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(Color.twinkoGold)
                            .frame(minHeight: 44)
                    }
                    Spacer()
                } else {
                    Spacer()
                    ProgressView().tint(.twinkoGold)
                    Spacer()
                }

                Button {
                    dismiss()
                } label: {
                    Text(HoroscopeStrings.close(lang))
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.85))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(TwinkoHapticPressStyle())
                .padding(.bottom, TwinkoSpacing.m)
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
                .accessibilityIdentifier("horoscopeToast")
            }
        }
        .onAppear { render() }
        .animation(.easeOut(duration: 0.2), value: toast != nil)
    }

    private var accessibilitySummary: String {
        let score = HoroscopeScoreLabel.accessibilityText(horoscope.overall.score, lang)
        return lang == .english
            ? "\(sign.displayName(for: lang)) daily horoscope. Overall \(score). \(horoscope.twinkoMessage)"
            : "\(sign.displayName(for: lang))今日運勢。整體\(score)。\(horoscope.twinkoMessage)"
    }

    private func render() {
        renderFailed = false
        rendered = HoroscopeSummaryCardRenderer.render(horoscope: horoscope, sign: sign, lang: lang)
        if rendered == nil { renderFailed = true }
    }

    private func saveToPhotos(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                guard status == .authorized || status == .limited else {
                    showToast(HoroscopeStrings.saveDenied(lang))
                    return
                }
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, _ in
                    DispatchQueue.main.async {
                        showToast(success ? HoroscopeStrings.savedToast(lang)
                                          : HoroscopeStrings.renderFailed(lang))
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
