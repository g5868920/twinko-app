import SwiftUI

// MARK: - Profile planet icon

/// TEMPORARY PROFILE PLANET — founder-approved SwiftUI prototype asset.
/// No PNG asset exists for the Profile control; this small ringed
/// planet (no face, no letters, deliberately not Earth) is drawn with
/// native shapes in the same soft style as the Home mode icons, and can
/// be replaced by a delivered image asset later.
struct ProfilePlanetIcon: View {
    /// Full visible diameter of the circular base.
    var diameter: CGFloat = 39

    var body: some View {
        ZStack {
            // Outer circular base — deep semi-transparent purple.
            Circle()
                .fill(Color.cosmicDeep.opacity(0.55))

            // Planet body — lavender-purple to pale blue.
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.72, green: 0.64, blue: 0.94),
                                 Color(red: 0.62, green: 0.72, blue: 0.94)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: diameter * 0.52, height: diameter * 0.52)

            // Thin planetary ring — light lavender, tilted.
            Ellipse()
                .strokeBorder(Color(red: 0.90, green: 0.87, blue: 0.99).opacity(0.95),
                              lineWidth: diameter * 0.045)
                .frame(width: diameter * 0.86, height: diameter * 0.30)
                .rotationEffect(.degrees(-18))
        }
        .frame(width: diameter, height: diameter)
        .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
        .accessibilityHidden(true)
    }
}

// MARK: - Branded profile sheet

