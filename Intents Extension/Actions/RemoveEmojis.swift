import AppIntents

struct RemoveEmojis: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "RemoveEmojiIntent"

    static let title: LocalizedStringResource = "Remove Emojis"

	static let description = IntentDescription(
		"Removes all emojis in the input text.",
		categoryName: "Text"
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
