import SwiftUI

// MARK: - Shared My Planet subpage scaffold (Twinko language, 2026-07-18)

/// Every My Planet subpage rides the planet-world background with a
/// floating glass Back orb and a centered rounded title — never the
/// system navigation bar. The founder flagged the previous
/// DreamyBackground + system-bar pages as reading like stock iPhone
/// UI; this scaffold is the replacement.
private struct MyPlanetSubpage<Trailing: View, Content: View>: View {
    let title: String
    let backLabel: String
    let onBack: () -> Void
    @ViewBuilder var trailing: () -> Trailing
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            TwinkoFullScreenBackground(imageName: TwinkoBackgrounds.myPlanetResolved,
                                       topOpacity: 0.20, bottomOpacity: 0.32)
            // Soft mist mutes artwork detail behind reading cards
            // (readability pass 2026-07-18).
            Color.white.opacity(0.10).ignoresSafeArea()
            VStack(spacing: 0) {
                ZStack {
                    Text(title)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.softWhite)
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    HStack {
                        TwinkoGlassBackButton(label: backLabel, action: onBack)
                        Spacer()
                        trailing()
                    }
                }
                .padding(.horizontal, 8)
                .frame(height: 48)

                content()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

extension MyPlanetSubpage where Trailing == EmptyView {
    init(title: String, backLabel: String, onBack: @escaping () -> Void,
         @ViewBuilder content: @escaping () -> Content) {
        self.init(title: title, backLabel: backLabel, onBack: onBack,
                  trailing: { EmptyView() }, content: content)
    }
}

/// Drives the sheet's presentation height per screen (content-aware
/// sizing). Shared across the sheet's NavigationStack via environment
/// so pushed destinations can report their own height.
private final class ProfileSheetHeight: ObservableObject {
    @Published var fraction: CGFloat = 0.55
}

/// Section label readable over the bright valley artwork.
private func sectionHeader(_ text: String) -> some View {
    Text(text)
        .font(.system(.caption, design: .rounded).weight(.semibold))
        .foregroundStyle(Color.softWhite.opacity(0.92))
        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, TwinkoSpacing.s)
}

// MARK: - My Planet landing

