import AppIntents

struct GetEmojisIntent: AppIntent {
	static let title: LocalizedStringResource = "Get Emojis"

	static let description = IntentDescription(
		"Returns all emojis in the input text.",
		categoryName: "Text",
		resultValueName: "Emojis"
	)

	@Parameter(
		title: "Text",
		inputOptions: .init(keyboardType: .default)
	)
	var text: String

	static var parameterSummary: some ParameterSummary {
		Summary("Get emojis in \(\.$text)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		.result(value: text.emojis.toString)
	}
}
