import AppIntents

struct GetRandomColor: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "RandomColorIntent"

	static let title: LocalizedStringResource = "Get Random Color"

	static let description = IntentDescription(
		"Returns a random color in Hex format.",
		categoryName: "Random"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<ColorAppEntity> {
		.result(value: .init(.randomAvoidingBlackAndWhite()))
	}
}
