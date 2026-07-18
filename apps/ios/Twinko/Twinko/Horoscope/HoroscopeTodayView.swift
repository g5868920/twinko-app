import SwiftUI

/// Horoscope Today: cosmic hero (zodiac identity + Twinko + headline),
/// four expandable dimension cards, lucky details, share and
/// summary-card actions. The profile birthday determines "My Sign";
/// viewing another sign never touches the profile. Daily results come
/// from the provider through the daily cache — the same sign, date,
/// and language always shows the same content.
struct HoroscopeTodayView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var prefs: PrefsStore
    @EnvironmentObject private var chrome: ShellChrome
    @Environment(\.dismiss) private var dismiss

    @StateObject private var cache = HoroscopeCache()
    private let provider: HoroscopeProviding = MockHoroscopeProvider()

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewedSign: ZodiacSign?
    @State private var horoscope: DailyHoroscope?
    @State private var loadFailed = false
    @State private var expandedKind: HoroscopeDimensionKind? = .overall
    @State private var showingSelector = false
    @State private var showingSummaryCard = false
    @State private var floating = false
    @State private var immersiveToken = UUID()

    private var lang: AppLanguage { prefs.language }

    /// Sign derived from the profile birthday — "My Sign".
    private var profileSign: ZodiacSign? {
        profileStore.profile.map { ZodiacSign.from(date: $0.birthday) }
    }

    /// Manually chosen sign for users without a profile.
    private var manualSign: ZodiacSign? {
        prefs.prefs.horoscopeManualSignID.flatMap(ZodiacSign.init(canonicalID:))
    }

    private var defaultSign: ZodiacSign? { profileSign ?? manualSign }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                content
            }
        }
        .background {
            GeometryReader { geo in
                ZStack {
                    Image("bg_horoscope_v2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    // Readability overlay: the cosmic art (zodiac
                    // wheel, decorative glyphs) stays as atmosphere,
                    // never competing with the reading content.
                    // Slightly deeper overlay: the zodiac wheel and
                    // decorative glyphs read as atmosphere, never
                    // competing with the text.
                    LinearGradient(
                        stops: [
                            .init(color: Color.deepSpace.opacity(0.36), location: 0),
                            .init(color: Color.deepSpace.opacity(0.28), location: 0.4),
                            .init(color: Color.deepSpace.opacity(0.42), location: 1),
                        ],
                        startPoint: .top, endPoint: .bottom)
                }
                .accessibilityHidden(true)
            }
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingSelector) {
            ZodiacSelectorSheet(selected: viewedSign ?? defaultSign ?? .aries,
                                mySign: profileSign) { sign in
                if profileSign == nil {
                    prefs.prefs.horoscopeManualSignID = sign.canonicalID
                }
                viewedSign = sign
            }
            .environmentObject(prefs)
        }
        .sheet(isPresented: $showingSummaryCard) {
            if let horoscope, let sign = viewedSign {
                HoroscopeSummaryCardPreviewSheet(horoscope: horoscope, sign: sign)
                    .environmentObject(prefs)
            }
        }
        .onAppear {
            if viewedSign == nil { viewedSign = defaultSign }
            // Horoscope content is a detail page: its immersive token
            // hides the bottom tab bar while it is on screen.
            chrome.setImmersive(immersiveToken, active: true)
        }
        .onDisappear {
            chrome.setImmersive(immersiveToken, active: false)
        }
        .task(id: taskKey) { await load() }
    }

    private var taskKey: String {
        "\(HoroscopeDateKey.key()):\(viewedSign?.canonicalID ?? "-"):\(lang.rawValue)"
    }

    @ViewBuilder
    private var content: some View {
        if let sign = viewedSign {
            if let horoscope {
                loadedContent(sign: sign, horoscope: horoscope)
            } else if loadFailed {
                HoroscopeEmptyStateView(lang: lang) {
                    Task { await load(force: true) }
                }
            } else {
                Spacer()
                ProgressView().tint(.twinkoGold)
                Spacer()
            }
        } else {
            HoroscopeSetupStage(
                onBirthday: { sign in
                    prefs.prefs.horoscopeManualSignID = sign.canonicalID
                    viewedSign = sign
                },
                onChooseManually: { showingSelector = true }
            )
        }
    }

    // MARK: Loading

    private func load(force: Bool = false) async {
        guard let sign = viewedSign else { return }
        let dateKey = HoroscopeDateKey.key()
        if !force, let cached = cache.cached(dateKey: dateKey, sign: sign, lang: lang) {
            horoscope = cached
            loadFailed = false
            return
        }
        do {
            let result = try await provider.daily(for: sign, on: .now, lang: lang)
            guard result.isValid else {
                horoscope = nil
                loadFailed = true
                return
            }
            cache.save(result, sign: sign, lang: lang)
            horoscope = result
            loadFailed = false
        } catch {
            // Offline / provider failure: keep any cached content.
            if horoscope == nil { loadFailed = true }
        }
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            Text(HoroscopeStrings.title(lang))
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.textInverseToken)
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.twinkoGold)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(Text(lang == .english ? "Back" : "返回"))
                .accessibilityIdentifier("horoscopeBackButton")
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 48)
    }

    // MARK: Loaded content

    private func loadedContent(sign: ZodiacSign, horoscope: DailyHoroscope) -> some View {
        ScrollView {
            VStack(spacing: TwinkoSpacing.m) {
                hero(sign: sign, horoscope: horoscope)

                TwinkoMessageBlock(message: horoscope.twinkoMessage, lang: lang)
                    .padding(.horizontal, TwinkoSpacing.m)

                VStack(spacing: TwinkoSpacing.s) {
                    ForEach(HoroscopeDimensionKind.allCases, id: \.self) { kind in
                        HoroscopeDimensionCard(kind: kind,
                                               dimension: horoscope.dimension(kind),
                                               lang: lang,
                                               expandedKind: $expandedKind)
                    }
                }
                .padding(.horizontal, TwinkoSpacing.m)

                LuckyDetailsGrid(lucky: horoscope.lucky, lang: lang)
                    .padding(.horizontal, TwinkoSpacing.m)
                    .padding(.top, 2)

                actions
                    .padding(.top, TwinkoSpacing.s)

                Text(HoroscopeStrings.disclaimer(lang))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.5))
                    .padding(.bottom, TwinkoSpacing.xl)
            }
        }
    }

    private func hero(sign: ZodiacSign, horoscope: DailyHoroscope) -> some View {
        VStack(spacing: 8) {
            ZodiacGlyphView(sign: sign, size: 56)

            HStack(spacing: 8) {
                Text(sign.displayName(for: lang))
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(Color.textInverseToken)
                if sign == profileSign {
                    Text(HoroscopeStrings.mySign(lang))
                        .font(.system(.caption2, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color.inkNavy)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.twinkoGold, in: Capsule())
                }
            }

            Text(Date.now.formatted(
                Date.FormatStyle(locale: Locale(identifier: lang.rawValue))
                    .year().month().day().weekday(.wide)))
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Color.textInverseToken.opacity(0.7))

            Button {
                showingSelector = true
            } label: {
                Label(HoroscopeStrings.changeSign(lang), systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(.caption, design: .rounded).weight(.medium))
                    .foregroundStyle(Color.twinkoGold)
                    .padding(.horizontal, 12)
                    .frame(minHeight: 30)
                    // Night-glass capsule (same family as the Tarot
                    // reveal hint) with the gold copy as the accent.
                    .background {
                        Capsule()
                            .fill(LinearGradient(colors: [Color(hex: 0x9C8CD8).opacity(0.38),
                                                          Color(hex: 0x6E5FB0).opacity(0.30)],
                                                 startPoint: .top, endPoint: .bottom))
                    }
                    .overlay(Capsule().strokeBorder(
                        LinearGradient(stops: [
                            .init(color: Color.white.opacity(0.35), location: 0),
                            .init(color: Color(hex: 0xD1C4FF).opacity(0.16), location: 1),
                        ], startPoint: .top, endPoint: .bottom),
                        lineWidth: 1))
                    .frame(minHeight: 44)
                    .contentShape(Capsule())
            }
            .accessibilityIdentifier("horoscopeChangeSign")

            // Floating Twinko — same gentle motion language as Home
            // and Chat (breathing drift, Reduce Motion aware). The
            // headline was removed; the Twinko message below carries
            // the day's feeling plus one small action.
            Image("twinko_horoscope_default_v1_transparent")
                .resizable()
                .scaledToFit()
                .frame(width: 118, height: 118)
                .offset(y: reduceMotion ? 0 : (floating ? -5 : 5))
                .accessibilityHidden(true)
        }
        .padding(.top, TwinkoSpacing.s)
        .accessibilityElement(children: .contain)
        .onAppear { startFloating() }
    }

    private func startFloating() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true)) {
            floating = true
        }
    }

    /// Single exit action: the summary-card sheet owns sharing, so the
    /// page-level Share button was removed (founder decision
    /// 2026-07-18).
    private var actions: some View {
        Button {
            showingSummaryCard = true
        } label: {
            Label(HoroscopeStrings.saveCard(lang), systemImage: "photo.on.rectangle.angled")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.horoscopeGrapePrimary)
        .accessibilityIdentifier("horoscopeSaveCardButton")
        .padding(.horizontal, TwinkoSpacing.m)
    }
}