/// My Planet: the personal cosmic space on the My Planet tab.
/// Identity hero above the 2×2 record collection, one merged
/// Profile & Settings card, and the quiet Privacy link (founder
/// structure decision 2026-07-18): "my world + utilities", never six
/// equal admin tiles.
struct MyPlanetContentView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var prefs: PrefsStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var sheetHeight = ProfileSheetHeight()
    @State private var activeHub: MyPlanetHub?
    @State private var showingProfileSettings = false
    @State private var showingPrivacy = false

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        NavigationStack {
            ZStack {
                TwinkoFullScreenBackground(imageName: TwinkoBackgrounds.myPlanetResolved,
                                           topOpacity: 0.18, bottomOpacity: 0.30)
                // Soft mist (readability pass 2026-07-18): mutes the
                // valley artwork behind the record cards.
                Color.white.opacity(0.10).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: TwinkoSpacing.m) {
                        hero
                        recordGrid
                        profileSettingsCard
                        privacyLink
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, TwinkoSpacing.l)
                    .padding(.bottom, TwinkoSpacing.l)
                }
            }
            .dockClearance()
            .toolbar(.hidden, for: .navigationBar)
            // Lazy routing: destinations are built only when a station
            // is opened — never eagerly on every body pass.
            .navigationDestination(item: $activeHub) { hub in
                hubDestination(hub)
            }
            .navigationDestination(isPresented: $showingProfileSettings) {
                profileSettingsDetail
            }
            .navigationDestination(isPresented: $showingPrivacy) {
                privacyDetail
            }
            .onAppear { sheetHeight.fraction = 0.55 }
        }
        .environmentObject(sheetHeight)
        .tint(.warmOrange)
    }

    // MARK: Hero — arriving on your own planet

    private var hero: some View {
        VStack(spacing: 6) {
            ZStack {
                // Soft luminous halo beneath the planet — a glow, not
                // a stroked sketch line.
                Ellipse()
                    .fill(Color(hex: 0xD9C8FF).opacity(0.45))
                    .frame(width: 118, height: 34)
                    .blur(radius: 9)
                    .offset(y: 38)
                Ellipse()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 92, height: 20)
                    .blur(radius: 3)
                    .offset(y: 40)
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: "sparkle")
                        .font(.system(size: [7.0, 5.0, 6.0][index]))
                        .foregroundStyle(Color.twinkoGold.opacity(0.85))
                        .offset(x: [-56.0, 60.0, -42.0][index],
                                y: [-28.0, -8.0, 32.0][index])
                }
                Image("home_my_planet_v1_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .shadow(color: Color.brandPurpleDeep.opacity(0.35), radius: 10, y: 4)
            }
            .frame(height: 112)
            .accessibilityHidden(true)

            Text(HomeExperienceStrings.planetOf(
                profileStore.profile?.preferredName ?? (lang == .english ? "Friend" : "朋友"),
                lang))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.softWhite)
                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
            Text(HomeExperienceStrings.planetSubtitle(lang))
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(Color.softWhite.opacity(0.85))
                .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
        }
    }

    // MARK: Records — what you've left on this planet

    private var recordGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(MyPlanetHub.records) { hub in
                hubPod(hub)
            }
        }
    }

    @ViewBuilder
    private func hubPod(_ hub: MyPlanetHub) -> some View {
        Button {
            activeHub = hub
        } label: {
            VStack(spacing: 6) {
                TwinkoCosmicOrb(diameter: 46, tint: hub.tint, showStar: hub.showsStar) {
                    Image(systemName: hub.glyph)
                        .font(.system(size: 17, weight: .medium))
                }
                Text(hub.title(lang))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.deepPlum)
                Text(hub.descriptor(lang))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.deepPlum.opacity(0.65))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 108)
            .padding(.vertical, 10)
            .twinkoGlass(cornerRadius: 24, tint: 0.16)
            .contentShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(TwinkoGlassPressStyle())
        .accessibilityIdentifier(hub.identifier)
        .accessibilityLabel(Text("\(hub.title(lang))，\(hub.descriptor(lang))"))
    }

    /// One merged utility card: Profile & Settings live behind a
    /// single quiet full-width row (founder decision 2026-07-18).
    private var profileSettingsCard: some View {
        Button {
            showingProfileSettings = true
        } label: {
            HStack(spacing: TwinkoSpacing.m) {
                TwinkoCosmicOrb(diameter: 46, tint: Color(hex: 0x9A6FD0),
                                showStar: false) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 17, weight: .medium))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(lang == .english ? "Profile & Settings" : "個人資料與設定")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.deepPlum)
                    Text(lang == .english ? "About you, language & preferences"
                                          : "關於你・語言與偏好")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(Color.deepPlum.opacity(0.65))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.deepPlum.opacity(0.45))
            }
            .padding(.horizontal, TwinkoSpacing.m)
            .frame(maxWidth: .infinity, minHeight: 64)
            .twinkoGlass(cornerRadius: 20, tint: 0.16)
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(TwinkoGlassPressStyle())
        .accessibilityIdentifier("profileSettingsCard")
    }

    /// Coming-soon stations for the record hubs — honest, never fake
    /// data — on the shared Twinko subpage scaffold.
    @ViewBuilder
    private func hubDestination(_ hub: MyPlanetHub) -> some View {
        switch hub {
        case .profile, .settings:
            profileSettingsDetail
        case .journal, .meditationHistory, .tarotHistory, .savedCards:
            hubComingSoon(hub)
        }
    }

    private func hubComingSoon(_ hub: MyPlanetHub) -> some View {
        MyPlanetSubpage(title: hub.title(lang),
                        backLabel: lang == .english ? "Back" : "返回",
                        onBack: { activeHub = nil }) {
            VStack(spacing: TwinkoSpacing.m) {
                Spacer()
                TwinkoCosmicOrb(diameter: 84, tint: hub.tint, showStar: hub.showsStar) {
                    Image(systemName: hub.glyph)
                        .font(.system(size: 30, weight: .medium))
                }
                Text(hub.title(lang))
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.softWhite)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                Text(HomeExperienceStrings.hubComingSoon(lang))
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.deepPlum.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .twinkoGlass(cornerRadius: 22, tint: 0.14)
                    .padding(.horizontal, TwinkoSpacing.l)
                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .dockClearance()
        .accessibilityIdentifier("hubComingSoonState")
    }

    // MARK: Privacy (quiet link — content unchanged)

    private var privacyLink: some View {
        Button {
            showingPrivacy = true
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: 0xE8DCFF).opacity(0.85))
                Text(HomeStrings.privacy(lang))
                    .font(.system(.footnote, design: .rounded).weight(.medium))
                    .foregroundStyle(Color.softWhite.opacity(0.85))
            }
            .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
            .frame(minHeight: 44)
        }
        .buttonStyle(TwinkoHapticPressStyle())
        .accessibilityIdentifier("sheetPrivacyRow")
    }

    // MARK: Profile & Settings (one merged Twinko-styled page)

    private var profileSettingsDetail: some View {
        MyPlanetSubpage(title: lang == .english ? "Profile & Settings" : "個人資料與設定",
                        backLabel: lang == .english ? "Back" : "返回",
                        onBack: { showingProfileSettings = false; activeHub = nil }) {
            ScrollView {
                VStack(spacing: TwinkoSpacing.m) {
                    VStack(spacing: TwinkoSpacing.s) {
                        sectionHeader(lang == .english
                                      ? "About you — tap a card to edit"
                                      : "關於你——輕點卡片就能修改")
                        if let profile = profileStore.profile {
                            let sign = ZodiacSign.from(date: profile.birthday)
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: TwinkoSpacing.s),
                                                GridItem(.flexible(), spacing: TwinkoSpacing.s)],
                                      spacing: TwinkoSpacing.s) {
                                profileCard(lang == .english ? "Name" : "稱呼",
                                            profile.preferredName,
                                            focus: .name, identifier: "profileCard-name")
                                profileCard(lang == .english ? "Birthday" : "生日",
                                            profile.birthday.formatted(
                                                Date.FormatStyle(locale: prefs.locale).year().month().day()),
                                            focus: .birthday, identifier: "profileCard-birthday")
                                zodiacCard(sign)
                                profileCard(lang == .english ? "Gender" : "性別",
                                            profile.gender.displayName(for: lang),
                                            focus: .gender, identifier: "profileCard-gender")
                            }
                        } else {
                            Text(lang == .english ? "No local profile yet." : "還沒有本機資料。")
                                .font(.twinkoBody)
                                .foregroundStyle(Color.deepPlum.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(TwinkoSpacing.m)
                                .twinkoGlass(cornerRadius: 18, tint: 0.14)
                        }
                    }

                    MyPlanetLanguageSection()
                }
                .padding(TwinkoSpacing.m)
            }
        }
        .dockClearance()
        .onAppear { sheetHeight.fraction = 0.62 }
    }

    /// Editable field card: tapping enters editing focused on that
    /// field (spec: no prominent Edit button needed).
    private func profileCard(_ title: String, _ value: String,
                             focus: EditProfileView.Focus,
                             identifier: String) -> some View {
        NavigationLink {
            EditProfileView(initialFocus: focus)
        } label: {
            VStack(spacing: 5) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.twinkoCaption)
                        .foregroundStyle(Color.deepPlum.opacity(0.6))
                    Image(systemName: "pencil")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color.warmOrange.opacity(0.85))
                }
                Text(value)
                    .font(.twinkoHeadline)
                    .foregroundStyle(Color.deepPlum)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 74)
            .padding(TwinkoSpacing.s)
            .twinkoGlass(cornerRadius: 18, tint: 0.14)
            .contentShape(Rectangle())
        }
        .buttonStyle(TwinkoHapticPressStyle())
        .accessibilityIdentifier(identifier)
        .accessibilityHint(Text(lang == .english ? "Double tap to edit" : "點兩下編輯"))
    }

    /// Zodiac is auto-calculated — informative, not editable.
    private func zodiacCard(_ sign: ZodiacSign) -> some View {
        VStack(spacing: 5) {
            Text(lang == .english ? "Zodiac (auto)" : "星座（自動）")
                .font(.twinkoCaption)
                .foregroundStyle(Color.deepPlum.opacity(0.6))
            Text("\(sign.symbol) \(sign.displayName(for: lang))")
                .font(.twinkoHeadline)
                .foregroundStyle(Color.deepPlum)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 74)
        .padding(TwinkoSpacing.s)
        .twinkoGlass(cornerRadius: 18, tint: 0.14)
        .accessibilityElement(children: .combine)
    }

    // MARK: Privacy (sectioned reading experience)

    private var privacyDetail: some View {
        MyPlanetSubpage(title: HomeStrings.privacy(lang),
                        backLabel: lang == .english ? "Back" : "返回",
                        onBack: { showingPrivacy = false }) {
            ScrollView {
                VStack(spacing: TwinkoSpacing.s) {
                    privacyRow(icon: "iphone",
                               title: lang == .english ? "Stays on this device"
                                                       : "只存在這台裝置",
                               body: lang == .english
                               ? "Your profile and chats are stored only on this device, as plain files you can inspect and delete."
                               : "你的個人資料與聊天紀錄，都只以可檢視、可刪除的檔案存在這台裝置上。")
                    privacyRow(icon: "icloud.slash",
                               title: lang == .english ? "Nothing is uploaded"
                                                       : "沒有上傳、沒有同步",
                               body: lang == .english
                               ? "Nothing is uploaded, synced, or shared — and there is no account."
                               : "沒有任何內容會被上傳、同步或分享，也沒有帳號。")
                    Text(lang == .english
                         ? "This describes the prototype only; it is not a production privacy policy."
                         : "以上僅描述此原型的行為，不是正式產品的隱私權政策。")
                        .font(.twinkoCaption)
                        .foregroundStyle(Color.softWhite.opacity(0.8))
                        .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, TwinkoSpacing.s)
                        .padding(.top, 2)
                }
                .padding(TwinkoSpacing.m)
            }
        }
        .dockClearance()
        .onAppear { sheetHeight.fraction = 0.58 }
    }

    private func privacyRow(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: TwinkoSpacing.m) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.brandPurpleDeep)
                .frame(width: 34, height: 34)
                .background(Color.brandPurple.opacity(0.14), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.twinkoHeadline)
                    .foregroundStyle(Color.deepPlum)
                Text(body)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.deepPlum.opacity(0.75))
                    .lineSpacing(3)
            }
            Spacer(minLength: 0)
        }
        .padding(TwinkoSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .twinkoGlass(cornerRadius: 18, tint: 0.14)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Edit Profile

/// Twinko-themed Edit Profile on the shared subpage scaffold: glass
/// Back orb (with an unsaved-changes guard), a gold Save pill, and
/// clear-glass field cards over the planet world. The tapped field
/// receives focus; birthday uses a wheel picker so year, month, and
/// day are adjustable in one coherent flow. Save persists and
/// returns; Back never saves silently.
struct EditProfileView: View {
    enum Focus { case name, birthday, gender }

    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var prefs: PrefsStore
    @Environment(\.dismiss) private var dismiss

    let initialFocus: Focus

    @State private var name: String = ""
    @State private var birthday: Date = .now
    @State private var gender: Gender = .preferNotToSay
    @State private var loaded = false
    @State private var showingDiscardDialog = false
    @State private var showingSavedToast = false
    @FocusState private var nameFieldFocused: Bool

    init(initialFocus: Focus = .name) {
        self.initialFocus = initialFocus
    }

    private var lang: AppLanguage { prefs.language }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var canSave: Bool { !trimmedName.isEmpty }

    private var hasUnsavedChanges: Bool {
        guard let profile = profileStore.profile else {
            return !trimmedName.isEmpty
        }
        return trimmedName != profile.preferredName
            || !Calendar.current.isDate(birthday, inSameDayAs: profile.birthday)
            || gender != profile.gender
    }

    var body: some View {
        MyPlanetSubpage(title: lang == .english ? "Edit Profile" : "編輯資料",
                        backLabel: lang == .english ? "Back" : "返回",
                        onBack: {
                            if hasUnsavedChanges {
                                showingDiscardDialog = true
                            } else {
                                dismiss()
                            }
                        },
                        trailing: { saveButton }) {
            ZStack(alignment: .top) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: TwinkoSpacing.m) {
                            fieldCard(lang == .english ? "Name" : "稱呼") {
                                VStack(alignment: .leading, spacing: 6) {
                                    TextField(lang == .english ? "Your name" : "你的名字或暱稱", text: $name)
                                        .font(.twinkoBody)
                                        .foregroundStyle(Color.deepPlum)
                                        .padding(10)
                                        .background(Color.white.opacity(0.7),
                                                    in: RoundedRectangle(cornerRadius: 10))
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color(hex: 0xB9A8E8).opacity(0.5),
                                                          lineWidth: 1))
                                        .focused($nameFieldFocused)
                                        .accessibilityIdentifier("editNameField")
                                    if !canSave {
                                        Text(lang == .english ? "Name can't be empty" : "名字不能是空白喔")
                                            .font(.twinkoCaption)
                                            .foregroundStyle(Color.cheekOrange)
                                    }
                                }
                            }
                            .id(Focus.name)

                            fieldCard(lang == .english ? "Birthday" : "生日") {
                                // Wheel picker: year / month / day visible
                                // and adjustable in one coherent flow — no
                                // month-then-hunt-for-the-day calendar hops.
                                DatePicker("", selection: $birthday, in: ...Date.now,
                                           displayedComponents: .date)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .frame(maxHeight: 148)
                                    .clipped()
                                    .environment(\.locale, prefs.locale)
                                    .tint(.brandPurpleDeep)
                                    .accessibilityIdentifier("editBirthdayPicker")
                            }
                            .id(Focus.birthday)

                            fieldCard(lang == .english ? "Zodiac (auto)" : "星座（自動計算）") {
                                let sign = ZodiacSign.from(date: birthday)
                                Text("\(sign.symbol) \(sign.displayName(for: lang))")
                                    .font(.twinkoHeadline)
                                    .foregroundStyle(Color.deepPlum.opacity(0.8))
                                    .accessibilityIdentifier("editZodiacValue")
                            }

                            fieldCard(lang == .english ? "Gender" : "性別") {
                                FlowHStack(spacing: TwinkoSpacing.s) {
                                    ForEach(Gender.allCases) { option in
                                        let selected = gender == option
                                        Button {
                                            gender = option
                                        } label: {
                                            Text(option.displayName(for: lang))
                                                .font(.twinkoBody)
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 8)
                                                .frame(minHeight: 38)
                                                .background(
                                                    selected ? AnyShapeStyle(
                                                        LinearGradient(colors: [.twinkoGold, .warmOrange],
                                                                       startPoint: .top, endPoint: .bottom))
                                                             : AnyShapeStyle(Color.white.opacity(0.55)),
                                                    in: Capsule()
                                                )
                                                .overlay(Capsule().strokeBorder(
                                                    selected ? Color.white.opacity(0.6)
                                                             : Color(hex: 0xB9A8E8).opacity(0.5),
                                                    lineWidth: 1))
                                                .foregroundStyle(selected ? .white : Color.deepPlum)
                                        }
                                        .buttonStyle(TwinkoHapticPressStyle())
                                        .accessibilityAddTraits(selected ? [.isSelected] : [])
                                    }
                                }
                            }
                            .id(Focus.gender)
                        }
                        .padding(TwinkoSpacing.m)
                        .padding(.bottom, TwinkoSpacing.xl)
                    }
                    .onAppear {
                        // Land on the tapped field.
                        switch initialFocus {
                        case .name:
                            nameFieldFocused = false
                        case .birthday, .gender:
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                withAnimation { proxy.scrollTo(initialFocus, anchor: .top) }
                            }
                        }
                    }
                }

                if showingSavedToast {
                    Text(lang == .english ? "Saved" : "已儲存")
                        .font(.twinkoHeadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, TwinkoSpacing.l)
                        .padding(.vertical, 10)
                        .background(Color.cosmicPurple.opacity(0.92), in: Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 6, y: 2)
                        .accessibilityIdentifier("savedToast")
                        .padding(.top, TwinkoSpacing.s)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .confirmationDialog(
            lang == .english ? "You have unsaved changes" : "還有尚未儲存的變更",
            isPresented: $showingDiscardDialog,
            titleVisibility: .visible
        ) {
            Button(lang == .english ? "Discard Changes" : "放棄變更", role: .destructive) {
                dismiss()
            }
            Button(lang == .english ? "Continue Editing" : "繼續編輯", role: .cancel) {}
        }
        .scrollDismissesKeyboard(.interactively)
        .interactiveDismissDisabled(hasUnsavedChanges)
        .onAppear {
            guard !loaded else { return }
            loaded = true
            if let profile = profileStore.profile {
                name = profile.preferredName
                birthday = profile.birthday
                gender = profile.gender
            }
        }
    }

    /// Gold Save pill — the page's single primary action, floating in
    /// the header instead of a system toolbar item.
    private var saveButton: some View {
        Button {
            save()
        } label: {
            Text(lang == .english ? "Save" : "儲存")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(canSave ? .white : Color.deepPlum.opacity(0.4))
                .padding(.horizontal, 14)
                .frame(minHeight: 34)
                .background(
                    canSave
                        ? AnyShapeStyle(LinearGradient(colors: [.twinkoGold, .warmOrange],
                                                       startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(Color.white.opacity(0.4)),
                    in: Capsule())
                .overlay(Capsule().strokeBorder(
                    canSave ? Color.white.opacity(0.6)
                            : Color(hex: 0xB9A8E8).opacity(0.4),
                    lineWidth: 1))
                .shadow(color: canSave ? Color.warmOrange.opacity(0.35) : .clear,
                        radius: 4, y: 2)
        }
        .buttonStyle(TwinkoHapticPressStyle())
        .disabled(!canSave)
        .accessibilityIdentifier("editSaveButton")
    }

    private func save() {
        guard canSave else { return }
        profileStore.save(UserProfile(preferredName: trimmedName,
                                      birthday: birthday, gender: gender))
        withAnimation(.easeOut(duration: 0.2)) {
            showingSavedToast = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            dismiss()
        }
    }

    @ViewBuilder
    private func fieldCard<Content: View>(_ title: String,
                                          @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            sectionHeader(title)
            content()
        }
        .padding(TwinkoSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .twinkoGlass(cornerRadius: 18, tint: 0.14)
    }
}

// MARK: - Language section (shared by the merged page and Home gear)

struct MyPlanetLanguageSection: View {
    @EnvironmentObject private var prefs: PrefsStore

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            sectionHeader(HomeStrings.language(lang))
            ForEach(AppLanguage.allCases) { option in
                let selected = prefs.language == option
                Button {
                    prefs.language = option
                } label: {
                    HStack(spacing: TwinkoSpacing.m) {
                        Text(option == .traditionalChinese ? "繁" : "EN")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(selected ? .white : Color.brandPurpleDeep)
                            .frame(width: 36, height: 36)
                            .background(
                                selected
                                    ? AnyShapeStyle(LinearGradient(
                                        colors: [.brandPurple, .brandPurpleDeep],
                                        startPoint: .top, endPoint: .bottom))
                                    : AnyShapeStyle(Color.brandPurple.opacity(0.14)),
                                in: Circle())
                        Text(option.displayName)
                            .font(.twinkoHeadline)
                            .foregroundStyle(Color.deepPlum)
                        Spacer()
                        Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundStyle(selected
                                             ? Color.brandPurpleDeep
                                             : Color.deepPlum.opacity(0.25))
                    }
                    .padding(TwinkoSpacing.m)
                    .frame(minHeight: 60)
                    .twinkoGlass(cornerRadius: 18, tint: selected ? 0.18 : 0.12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(selected ? Color.brandPurple.opacity(0.6)
                                                   : Color.clear,
                                          lineWidth: 1.5)
                    )
                }
                .buttonStyle(TwinkoHapticPressStyle())
                .accessibilityIdentifier("language-\(option.rawValue)")
                .accessibilityAddTraits(prefs.language == option ? [.isSelected] : [])
            }
        }
    }
}

