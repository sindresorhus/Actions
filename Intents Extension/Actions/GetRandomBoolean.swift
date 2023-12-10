import AppIntents

struct RandomBooleanIntent: AppIntent {
	static let title: LocalizedStringResource = "Get Random Boolean"

	static let description = IntentDescription(
		"Returns a random boolean. Think of it as a random “Yes” or “No” answer.",
		categoryName: "Random",
		resultValueName: "Random Boolean"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: .random())
	}
}
