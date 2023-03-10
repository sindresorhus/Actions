import AppIntents

// NOTE: This must be in the app and not extension because when it's in the extension, it only returns a single item. (macOS 13.0.1)

struct RemoveDuplicatesFromList: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "RemoveDuplicatesFromListIntent"

	static let title: LocalizedStringResource = "Remove Duplicates from List"

	static let description = IntentDescription(
"""
Removes duplicates from the input list.

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
		Summary("Remove duplicates from \(\.$list)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		.result(value: list.removingDuplicates(by: \.data))
	}
}
