import AppIntents

struct CombineListsIntent: AppIntent {
	static let title: LocalizedStringResource = "Combine Lists"

	static let description = IntentDescription(
		"""
		Combines two or more lists into one list.

		Supports up to 10 lists.

		Tap and hold a list parameter to select a variable to a list. Don't quick tap it.

		Note: If you get the error “The operation failed because Shortcuts couldn't convert from Text to NSString.”, just change the preview to show a list view instead. This is a bug in the Shortcuts app.
		""",
		categoryName: "List",
		resultValueName: "Combined List"
	)

	@Parameter(title: "List 1", supportedTypeIdentifiers: ["public.item"])
	var list1: [IntentFile]

	// swiftlint:disable discouraged_optional_collection
	@Parameter(title: "List 2", supportedTypeIdentifiers: ["public.item"])
	var list2: [IntentFile]?

	@Parameter(title: "List 3", supportedTypeIdentifiers: ["public.item"])
	var list3: [IntentFile]?

	@Parameter(title: "List 4", supportedTypeIdentifiers: ["public.item"])
	var list4: [IntentFile]?

	@Parameter(title: "List 5", supportedTypeIdentifiers: ["public.item"])
	var list5: [IntentFile]?

	@Parameter(title: "List 6", supportedTypeIdentifiers: ["public.item"])
	var list6: [IntentFile]?

	@Parameter(title: "List 7", supportedTypeIdentifiers: ["public.item"])
	var list7: [IntentFile]?

	@Parameter(title: "List 8", supportedTypeIdentifiers: ["public.item"])
	var list8: [IntentFile]?

	@Parameter(title: "List 9", supportedTypeIdentifiers: ["public.item"])
	var list9: [IntentFile]?

	@Parameter(title: "List 10", supportedTypeIdentifiers: ["public.item"])
	var list10: [IntentFile]?
	// swiftlint:enable discouraged_optional_collection

	static var parameterSummary: some ParameterSummary {
		Summary("Combine \(\.$list1) with \(\.$list2)") {
			\.$list3
			\.$list4
			\.$list5
			\.$list6
			\.$list7
			\.$list8
			\.$list9
			\.$list10
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		let result = [
			list1,
			list2,
			list3,
			list4,
			list5,
			list6,
			list7,
			list8,
			list9,
			list10
		]
			.compact()
			.flatten()

		return .result(value: result)
	}
}
