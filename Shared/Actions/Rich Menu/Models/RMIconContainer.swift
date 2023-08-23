import SwiftUI

/// Container for rendering Icons in Menu Items
struct RMIconContainer<Icon: View>: View {
    let icon: Icon
    var backgroundColor: Color
    var backgroundShape: RMBackgroundShape

    /// Initializes with a custom view as the icon and the specified background color
    /// - Parameters:
    ///   - icon: any view, will be clipped to 93x93
    ///   - background: a color
    ///   - backgroundShape: Shape for the background
    private init(
        @ViewBuilder
        icon: () -> Icon,
        background: Color,
        backgroundShape: RMBackgroundShape
    ) {
        self.icon = icon()
        self.backgroundColor = background
        self.backgroundShape = backgroundShape
    }

    /// Initializes with a an emoji icon with the specified background color
    /// - Parameters:
    ///   - emoji: Emoji String :-) ,
    ///   - background: a color
    ///   - backgroundShape: Shape for the background
    init(
        emoji: String,
        backgroundColor: Color,
        backgroundShape: RMBackgroundShape
    ) where Icon == RMEmojiIconView {
        self.init(
            icon: { RMEmojiIconView(emoji: emoji) },
            background: backgroundColor, backgroundShape: backgroundShape
        )
    }

    /// Initializes with a an SFSymbol icon with the specified background color
    /// - Parameters:
    ///   - sfSymbol: SF Symbol Name ,
    ///   - background: a color
    ///   - backgroundShape: Shape for the background
    init(
        sfSymbol systemName: String,
        foregroundColor: Color,
        backgroundColor: Color,
        backgroundShape: RMBackgroundShape
    ) where Icon == RMSybmolIconView {
        self.init(icon: {
            RMSybmolIconView(
                systemName: systemName,
                foregroundColor: foregroundColor == .primary ? .primary : foregroundColor
            )
        }, background: backgroundColor, backgroundShape: backgroundShape)
    }


    var body: some View {
        icon
            .frame(width: 93, height: 93)
            .background {
                if let shape = backgroundShape.shape {
                    shape
                        .foregroundStyle(.quaternary)
                        .foregroundColor(backgroundColor)
                }
            }
    }

    @MainActor func render() async -> Data? {
        let renderer = ImageRenderer(content: self)

        // scale doesn't really matter
        renderer.scale = 1

        let data: Data?


#if os(macOS)
        guard let image = renderer.nsImage else {
            return nil
        }

        data = image.tiffRepresentation
#else
        guard let image = renderer.uiImage else {
            return nil
        }

        data = image.pngData()
#endif

        return data
    }
}


struct RMEmojiIconView: View {
    var emoji: String

    var body: some View {
        Text(String(emoji.prefix(2)))
            .font(.system(size: 70))
            .fontWeight(.semibold)
    }
}

struct RMSybmolIconView: View {
    let systemName: String
    let foregroundColor: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 50))
            .fontWeight(.semibold)
            .foregroundColor(foregroundColor)
            .padding(5)
    }
}