/// Direct Settings sheet for the Home top-right gear — a different
/// destination from the My Planet tab.
struct SettingsSheetView: View {
    @EnvironmentObject private var prefs: PrefsStore

    var body: some View {
        ZStack {
            TwinkoFullScreenBackground(imageName: TwinkoBackgrounds.myPlanetResolved,
                                       topOpacity: 0.20, bottomOpacity: 0.32)
            ScrollView {
                VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                    Text(HomeStrings.settings(prefs.language))
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.softWhite)
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                        .frame(maxWidth: .infinity)
                        .padding(.top, TwinkoSpacing.m)
                    MyPlanetLanguageSection()
                }
                .padding(TwinkoSpacing.m)
            }
        }
        .presentationDetents([.fraction(0.55)])
        .presentationCornerRadius(28)
        .presentationDragIndicator(.visible)
        .tint(.warmOrange)
    }
}

#Preview {
    MyPlanetContentView()
        .environmentObject(ProfileStore())
        .environmentObject(PrefsStore())
}


// MARK: - My Planet hubs (companion-universe redesign 2026-07-17)

/// The personal stations on My Planet. The four record hubs form the
/// 2×2 collection grid (honest coming-soon stations until their
/// features are implemented); Profile and Settings remain as cases for
/// routing but present as one merged utility card.
enum MyPlanetHub: String, CaseIterable, Identifiable, Hashable {
    case journal, meditationHistory, tarotHistory, savedCards, profile, settings

