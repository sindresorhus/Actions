import AppIntents

struct TruncateList: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "TruncateListIntent"

	static let title: LocalizedStringResource = "Truncate List"

	static let description = IntentDescription(
		"Truncates the input list to the given limit by removing items from the end.",
		categoryName: "List"
	)

	@Parameter(
		title: "List",
		description: "Tap and hold the parameter to select a variable to a list. Don't quick tap it.",
		supportedTypeIdentifiers: ["public.item"]
	)
	var list: [IntentFile]

	@Parameter(title: "Count", inclusiveRange: (0, 999_999))
	var limit: Int

	static var parameterSummary: some ParameterSummary {
		Summary("Truncate \(\.$list) to maximum \(\.$limit) items")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		let result = Array(list.prefix(limit))
		return .result(value: result)
	}
}
