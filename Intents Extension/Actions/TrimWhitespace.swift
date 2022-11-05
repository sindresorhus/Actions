import AppIntents

struct TrimWhitespace: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "TrimWhitespaceIntent"

	static let title: LocalizedStringResource = "Trim Whitespace"

	static let description = IntentDescription(
		"Removes leading & trailing whitespace and newline characters from the input text.",
		categoryName: "Text"
	)

	@Parameter(title: "Text")
	var text: String

	static var parameterSummary: some ParameterSummary {
		Summary("Trim leading and trailing whitespace from \(\.$text)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		.result(value: text.trimmingCharacters(in: .whitespacesAndNewlines))
	}
}