/// Branded Profile bottom sheet (D-055 refinement): misty lavender
/// surface, header with planet / name / zodiac / Edit, and custom
/// rounded rows for Profile, Settings (Language only), and Privacy.
/// No Log Out — no authentication or account system exists.
struct ProfileSheetView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var prefs: PrefsStore

    private var lang: AppLanguage { prefs.language }
    private static let surface = Color(red: 0.965, green: 0.945, blue: 0.995)
    private static let cardBorder = Color(red: 0.83, green: 0.77, blue: 0.95)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TwinkoSpacing.m) {
                    header
                        .padding(.top, TwinkoSpacing.l)

                    VStack(spacing: TwinkoSpacing.s) {
                        navRow(HomeStrings.profile(lang), icon: "person.fill",
                               identifier: "sheetProfileRow") { profileDetail }
                        navRow(HomeStrings.settings(lang), icon: "gearshape.fill",
                               identifier: "sheetSettingsRow") { settingsDetail }
                        navRow(HomeStrings.privacy(lang), icon: "hand.raised.fill",
                               identifier: "sheetPrivacyRow") { privacyDetail }
                    }
                    .padding(.horizontal, TwinkoSpacing.m)
                }
                .padding(.bottom, TwinkoSpacing.xl)
            }
            .background(Self.surface)
            .toolbar(.hidden, for: .navigationBar)
        }
        .presentationDetents([.fraction(0.74)])
        .presentationCornerRadius(28)
        .presentationDragIndicator(.visible)
        .presentationBackground(Self.surface)
        .tint(.warmOrange)
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: TwinkoSpacing.s) {
            ProfilePlanetIcon(diameter: 56)
            Text(profileStore.profile?.preferredName ?? (lang == .english ? "Friend" : "朋友"))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.inkNavy)
            if let birthday = profileStore.profile?.birthday {
                let sign = ZodiacSign.from(date: birthday)
                Text("\(sign.symbol) \(sign.rawValue)")
                    .font(.twinkoBody)
                    .foregroundStyle(Color.inkNavy.opacity(0.6))
            }
            NavigationLink {
                EditProfileView()
            } label: {
                Text(lang == .english ? "Edit" : "編輯")
                    .font(.twinkoHeadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, TwinkoSpacing.l)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(colors: [.twinkoGold, .warmOrange],
                                       startPoint: .top, endPoint: .bottom),
                        in: Capsule()
                    )
            }
            .accessibilityIdentifier("sheetEditButton")
        }
    }

    // MARK: Custom rows

    @ViewBuilder
    private func navRow<Destination: View>(
        _ title: String, icon: String, identifier: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: TwinkoSpacing.m) {
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.skyPurple)
                    .frame(width: 26)
                Text(title)
                    .font(.twinkoHeadline)
                    .foregroundStyle(Color.inkNavy)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.inkNavy.opacity(0.35))
            }
            .padding(TwinkoSpacing.m)
            .frame(minHeight: 54)
            .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Self.cardBorder.opacity(0.55), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    private func infoCard(_ title: String, _ value: String) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.twinkoCaption)
                .foregroundStyle(Color.inkNavy.opacity(0.55))
            Text(value)
                .font(.twinkoHeadline)
                .foregroundStyle(Color.inkNavy)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 74)
        .padding(TwinkoSpacing.s)
        .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Self.cardBorder.opacity(0.55), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    // MARK: Profile detail (read-only 2×2 cards)

    private var profileDetail: some View {
        ScrollView {
            VStack(spacing: TwinkoSpacing.m) {
                if let profile = profileStore.profile {
                    let sign = ZodiacSign.from(date: profile.birthday)
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: TwinkoSpacing.s),
                                        GridItem(.flexible(), spacing: TwinkoSpacing.s)],
                              spacing: TwinkoSpacing.s) {
                        infoCard(lang == .english ? "Name" : "稱呼", profile.preferredName)
                        infoCard(lang == .english ? "Birthday" : "生日",
                                 profile.birthday.formatted(
                                    Date.FormatStyle(locale: prefs.locale).year().month().day()))
                        infoCard(lang == .english ? "Zodiac" : "星座", "\(sign.symbol) \(sign.rawValue)")
                        infoCard(lang == .english ? "Gender" : "性別", profile.gender.rawValue)
                    }
                    NavigationLink {
                        EditProfileView()
                    } label: {
                        Text(lang == .english ? "Edit" : "編輯")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.twinkoPrimary)
                } else {
                    Text(lang == .english ? "No local profile yet." : "還沒有本機資料。")
                        .font(.twinkoBody)
                        .foregroundStyle(Color.inkNavy.opacity(0.6))
                }
            }
            .padding(TwinkoSpacing.m)
        }
        .background(Self.surface)
        .navigationTitle(HomeStrings.profile(lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Settings (Language only)

    private var settingsDetail: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                Text(HomeStrings.language(lang))
                    .font(.twinkoCaption)
                    .foregroundStyle(Color.inkNavy.opacity(0.55))
                    .padding(.leading, TwinkoSpacing.s)
                ForEach(AppLanguage.allCases) { option in
                    Button {
                        prefs.language = option
                    } label: {
                        HStack {
                            Text(option.displayName)
                                .font(.twinkoHeadline)
                                .foregroundStyle(Color.inkNavy)
                            Spacer()
                            if prefs.language == option {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.warmOrange)
                            }
                        }
                        .padding(TwinkoSpacing.m)
                        .frame(minHeight: 52)
                        .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Self.cardBorder.opacity(0.55), lineWidth: 1)
                        )
                    }
                    .accessibilityIdentifier("language-\(option.rawValue)")
                    .accessibilityAddTraits(prefs.language == option ? [.isSelected] : [])
                }
            }
            .padding(TwinkoSpacing.m)
        }
        .background(Self.surface)
        .navigationTitle(HomeStrings.settings(lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Privacy

    private var privacyDetail: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TwinkoSpacing.m) {
                Text(lang == .english
                     ? "This is a local prototype. Everything you enter — your profile and your chats — is stored only on this device, as plain files you can inspect and delete. Nothing is uploaded, synced, or shared, and there is no account."
                     : "這是一個本機原型。你輸入的所有內容——個人資料與聊天紀錄——都只以可檢視、可刪除的檔案存在這台裝置上。沒有上傳、沒有同步、沒有分享，也沒有帳號。")
                    .font(.twinkoBody)
                    .foregroundStyle(Color.inkNavy)
                Text(lang == .english
                     ? "This describes the prototype only; it is not a production privacy policy."
                     : "以上僅描述此原型的行為，不是正式產品的隱私權政策。")
                    .font(.twinkoCaption)
                    .foregroundStyle(Color.inkNavy.opacity(0.55))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Self.surface)
        .navigationTitle(HomeStrings.privacy(lang))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Edit Profile

/// Custom-designed Edit Profile (no system table): rounded field cards,
/// auto-derived read-only zodiac, gender chips, Cancel/Save. Saves
/// through the existing local JSON persistence.
struct EditProfileView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var prefs: PrefsStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var birthday: Date = .now
    @State private var gender: Gender = .preferNotToSay
    @State private var loaded = false

    private var lang: AppLanguage { prefs.language }
    private static let surface = Color(red: 0.965, green: 0.945, blue: 0.995)
    private static let cardBorder = Color(red: 0.83, green: 0.77, blue: 0.95)

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var canSave: Bool { !trimmedName.isEmpty }

    var body: some View {
        ScrollView {
            VStack(spacing: TwinkoSpacing.m) {
                fieldCard(lang == .english ? "Name" : "稱呼") {
                    TextField(lang == .english ? "Your name" : "你的名字或暱稱", text: $name)
                        .font(.twinkoBody)
                        .padding(10)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
                        .accessibilityIdentifier("editNameField")
                }

                fieldCard(lang == .english ? "Birthday" : "生日") {
                    DatePicker("", selection: $birthday, in: ...Date.now,
                               displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .environment(\.locale, prefs.locale)
                }

                fieldCard(lang == .english ? "Zodiac (auto)" : "星座（自動計算）") {
                    let sign = ZodiacSign.from(date: birthday)
                    Text("\(sign.symbol) \(sign.rawValue)")
                        .font(.twinkoHeadline)
                        .foregroundStyle(Color.inkNavy.opacity(0.75))
                        .accessibilityIdentifier("editZodiacValue")
                }

                fieldCard(lang == .english ? "Gender" : "性別") {
                    FlowHStack(spacing: TwinkoSpacing.s) {
                        ForEach(Gender.allCases) { option in
                            let selected = gender == option
                            Button {
                                gender = option
                            } label: {
                                Text(option.rawValue)
                                    .font(.twinkoBody)
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 8)
                                    .frame(minHeight: 38)
                                    .background(
                                        selected ? AnyShapeStyle(
                                            LinearGradient(colors: [.twinkoGold, .warmOrange],
                                                           startPoint: .top, endPoint: .bottom))
                                                 : AnyShapeStyle(Color.inkNavy.opacity(0.06)),
                                        in: Capsule()
                                    )
                                    .foregroundStyle(selected ? .white : Color.inkNavy)
                            }
                            .accessibilityAddTraits(selected ? [.isSelected] : [])
                        }
                    }
                }

                Button {
                    guard canSave else { return }
                    profileStore.save(UserProfile(preferredName: trimmedName,
                                                  birthday: birthday, gender: gender))
                    dismiss()
                } label: {
                    Text(lang == .english ? "Save" : "儲存")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.twinkoPrimary)
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.55)
                .accessibilityIdentifier("editSaveButton")

                Button {
                    dismiss()
                } label: {
                    Text(lang == .english ? "Cancel" : "取消")
                        .font(.twinkoHeadline)
                        .foregroundStyle(Color.inkNavy.opacity(0.6))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .accessibilityIdentifier("editCancelButton")
            }
            .padding(TwinkoSpacing.m)
        }
        .background(Self.surface)
        .navigationTitle(lang == .english ? "Edit Profile" : "編輯資料")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
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

    @ViewBuilder
    private func fieldCard<Content: View>(_ title: String,
                                          @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
            Text(title)
                .font(.twinkoCaption)
                .foregroundStyle(Color.inkNavy.opacity(0.55))
            content()
        }
        .padding(TwinkoSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Self.cardBorder.opacity(0.55), lineWidth: 1)
        )
    }
}

#Preview {
    ProfileSheetView()
        .environmentObject(ProfileStore())
        .environmentObject(PrefsStore())
}