    var id: String { rawValue }

    /// The 2×2 record collection shown on the landing grid.
    static let records: [MyPlanetHub] = [.journal, .meditationHistory,
                                         .tarotHistory, .savedCards]

    var identifier: String {
        switch self {
        case .journal: return "hubJournal"
        case .meditationHistory: return "hubMeditation"
        case .tarotHistory: return "hubTarot"
        case .savedCards: return "hubCards"
        case .profile: return "sheetProfileRow"
        case .settings: return "sheetSettingsRow"
        }
    }

    /// True when the hub routes to an existing real destination.
    var routesToExistingDestination: Bool {
        switch self {
        case .profile, .settings: return true
        case .journal, .meditationHistory, .tarotHistory, .savedCards: return false
        }
    }

    var glyph: String {
        switch self {
        case .journal: return "book.closed.fill"
        case .meditationHistory: return "moon.zzz.fill"
        case .tarotHistory: return "rectangle.portrait.on.rectangle.portrait.fill"
        case .savedCards: return "sparkles.rectangle.stack.fill"
        case .profile: return "person.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var tint: Color {
        switch self {
        case .journal: return Color(hex: 0x8F7BD8)           // violet memory
        case .meditationHistory: return Color(hex: 0x5D7BC8) // calm blue-lilac
        case .tarotHistory: return Color(hex: 0x6B4BA8)      // plum oracle
        case .savedCards: return Color(hex: 0x4E5FB8)        // violet-blue vault
        case .profile: return Color(hex: 0x9A6FD0)           // warm lilac identity
        case .settings: return Color(hex: 0x7A6FA8)          // control station
        }
    }

    var showsStar: Bool {
        self == .savedCards || self == .journal
    }

    func title(_ lang: AppLanguage) -> String {
        switch self {
        case .journal: return HomeExperienceStrings.hubJournal(lang)
        case .meditationHistory: return HomeExperienceStrings.hubMeditation(lang)
        case .tarotHistory: return HomeExperienceStrings.hubTarot(lang)
        case .savedCards: return HomeExperienceStrings.hubCards(lang)
        case .profile: return HomeExperienceStrings.hubProfile(lang)
        case .settings: return HomeExperienceStrings.hubSettings(lang)
        }
    }

    func descriptor(_ lang: AppLanguage) -> String {
        switch self {
        case .journal: return HomeExperienceStrings.hubJournalDesc(lang)
        case .meditationHistory: return HomeExperienceStrings.hubMeditationDesc(lang)
        case .tarotHistory: return HomeExperienceStrings.hubTarotDesc(lang)
        case .savedCards: return HomeExperienceStrings.hubCardsDesc(lang)
        case .profile: return HomeExperienceStrings.hubProfileDesc(lang)
        case .settings: return HomeExperienceStrings.hubSettingsDesc(lang)
        }
    }
}
