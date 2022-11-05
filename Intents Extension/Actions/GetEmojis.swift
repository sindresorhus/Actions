import AppIntents

struct GetEmojis: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GetEmojisIntent"

	static let title: LocalizedStringResource = "Get Emojis"

	static let description = IntentDescription(
		"Returns all emojis in the input text.",
		categoryName: "Text"
	)

	@Parameter(title: "Text")
	var text: String

	static var parameterSummary: some ParameterSummary {
		Summary("Get emojis in \(\.$text)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		.result(value: text.emojis.toString)
	}
}
