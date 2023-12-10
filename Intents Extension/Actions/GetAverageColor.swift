import AppIntents

struct GetAverageColorIntent: AppIntent {
	static let title: LocalizedStringResource = "Get Average Color"

	// FB13291593: https://github.com/feedback-assistant/reports/issues/429
	static let description = IntentDescription(
		"""
		Returns the average color of the input colors.

		IMPORTANT: Because of a bug in the Shortcuts app, you must first make the colors you want with the “Color” action, then pass the colors to the “List” action, and then pass the list to this action. (If you work at Apple → FB13291593)
		""",
		categoryName: "Color",
		searchKeywords: [
			"colour"
		],
		resultValueName: "Average Color"
	)

	@Parameter(
		title: "Color"
//		description: "Pass in the result of the “Color” action."
	)
	var colors: [ColorAppEntity]

	static var parameterSummary: some ParameterSummary {
		Summary("Get the average color of \(\.$colors) (Please read the action description)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<ColorAppEntity> {
		guard
			let averageColor = (colors.compactMap { $0.toColor }.averageColor())
		else {
			throw "No valid colors were specified.".toError
		}

		return .result(value: .init(averageColor))
	}
}
