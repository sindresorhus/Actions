import AppIntents

struct RemoveEmptyLinesIntent: AppIntent {
	static let title: LocalizedStringResource = "Remove Empty Lines"

	static let description = IntentDescription(
		"Removes empty and whitespace-only lines from the input text.",
		categoryName: "Text",
		resultValueName: "Text without Empty and Whitespace-only Lines"
	)

	@Parameter(title: "Text")
	var text: String

	static var parameterSummary: some ParameterSummary {
		Summary("Remove empty lines from \(\.$text)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		.result(value: text.removingEmptyLines())
	}
}
