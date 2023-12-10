import AppIntents

struct RandomEmojiIntent: AppIntent {
	static let title: LocalizedStringResource = "Get Random Emoticon"

	static let description = IntentDescription(
		"Returns a random emoticon (also known as smiley).",
		categoryName: "Random",
		resultValueName: "Random Emoticon"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		.result(value: .randomEmoticon())
	}
}
