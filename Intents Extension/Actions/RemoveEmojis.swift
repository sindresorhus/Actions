import AppIntents

struct RemoveEmojiIntent: AppIntent {
	static let title: LocalizedStringResource = "Remove Emojis"

	static let description = IntentDescription(
		"Removes all emojis in the input text.",
		categoryName: "Text",
		resultValueName: "Text without Emojis"
	)

	@Parameter(title: "Text")
	var text: String

	static var parameterSummary: some ParameterSummary {
		Summary("Remove emojis in \(\.$text)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		.result(value: text.removingEmojis())
	}
}
