import AppIntents

struct TruncateTextIntent: AppIntent {
	static let title: LocalizedStringResource = "Truncate Text"

	static let description = IntentDescription(
		"Truncates the input text from the end to the given maximum length.",
		categoryName: "Text",
		resultValueName: "Truncated Text"
	)

	@Parameter(title: "Text")
	var text: String

	@Parameter(
		title: "Maximum Length",
		description: "Sets the maximum length for the resulting text, truncation character included."
	)
	var maximumLength: Int

	@Parameter(
		title: "Truncation Indicator",
		description: "The default indicator “…” is a single character called Horizontal Ellipsis, not three dots.",
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
