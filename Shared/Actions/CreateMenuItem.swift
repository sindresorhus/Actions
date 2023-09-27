import Foundation
import AppIntents
import SwiftUI

// MARK: Action
struct CreateMenuItem: AppIntent {
	static let title: LocalizedStringResource = "Create Menu Item"

	static let description = IntentDescription(
"""
Create a menu item with a title, subtitle and icon.

You can later use one or more of these Items in a "Choose from List" action.

Add an "Add to Variable" action below this to populate a list and then use that variable in the "Choose From List" action.
""",
		categoryName: "Rich Menu",
		searchKeywords: [
			"menu",
			"menu item",
			"choose from menu",
			"rich menu"
		]
	)

	static var parameterSummary: some ParameterSummary {
		Switch(\.$iconType) {
			// MARK: SFSymbol
			Case(RMIconType.sfSymbol) {
				When(\.$backgroundShape, .equalTo, .noBackground) {
					Summary("Create \(\.$menuTitle) with \(\.$systemName) and \(\.$subtitle)") {
						\.$iconType
						\.$foreground
						\.$backgroundShape
						\.$data
					}
				} otherwise: {
					Summary("Create \(\.$menuTitle) with \(\.$systemName) and \(\.$subtitle)") {
						\.$iconType
						\.$foreground
						\.$backgroundShape
						\.$background
						\.$data
					}
				}
			}
			
			// MARK: Emoji
			Case(RMIconType.emoji) {
				When(\.$backgroundShape, .equalTo, .noBackground) {
					Summary("Create \(\.$menuTitle) with \(\.$emoji) and \(\.$subtitle)") {
						\.$iconType
						\.$foreground
						\.$backgroundShape
						\.$data
					}
				} otherwise: {
					Summary("Create \(\.$menuTitle) with \(\.$emoji) and \(\.$subtitle)") {
						\.$iconType
						\.$foreground
						\.$backgroundShape
						\.$background
						\.$data
					}
				}
			}
			
			DefaultCase {
				Summary("Create Item with \(\.$menuTitle) and \(\.$subtitle)") {
					\.$iconType
					\.$backgroundShape
					\.$background
					\.$data
				}
			}
		}
	}

	@Parameter(title: "Title")
	var menuTitle: String

	@Parameter(title: "Subtitle")
	var subtitle: String?

	@Parameter(
		title: "Icon",
		default: .sfSymbol
	)
	var iconType: RMIconType

	@Parameter(
		title: "Background",
		description:
"""
A Background for your Icon

Use this in combination with background shape to show a background behind your icon
""",
		default: .default
	)
	var background: RMStyle

	// SF Symbol
	@Parameter(
		title: "SF Symbol",
		description: """
  The name of a SF Symbol

  For available symbols see Apple's website (https://developer.apple.com/sf-symbols/)
  """
	)
	var systemName: String

	@Parameter(
		title: "Foreground",
		description: "The color for your SF Symbol",
		default: .default
	)
	var foreground: RMStyle

	// Emoji
	@Parameter(
		title: "Emoji",
		description:
"""
Any Emoji 😀.

Tap the Emoji button on your keyboard and select one emoji.
""",
		inputOptions: .init(keyboardType: .default)
	)
	var emoji: String?

	@Parameter(
		title: "Data"
	)
	var data: String?

	@Parameter(
		title: "Background Style",
		description:
"""
The style of the icon's background.
""",
		default: .circle
	)
	var backgroundShape: RMBackgroundShape

