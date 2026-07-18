import SwiftUI

/// Shared circular container for Twinko's chat avatar (DESIGN.md §26).
/// Keeps the character legible against the illustrated background —
/// warm-ivory disc, soft border, small neutral shadow, no glow or
/// status indicator. Shown only on the first message of a Twinko group.
struct TwinkoChatAvatar: View {
    let assetName: String
    var containerSize: CGFloat = 38
    var imageSize: CGFloat = 30

    var body: some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .frame(width: imageSize, height: imageSize)
            .frame(width: containerSize, height: containerSize)
            // Translucent warm glass instead of an opaque white disc —
            // matches the speech-bubble material.
            .background(Color.surfacePrimary.opacity(0.72), in: Circle())
            .overlay(
                Circle().strokeBorder(
                    LinearGradient(stops: [
                        .init(color: .white.opacity(0.85), location: 0),
                        .init(color: Color.borderSoft.opacity(0.8), location: 1),
                    ], startPoint: .top, endPoint: .bottom),
                    lineWidth: 1)
            )
            .shadowSmall()
            .accessibilityHidden(true)
    }
}

#Preview {
    ZStack {
        TwinkoBackground.night
        TwinkoChatAvatar(assetName: "twinko_chat_day_v1_transparent")
    }
}
