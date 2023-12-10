import AppIntents
import SwiftUI

// NOTE: It's intentionally in the app and not extension because when it's in the extension it causes the "Intents Extension" icon to show in the Dock. (macOS 14.0)

struct CreateMenuItem: AppIntent {
	static let title: LocalizedStringResource = "Create Menu Item"

	static let description = IntentDescription(
		"""
		Create a menu item with a title, subtitle, and icon.

		You can later use one or more of these menu items in a “Choose from List” action.

		Add an “Add to Variable” action below this one to populate a list and then use that variable in the “Choose From List” action.
		""",
		categoryName: "Miscellaneous",
		searchKeywords: [
			"choose",
			"rich",
			"list",
			"menuitem"
		],
		resultValueName: "Menu Item"
	)

	static var parameterSummary: some ParameterSummary {
		Switch(\.$iconType) {
			Case(.sfSymbol) {
				When(\.$backgroundShape, .equalTo, .noBackground) {
					Summary("Create menu item with title \(\.$menuTitle) and icon \(\.$sfSymbolName)") {
						\.$subtitle
						\.$iconType
						\.$foreground
						\.$backgroundShape
						\.$data
					}
				} otherwise: {
					Summary("Create menu item with title \(\.$menuTitle) and icon \(\.$sfSymbolName)") {
						\.$subtitle
						\.$iconType
						\.$foreground
						\.$background
						\.$backgroundShape
						\.$data
					}
				}
			}
			Case(.emoji) {
				When(\.$backgroundShape, .equalTo, .noBackground) {
					Summary("Create menu item with title \(\.$menuTitle) and icon \(\.$emoji)") {
						\.$subtitle
						\.$iconType
						\.$backgroundShape
						\.$data
					}
				} otherwise: {
					Summary("Create menu item with title \(\.$menuTitle) and icon \(\.$emoji)") {
						\.$subtitle
						\.$iconType
						\.$background
						\.$backgroundShape
						\.$data
					}
				}
			}
			// I don't think this can ever be hit.
			DefaultCase {
				Summary("Create menu item with title \(\.$menuTitle)") {}
			}
		}
	}

	@Parameter(
		title: "Title",
		inputOptions: .init(keyboardType: .default)
	)
	var menuTitle: String

