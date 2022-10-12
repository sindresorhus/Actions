import AppIntents

struct ReverseLines: AppIntent {
	static let title: LocalizedStringResource = "Reverse Lines"

	static let description = IntentDescription(
		"Reverses the lines of the input text.",
		categoryName: "Text"
	)

	@Parameter(title: "Text")
	var text: String

	static var parameterSummary: some ParameterSummary {
		Summary("Reverse lines of \(\.$text)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		.result(value: text.reversingLines())
	}
}
