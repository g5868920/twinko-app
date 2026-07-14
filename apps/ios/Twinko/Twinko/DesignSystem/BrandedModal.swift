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

                VStack(spacing: 18) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(iconColor)
                            .frame(width: 52, height: 52)
                            .background(iconColor.opacity(0.14), in: Circle())
                    }
                    Text(title)
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color.deepPlum)
                        .multilineTextAlignment(.center)

                    content()

                    HStack(spacing: 12) {
                        Button(action: onCancel) {
                            Text(cancelTitle)
                                .font(.system(.body, design: .rounded).weight(.medium))
                                .foregroundStyle(Color.textSecondaryToken)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.surfaceSecondary, in: RoundedRectangle(cornerRadius: 24))
                        }

                        Button(action: onConfirm) {
                            Text(confirmTitle)
                                .font(.system(.body, design: .rounded).weight(.semibold))
                                .foregroundStyle(Color.textInverseToken)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(confirmBackground, in: RoundedRectangle(cornerRadius: 24))
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
