import AppIntents

struct ReverseList: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "ReverseListIntent"

	static let title: LocalizedStringResource = "Reverse List"

	static let description = IntentDescription(
		"Reverses the input list.",
		categoryName: "List"
	)

	@Parameter(
		title: "List",
		description: "Tap and hold the parameter to select a variable to a list. Don't quick tap it.",
		supportedTypeIdentifiers: ["public.item"]
	)
	var list: [IntentFile]

	static var parameterSummary: some ParameterSummary {
		Summary("Reverse \(\.$list)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		.result(value: list.reversed())
	}
}
