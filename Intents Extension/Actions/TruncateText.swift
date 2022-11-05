import AppIntents

struct TruncateText: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "TruncateTextIntent"

	static let title: LocalizedStringResource = "Truncate Text"

	static let description = IntentDescription(
		"Truncates the input text from the end to the given maximum length.",
		categoryName: "Text"
	)

	@Parameter(title: "Text")
	var text: String

	@Parameter(title: "Maximum Length")
	var maximumLength: Int

	@Parameter(
		title: "Truncation Indicator",
		default: "…",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var truncationIndicator: String

	static var parameterSummary: some ParameterSummary {
		Summary("Truncate \(\.$text) to \(\.$maximumLength) characters") {
			\.$truncationIndicator
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		let result = text.truncating(
			to: maximumLength,
			truncationIndicator: truncationIndicator
		)

		return .result(value: result)
	}
}
