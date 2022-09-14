import AppIntents

struct RemoveDuplicatesFromList: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "RemoveDuplicatesFromListIntent"

	static let title: LocalizedStringResource = "Remove Duplicates from List"

	static let description = IntentDescription(
		"Removes duplicates from the input list.",
		categoryName: "List"
	)

	@Parameter(
		title: "List",
		description: "Tap and hold the parameter to select a variable to a list. Don't quick tap it.",
		supportedTypeIdentifiers: ["public.item"]
	)
	var list: [IntentFile]

	static var parameterSummary: some ParameterSummary {
		Summary("Remove duplicates from \(\.$list)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		.result(value: list.removingDuplicates(by: \.data))
	}
}
