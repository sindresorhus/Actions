import AppIntents

struct RemoveEmptyLines: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "RemoveEmptyLinesIntent"

	static let title: LocalizedStringResource = "Remove Empty Lines"

	static let description = IntentDescription(
		"Removes empty and whitespace-only lines from the input text.",
		categoryName: "Text"
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
