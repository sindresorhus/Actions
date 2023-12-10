import AppIntents

struct GenerateUUIDIntent: AppIntent {
	static let title: LocalizedStringResource = "Generate UUID"

	static let description = IntentDescription(
		"Generates a universally unique identifier (UUID).",
		categoryName: "Random",
		resultValueName: "UUID"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		.result(value: UUID().uuidString)
	}
}
