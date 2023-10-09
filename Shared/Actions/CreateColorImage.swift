import AppIntents

struct CreateColorImage: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "CreateColorImageIntent"

	static let title: LocalizedStringResource = "Create Color Image"

	static let description = IntentDescription(
		"Creates a solid color image.",
		categoryName: "Image"
	)

	@Parameter(
		title: "Hex Color",
		default: "#ff69b4",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var color: String

	@Parameter(title: "Width", inclusiveRange: (1, 8000))
	var width: Int

	@Parameter(title: "Height", inclusiveRange: (1, 8000))
	var height: Int

	@Parameter(title: "Opacity", default: 1, controlStyle: .slider, inclusiveRange: (0, 1))
	var opacity: Double

	static var parameterSummary: some ParameterSummary {
		Summary("Create image of color \(\.$color) with size \(\.$width)×\(\.$height)") {
			\.$opacity
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		guard
			let color = XColor(hexString: color, opacity: opacity)
		else {
			throw "Invalid color.".toError
		}

		let result = try XImage.color(
			color,
			size: .init(width: width, height: height),
			scale: 1
		)
			.toIntentFile()

		return .result(value: result)
	}
}
