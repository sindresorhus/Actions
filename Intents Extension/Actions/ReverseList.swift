import AppIntents

struct ReverseList: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "ReverseListIntent"

	static let title: LocalizedStringResource = "Reverse List"

	static let description = IntentDescription(
"""
Reverses the input list.

Note: If you get the error “The operation failed because Shortcuts couldn't convert from Text to NSString.”, just change the preview to show a list view instead. This is a bug in the Shortcuts app.
""",
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
