import AppIntents

struct GenerateUUID: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GenerateUUIDIntent"

	static let title: LocalizedStringResource = "Generate UUID"

	static let description = IntentDescription(
		"Generates a universally unique identifier (UUID).",
		categoryName: "Random"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		.result(value: UUID().uuidString)
	}
}
