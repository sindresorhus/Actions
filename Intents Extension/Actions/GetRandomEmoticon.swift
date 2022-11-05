import AppIntents

struct GetRandomEmoticon: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "RandomEmojiIntent"

	static let title: LocalizedStringResource = "Get Random Emoticon"

	static let description = IntentDescription(
		"Returns a random emoticon (also known as smiley).",
		categoryName: "Random"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		.result(value: .randomEmoticon())
	}
}
