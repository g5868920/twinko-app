import SwiftUI

/// Shared branded modal shell for Rename, Delete, and future
/// confirmations (DESIGN.md §26) — replaces native Alert / confirmation
/// dialog chrome so every popup in the app shares one component family.
struct BrandedModal<Content: View>: View {
    var icon: String? = nil
    var iconColor: Color = .destructiveToken
    let title: String
    @ViewBuilder var content: () -> Content
    let cancelTitle: String
    let confirmTitle: String
    var confirmDisabled = false
    var isDestructive = false
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.deepSpace.opacity(0.4)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)

                VStack(spacing: 15) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(iconColor)
                            .frame(width: 46, height: 46)
                            .background(iconColor.opacity(0.14), in: Circle())
                    }
                    // Headline-scale title (typography normalization
                    // 2026-07-17): modal text sits with the rest of the
                    // app instead of reading oversized.
                    Text(title)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.deepPlum)
                        .multilineTextAlignment(.center)

                    content()

                    HStack(spacing: 12) {
                        Button(action: onCancel) {
                            Text(cancelTitle)
                                .font(.system(.subheadline, design: .rounded).weight(.medium))
                                .foregroundStyle(Color.textSecondaryToken)
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .background(Color.surfaceSecondary, in: RoundedRectangle(cornerRadius: 23))
                        }

                        Button(action: onConfirm) {
                            Text(confirmTitle)
                                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                .foregroundStyle(Color.textInverseToken)
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .background(confirmBackground, in: RoundedRectangle(cornerRadius: 23))
                        }
                        .disabled(confirmDisabled)
                        .opacity(confirmDisabled ? 0.5 : 1.0)
                    }
                }
                .padding(22)
                .frame(width: geo.size.width * 0.86)
                .background(Color.surfacePrimary, in: RoundedRectangle(cornerRadius: 28))
                .shadowFloating()
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
    }

    private var confirmBackground: AnyShapeStyle {
        isDestructive
            ? AnyShapeStyle(Color.destructiveToken)
            : AnyShapeStyle(LinearGradient(colors: [.brandPurple, .brandPurpleDeep],
                                            startPoint: .top, endPoint: .bottom))
    }
}