	func makeIcon() async -> Data? {
		switch iconType {
		case .sfSymbol:
			return await RMIconContainer(
				sfSymbol: systemName,
				foregroundColor: foreground.color(),
				backgroundColor: background.color(isBackground: true),
				backgroundShape: backgroundShape
			)
			.render()
		case .emoji:
			return await RMIconContainer(
				emoji: emoji ?? "",
				backgroundColor: background.color(isBackground: true),
				backgroundShape: backgroundShape
			)
			.render()
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<MenuItem>  {
		let icon = await makeIcon()

		let item = MenuItem(
			title: menuTitle,
			subtitle: subtitle,
			icon: icon
		)

		return .result(value: item)
	}
}

// MARK: Menu Item
struct MenuItem: TransientAppEntity {
	init() {
		self.init(title: "", subtitle: nil)
	}

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Menu Item"

	var displayRepresentation: DisplayRepresentation {
		let title: LocalizedStringResource = "\(title)"
		let subtitle: LocalizedStringResource? = if let subtitle  { "\(subtitle)" } else { nil }
		let image: DisplayRepresentation.Image? = if let icon {
			if #available(iOS 17.0, macOS 14.0, *) {
				.init(data: icon.data, displayStyle: .default)
			} else {
				.init(data: icon.data)
			}
		} else {
			nil
		}

		return DisplayRepresentation(
			title: title,
			subtitle: subtitle,
			image: image
		)
	}

	@Property(title: "Title")
	var title: String

	@Property(title: "Subtitle")
	var subtitle: String?

	@Property(title: "Icon")
	var icon: IntentFile?

	init(
		title: String,
		subtitle: String? = nil,
		icon: Data? = nil
	) {
		if let icon {
			self.icon = .init(data: icon, filename: "icon.png", type: .png)
		} else {
			self.icon = nil
		}
		self.title = title
		self.subtitle = subtitle
	}
}

// MARK: Style
/**
 A Style for an Icon or it's background
 */
enum RMStyle: String, AppEnum {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Style"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.default: "default",
		.red: "red",
		.orange: "orange",
		.yellow: "yellow",
		.green: "green",
		.mint: "mint",
		.teal: "teal",
		.cyan: "cyan",
		.blue: "blue",
		.purple: "purple",
		.pink: "pink",
		.brown: "brown",
		.white: "white",
		.gray: "gray",
		.black: "black",
		.clear: "clear"
	]

	case `default`
	case red
	case orange
	case yellow
	case green
	case mint
	case teal
	case cyan
	case blue
	case purple
	case pink
	case brown
	case white
	case gray
	case black
	case clear

	/**
	 Converts to color
	 - Parameter isBackground: differentiator for default color
	 - Returns: Color
	 */
	func color(isBackground: Bool = false) -> Color {
		switch self {
		case .default:
			return isBackground ? .white : .gray
		case .red:
			return .red
		case .orange:
			return .orange
		case .yellow:
			return .yellow
		case .green:
			return .green
		case .mint:
			return .mint
		case .teal:
			return .teal
		case .cyan:
			return .cyan
		case .blue:
			return .blue
		case .purple:
			return .purple
		case .pink:
			return .pink
		case .brown:
			return .brown
		case .white:
			return .white
		case .gray:
			return .gray
		case .black:
			return .black
		case .clear:
			return .clear
		}
	}
}


// MARK: Background Shape
/**
 Shape for an Icon's Background
 */
enum RMBackgroundShape: String, AppEnum {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Background Shape"


	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.circle: "circle",
		.square: "square",
		.noBackground: "no background"
	]

	case circle
	case square
	case noBackground


	var shape: AnyShape? {
		switch self {
		case .circle:
			AnyShape(Circle())
		case .square:
			AnyShape(RoundedRectangle(cornerRadius: 10))
		case .noBackground:
			nil
		}
	}
}


// MARK: Icon
enum RMIconType: String, AppEnum {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Icon Type"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.sfSymbol: .init(
			title: "SF Symbol",
			image: .init(named: "circle.fill")
		),
		.emoji: .init(
			title: "Emoji",
			image: .init(named: "face.smiling")
		)
	]

	case sfSymbol
	case emoji
}


/**
 Container for rendering Icons in Menu Items
 */
struct RMIconContainer<Icon: View>: View {
	let icon: Icon
	var backgroundColor: Color
	var backgroundShape: RMBackgroundShape

	/**
	 Initializes with a custom view as the icon and the specified background color
	 - Parameters:
	 - icon: Any view. Will be clipped to 93x93.
	 - background: a color
	 - backgroundShape: Shape for the background
	 */
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
	/**
	 Initializes with a an emoji icon with the specified background color
	 - Parameters:
	 - emoji: Emoji String :-)
	 - background: a color
	 - backgroundShape: Shape for the background
	 */
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

	/**
	 Initializes with a an SFSymbol icon with the specified background color
	 - Parameters:
	 - sfSymbol: SF Symbol ,
	 - background: a color
	 - backgroundShape: Shape for the background
	 */
	init(
		sfSymbol systemName: String,
		foregroundColor: Color,
		backgroundColor: Color,
		backgroundShape: RMBackgroundShape
	) where Icon == RMSymbolIconView {
		self.init(icon: {
			RMSymbolIconView(
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


struct RMSymbolIconView: View {
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
