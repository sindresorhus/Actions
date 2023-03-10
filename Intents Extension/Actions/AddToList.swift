import AppIntents

struct AddToList: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "AddToListIntent"

	static let title: LocalizedStringResource = "Add to List"

	static let description = IntentDescription(
"""
Adds the input item to the given list.

Even though the description says this action accepts input of type Files, it accepts any type.

Note: If you get the error “The operation failed because Shortcuts couldn't convert from Text to NSString.”, just change the preview to show a list view instead. This is a bug in the Shortcuts app.
""",
		categoryName: "List",
		searchKeywords: [
			"append",
			"prepend",
			"push",
			"shift"
		]
	)

	@Parameter(
		title: "List",
		description: "Tap and hold the parameter to select a variable to a list. Don't quick tap it.",
		supportedTypeIdentifiers: ["public.item"]
	)
	var list: [IntentFile]

	@Parameter(title: "Item", supportedTypeIdentifiers: ["public.item"])
	var item: IntentFile

	@Parameter(
		title: "Prepend",
		default: false,
		displayName: Bool.IntentDisplayName(true: "Prepend", false: "Append")
	)
	var prepend: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("\(\.$prepend) \(\.$item) to \(\.$list)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		let result = prepend ? list.prepending(item) : list.appending(item)
		return .result(value: result)
	}
}
