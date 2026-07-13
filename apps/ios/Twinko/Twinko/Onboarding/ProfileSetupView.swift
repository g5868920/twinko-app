import SwiftUI

/// Consolidated single-screen Profile Setup (D-054): preferred name,
/// birthday, gender. Gender never affects any feature, safety
/// treatment, or access; birthday is used only for local zodiac
/// calculation. Everything stays on this device.
struct ProfileSetupView: View {
    @EnvironmentObject private var profileStore: ProfileStore

    @State private var name = ""
    @State private var birthday = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? .now
    @State private var gender: Gender?
    @FocusState private var nameFocused: Bool

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var canSave: Bool {
        !trimmedName.isEmpty && gender != nil
    }

    var body: some View {
        ZStack {
            TwinkoBackground.sky.ignoresSafeArea()
            StarFieldView()

            ScrollView {
                VStack(spacing: TwinkoSpacing.m) {
                    TwinkoCharacterView(mood: .listening, size: 110)
                        .padding(.top, TwinkoSpacing.s)

                    Text("讓 Twinko 更認識你")
                        .font(.twinkoTitle)
                        .foregroundStyle(.white)

                    Text("這些資料只會存在這台裝置上的原型裡，\n生日只用來計算你的星座。")
                        .font(.twinkoCaption)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)

                    TwinkoCard {
                        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                            Text("怎麼稱呼你？")
                                .font(.twinkoHeadline)
                                .foregroundStyle(Color.inkNavy)
                            TextField("你的名字或暱稱", text: $name)
                                .font(.twinkoBody)
                                .textFieldStyle(.roundedBorder)
                                .focused($nameFocused)
                                .submitLabel(.done)
                                .accessibilityIdentifier("profileNameField")
                            if nameFocused && trimmedName.isEmpty {
                                Text("名字不能是空白喔")
                                    .font(.twinkoCaption)
                                    .foregroundStyle(Color.cheekOrange)
                            }
                        }
                    }

                    TwinkoCard {
                        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                            Text("你的生日")
                                .font(.twinkoHeadline)
                                .foregroundStyle(Color.inkNavy)
                            DatePicker("生日", selection: $birthday,
                                       in: ...Date.now, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .accessibilityIdentifier("profileBirthdayPicker")
                            Text("星座：\(ZodiacSign.from(date: birthday).rawValue)")
                                .font(.twinkoCaption)
                                .foregroundStyle(Color.inkNavy.opacity(0.65))
                        }
                    }

                    TwinkoCard {
                        VStack(alignment: .leading, spacing: TwinkoSpacing.s) {
                            Text("你的性別")
                                .font(.twinkoHeadline)
                                .foregroundStyle(Color.inkNavy)
                            genderChips
                            Text("性別不會影響任何功能，只是讓 Twinko 知道怎麼陪你。")
                                .font(.twinkoCaption)
                                .foregroundStyle(Color.inkNavy.opacity(0.65))
                        }
                    }

                    Button {
                        guard let gender else { return }
                        profileStore.save(UserProfile(
                            preferredName: trimmedName,
                            birthday: birthday,
                            gender: gender
                        ))
                    } label: {
                        Text("完成")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.twinkoPrimary)
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.55)
                    .accessibilityIdentifier("profileSaveButton")
                    .padding(.top, TwinkoSpacing.s)
                    .padding(.bottom, TwinkoSpacing.xl)
                }
                .padding(.horizontal, TwinkoSpacing.m)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("基本資料")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var genderChips: some View {
        FlowHStack(spacing: TwinkoSpacing.s) {
            ForEach(Gender.allCases) { option in
                let selected = gender == option
                Button {
                    gender = option
                } label: {
                    Text(option.rawValue)
                        .font(.twinkoBody)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .frame(minHeight: 40)
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
}

/// Minimal wrapping HStack for the five gender chips.
struct FlowHStack: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileSetupView()
            .environmentObject(ProfileStore())
    }
    .environment(\.locale, Locale(identifier: "zh-Hant"))
}