	@Parameter(
		title: "SF Symbol",
		description: "Find symbol names here: https://developer.apple.com/sf-symbols/",
		inputOptions: .init(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var sfSymbolName: String?

	@Parameter(
		title: "Emoji",
		description: "Tap the emoji button on your keyboard and select one emoji.",
		inputOptions: .init(
			keyboardType: .default,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var emoji: String?

	@Parameter(
		title: "Subtitle",
		inputOptions: .init(keyboardType: .default)
	)
	var subtitle: String?

	@Parameter(title: "Icon Type", default: .sfSymbol)
	var iconType: MenuItemIconType

	@Parameter(
		title: "Foreground Color",
		default: .default
	)
	var foreground: MenuItemStyle

	@Parameter(
		title: "Background Color",
		description: "Use this in combination with the background shape to show a background behind the icon.",
		default: .default
	)
	var background: MenuItemStyle

	@Parameter(
		title: "Background Style",
		description: "The style of the icon's background.",
		default: .circle
	)
	var backgroundShape: MenuItemBackgroundShape

	@Parameter(
		title: "Data",
		inputOptions: .init(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var data: String?

	@MainActor
	func perform() async throws -> some IntentResult & ReturnsValue<MenuItem> {
		// Tries to work around some crash: https://github.com/sindresorhus/Actions/issues/180
		try? await Task.sleep(for: .seconds(0.1))

		let menuItem = MenuItem(
			title: menuTitle,
			subtitle: subtitle,
			icon: await makeIcon(),
			data: data
		)

		return .result(value: menuItem)
	}

	private func makeIcon() async -> Data? {
		switch iconType {
		case .sfSymbol:
			await IconContainerView(
				sfSymbol: sfSymbolName ?? "",
				foregroundColor: foreground.color(),
				backgroundColor: background.color(isBackground: true),
				backgroundShape: backgroundShape
			)
			.render()
		case .emoji:
			await IconContainerView(
				emoji: emoji ?? "",
				backgroundColor: background.color(isBackground: true),
				backgroundShape: backgroundShape
			)
			.render()
		}
	}
}

struct MenuItem: TransientAppEntity {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Menu Item"

	@Property(title: "Title")
	var title: String

	@Property(title: "Subtitle")
	var subtitle: String?

	@Property(title: "Icon")
	var icon: IntentFile?

	@Property(title: "Data")
	var data: String?

	init(
		title: String,
		subtitle: String? = nil,
		icon: Data? = nil,
		data: String? = nil
	) {
		self.icon = icon.flatMap { .init(data: $0, filename: "icon.png", type: .png) }
		self.title = title
		self.subtitle = subtitle
		self.data = data
	}

	init() {
		self.init(title: "", subtitle: nil)
	}

	var displayRepresentation: DisplayRepresentation {
		let image: DisplayRepresentation.Image? = if let icon {
			if #available(iOS 17.0, macOS 14.0, *) {
				.init(data: icon.data, displayStyle: .default)
			} else {
				.init(data: icon.data)
			}
		} else {
			nil
		}

		return .init(
			title: "\(title)",
			subtitle: subtitle.flatMap { "\($0)" } ?? "", // The `""` is required as otherwise the icon doesn't show. (macOS 14.0)
			image: image
		)
	}
}

enum MenuItemStyle: String, AppEnum {
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

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Menu Item Style"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.default: "Default",
		.red: "Red",
		.orange: "Orange",
		.yellow: "Yellow",
		.green: "Green",
		.mint: "Mint",
		.teal: "Teal",
		.cyan: "Cyan",
		.blue: "Blue",
		.purple: "Purple",
		.pink: "Pink",
		.brown: "Brown",
		.white: "White",
		.gray: "Gray",
		.black: "Black",
		.clear: "Clear"
	]

	func color(isBackground: Bool = false) -> Color {
		switch self {
		case .default:
			isBackground ? .white : .gray
		case .red:
			.red
		case .orange:
			.orange
		case .yellow:
			.yellow
		case .green:
			.green
		case .mint:
			.mint
		case .teal:
			.teal
		case .cyan:
			.cyan
		case .blue:
			.blue
		case .purple:
			.purple
		case .pink:
			.pink
		case .brown:
			.brown
		case .white:
			.white
		case .gray:
			.gray
		case .black:
			.black
		case .clear:
			.clear
		}
	}
}

enum MenuItemBackgroundShape: String, AppEnum {
	case circle
	case square
	case noBackground

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Menu Item Background Shape"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.circle: "Circle",
		.square: "Square",
		.noBackground: "No Background"
	]

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

enum MenuItemIconType: String, AppEnum {
	case sfSymbol
	case emoji

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Menu Item Icon Type"

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
}

private struct IconContainerView<Icon: View>: View {
	private let icon: Icon
	private let backgroundColor: Color
	private let backgroundShape: MenuItemBackgroundShape

	/**
	The icon will be clipped to 93x93.
	*/
	private init(
		@ViewBuilder icon: () -> Icon,
		background: Color,
		backgroundShape: MenuItemBackgroundShape
	) {
		self.icon = icon()
		self.backgroundColor = background
		self.backgroundShape = backgroundShape
	}

	init(
		emoji: String,
		backgroundColor: Color,
		backgroundShape: MenuItemBackgroundShape
	) where Icon == IconView {
		self.init(
			icon: { IconView(emoji: emoji) },
			background: backgroundColor,
			backgroundShape: backgroundShape
		)
	}

	init(
		sfSymbol systemName: String,
		foregroundColor: Color,
		backgroundColor: Color,
		backgroundShape: MenuItemBackgroundShape
	) where Icon == SymbolIconView {
		self.init(
			icon: {
				SymbolIconView(
					systemName: systemName,
					foregroundColor: foregroundColor == .primary ? .primary : foregroundColor
				)
			},
			background: backgroundColor,
			backgroundShape: backgroundShape
		)
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

	@MainActor
	func render() async -> Data? {
		let renderer = ImageRenderer(content: self)

		// We cannot fetch the scale here, so we just default to the best resolution.
		renderer.scale = 3

		return renderer.xImage?.pngData()
	}
}

private struct IconView: View {
	var emoji: String

	var body: some View {
		Text(String(emoji.prefix(2)))
			.font(.system(size: 70))
			.fontWeight(.semibold)
	}
}

private struct SymbolIconView: View {
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