// MARK: - Missing-profile setup state

/// Lightweight Horoscope setup shown only when no profile sign exists:
/// birthday input (date only) with a live sign confirmation, or manual
/// zodiac selection. Never writes to the profile.
private struct HoroscopeSetupStage: View {
    let onBirthday: (ZodiacSign) -> Void
    let onChooseManually: () -> Void

    @EnvironmentObject private var prefs: PrefsStore
    @State private var birthday = Calendar.current.date(
        from: DateComponents(year: 2000, month: 1, day: 1)) ?? .now

    private var lang: AppLanguage { prefs.language }
    private var derivedSign: ZodiacSign { ZodiacSign.from(date: birthday) }

    var body: some View {
        ScrollView {
            VStack(spacing: TwinkoSpacing.m) {
                Image("twinko_horoscope_default_v1_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, TwinkoSpacing.l)
                    .accessibilityHidden(true)

                Text(HoroscopeStrings.setupExplainer(lang))
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.textInverseToken.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TwinkoSpacing.l)

                DatePicker(lang == .english ? "Birthday" : "生日",
                           selection: $birthday,
                           in: ...Date.now,
                           displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .environment(\.locale, Locale(identifier: lang.rawValue))
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.textInverseToken)
                    .tint(.twinkoGold)
                    .padding(TwinkoSpacing.m)
                    .twinkoGlass(cornerRadius: TwinkoRadius.card, tint: 0.40, night: true)
                    .padding(.horizontal, TwinkoSpacing.m)
                    .colorScheme(.dark)

                Text(HoroscopeStrings.youAre(derivedSign, lang))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.twinkoGold)

                Button {
                    onBirthday(derivedSign)
                } label: {
                    Text(HoroscopeStrings.continueLabel(lang))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.horoscopeGrapePrimary)
                .padding(.horizontal, TwinkoSpacing.m)

                Button {
                    onChooseManually()
                } label: {
                    Text(HoroscopeStrings.chooseManually(lang))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.textInverseToken.opacity(0.85))
                        .frame(minHeight: 44)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HoroscopeTodayView()
            .environmentObject(ProfileStore())
            .environmentObject(PrefsStore())
    }
}
