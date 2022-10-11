import AppIntents

struct AddToList: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "AddToListIntent"

	static let title: LocalizedStringResource = "Add to List"

	static let description = IntentDescription(
"""
Adds the input item to the given list.

Even though the description says this action accepts input of type Files, it accepts any type.
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

//	@Parameter(title: "Prepend", default: false, displayName: .init(true: "Prepend", false: "Append"))
	@Parameter(title: "Prepend instead of append", default: false)
	var prepend: Bool

	static var parameterSummary: some ParameterSummary {
		// TODO: iOS 16.0 only shows "On" even though we have specified a `displayName`.
//		Summary("\(\.$prepend) \(\.$item) to \(\.$list)")
		Summary("Add \(\.$item) to \(\.$list)") {
			\.$prepend
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		let result = prepend ? list.prepending(item) : list.appending(item)
		return .result(value: result)
	}
}
