import SwiftUI

/// A single row inside a `BrandedActionPopover`.
struct BrandedActionPopoverRow: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let tint: Color
    let action: () -> Void
}

/// Branded compact action popover (DESIGN.md §27) — replaces native
/// `Menu` / `ContextMenu` chrome for row-level actions. Anchors near
/// the control that opened it, dims the screen behind it, and closes
/// on outside tap.
struct BrandedActionPopover: View {
    /// The opening control's frame, in the coordinate space this
    /// popover is overlaid in.
    let anchor: CGRect
    let rows: [BrandedActionPopoverRow]
    let onDismiss: () -> Void

    private let width: CGFloat = 160
    private let rowHeight: CGFloat = 50

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Color.deepSpace.opacity(0.2)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { onDismiss() }
                    .accessibilityHidden(true)

                VStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                        Button {
                            onDismiss()
                            row.action()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: row.icon)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(row.tint)
                                    .frame(width: 20)
                                Text(row.label)
                                    .font(.system(.body, design: .rounded).weight(.medium))
                                    .foregroundStyle(row.tint)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 14)
                            .frame(width: width, height: rowHeight)
                            .contentShape(Rectangle())
                        }
                        .frame(minHeight: 44)
                        if index < rows.count - 1 {
                            Divider()
                                .overlay(Color.textInverseToken.opacity(0.12))
                                .padding(.horizontal, 10)
                        }
                    }
                }
                .background(Color.menuDeep, in: RoundedRectangle(cornerRadius: 17))
                .shadowMedium()
                .frame(width: width)
                .position(popoverPosition(rowCount: rows.count, in: geo.size))
            }
        }
        .transition(.opacity)
    }

    private func popoverPosition(rowCount: Int, in containerSize: CGSize) -> CGPoint {
        let height = CGFloat(rowCount) * rowHeight
        let rawX = anchor.maxX - width / 2
        let rawY = anchor.maxY + 6 + height / 2
        let x = min(max(rawX, width / 2 + 8), containerSize.width - width / 2 - 8)
        let y = min(rawY, containerSize.height - height / 2 - 8)
        return CGPoint(x: x, y: y)
    }
}
