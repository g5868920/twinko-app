import SwiftUI

/// Bottom sheet opened from Home's top-right Profile control (D-055
/// §10–§11): Profile / Settings / Privacy, with Language under
/// Settings. No Log Out — no authentication or account system exists.
struct ProfileSheetView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var prefs: PrefsStore

    private var lang: AppLanguage { prefs.language }

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    profileDetail
                } label: {
                    Label(HomeStrings.profile(lang), systemImage: "person.fill")
                }
                .accessibilityIdentifier("sheetProfileRow")

                NavigationLink {
                    settingsDetail
                } label: {
                    Label(HomeStrings.settings(lang), systemImage: "gearshape.fill")
                }
                .accessibilityIdentifier("sheetSettingsRow")

                NavigationLink {
                    privacyDetail
                } label: {
                    Label(HomeStrings.privacy(lang), systemImage: "hand.raised.fill")
                }
                .accessibilityIdentifier("sheetPrivacyRow")
            }
            .navigationBarTitleDisplayMode(.inline)
            .tint(.warmOrange)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: Profile

    private var profileDetail: some View {
        List {
            if let profile = profileStore.profile {
                LabeledContent(lang == .english ? "Name" : "稱呼", value: profile.preferredName)
                LabeledContent(lang == .english ? "Birthday" : "生日") {
                    Text(profile.birthday.formatted(
                        Date.FormatStyle(locale: prefs.locale).year().month().day()))
                }
                LabeledContent(lang == .english ? "Zodiac sign" : "星座") {
                    let sign = ZodiacSign.from(date: profile.birthday)
                    Text("\(sign.symbol) \(sign.rawValue)")
                }
                LabeledContent(lang == .english ? "Gender" : "性別", value: profile.gender.rawValue)
            } else {
                Text(lang == .english ? "No local profile yet." : "還沒有本機資料。")
            }
        }
        .navigationTitle(HomeStrings.profile(lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Settings

    private var settingsDetail: some View {
        List {
            Section(HomeStrings.language(lang)) {
                ForEach(AppLanguage.allCases) { option in
                    Button {
                        prefs.language = option
                    } label: {
                        HStack {
                            Text(option.displayName)
                                .foregroundStyle(.primary)
                            Spacer()
                            if prefs.language == option {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.warmOrange)
                            }
                        }
                    }
                    .accessibilityIdentifier("language-\(option.rawValue)")
                    .accessibilityAddTraits(prefs.language == option ? [.isSelected] : [])
                }
            }
        }
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
                Text(lang == .english
                     ? "This describes the prototype only; it is not a production privacy policy."
                     : "以上僅描述此原型的行為，不是正式產品的隱私權政策。")
                    .font(.twinkoCaption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(HomeStrings.privacy(lang))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileSheetView()
        .environmentObject(ProfileStore())
        .environmentObject(PrefsStore())
}
