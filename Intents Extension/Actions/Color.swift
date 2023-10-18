import AppIntents

struct ColorIntent: AppIntent {
	static let title: LocalizedStringResource = "Color"

	static let description = IntentDescription(
"""
Create a color type.

This color type can be used as input for the following actions:
- Get Average Color

This color type is the return value of the following actions:
- Get Random Color
- Get Dominant Colors of Image
- Get Average Color of Image

For example, you could get the two most dominant colors of an image using the “Get Dominant Colors of Image” action and then pass the result into the “Get Average Color” action to get the average of those.
""",
		categoryName: "Color",
		searchKeywords: [
			"colour"
		]
	)

	@Parameter(
		title: "Color (hex format)",
		description:
			"""
			Example: #ff69b4
			Example: #80ff69b4 (with 50% opacity)
			""",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var color: String

	// TODO: Add opacity slider.

	static var parameterSummary: some ParameterSummary {
		Summary("\(\.$color)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<ColorAppEntity> {
		guard let color = XColor(hexString: color) else {
			throw "Invalid Hex color.".toError
		}

		return .result(value: .init(color))
	}
}
