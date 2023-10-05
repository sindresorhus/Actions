import AppIntents

struct GetSymbolImage: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "SymbolImageIntent"

	static let title: LocalizedStringResource = "Get SF Symbol Image"

	static let description = IntentDescription(
"""
Returns a SF Symbols symbol as an image.

For example, “checkmark.circle.fill”.

Use the SF Symbols app to find the symbol you want.
""",
		categoryName: "Image"
	)

	@Parameter(
		title: "Symbol Name",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var symbolName: String

	@Parameter(title: "Size", default: 128, inclusiveRange: (8, 2000))
	var size: Int

	@Parameter(title: "Rendering", default: .monochrome)
	var rendering: SymbolImageRenderingAppEnum

	@Parameter(title: "Hex Color", default: "#ff69b4")
	var color: String?

	@Parameter(title: "Hex Color", default: ["#ff69b4"])
	var paletteColors: [String]

	static var parameterSummary: some ParameterSummary {
		Switch(\.$rendering) {
			Case(.monochrome) {
				Summary("Get symbol \(\.$symbolName) of size \(\.$size) as \(\.$rendering) \(\.$color)")
			}
			Case(.hierarchical) {
				Summary("Get symbol \(\.$symbolName) of size \(\.$size) as \(\.$rendering) \(\.$color)")
			}
			Case(.palette) {
				Summary("Get symbol \(\.$symbolName) of size \(\.$size) as \(\.$rendering) \(\.$paletteColors)")
			}
			DefaultCase {
				Summary("Get symbol \(\.$symbolName) of size \(\.$size) as \(\.$rendering)")
			}
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		guard size <= 2000 else {
			throw "The maximum size is 2000.".toError
		}

		var configuration = XImage.SymbolConfiguration(pointSize: Double(size), weight: .regular)

		switch rendering {
		case .monochrome:
			if
				let hexString = color,
				let color = XColor(hexString: hexString)
			{
				configuration = configuration.applying(XImage.SymbolConfiguration(paletteColors: [color]))
			}
		case .hierarchical:
			if
				let hexString = color,
				let color = XColor(hexString: hexString)
			{
				configuration = configuration.applying(XImage.SymbolConfiguration(hierarchicalColor: color))
			}
		case .palette:
			if let colors = (paletteColors.compactMap { XColor(hexString: $0) }).nilIfEmpty {
				configuration = configuration.applying(XImage.SymbolConfiguration(paletteColors: colors))
			}
		case .multicolor: // TODO: Does not work on macOS. (macOS 12.2) Check if it's fixed on macOS 13.
			configuration = configuration.applying(XImage.SymbolConfiguration.preferringMulticolor())
		}

		guard var image = XImage(systemName: symbolName) else {
			throw "No symbol with the given name or it requires a newer operating system version.".toError
		}

		image = image.withConfiguration(configuration)

		#if os(macOS)
		// See: https://developer.apple.com/forums/thread/663728
		image = image.normalizingImage()
		#endif

		let result = try image.toIntentFile(filename: symbolName)

		return .result(value: result)
	}
}

enum SymbolImageRenderingAppEnum: String, AppEnum {
	case monochrome
	case hierarchical
	case palette
	case multicolor

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Symbol Image Rendering"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.monochrome: "monochrome",
		.hierarchical: "hierarchical",
		.palette: "palette",
		.multicolor: "multicolor (iOS-only)"
	]
}
