import AppIntents

struct GetIndexOfListItem: AppIntent {
	static let title: LocalizedStringResource = "Get Index of List Item"

	static let description = IntentDescription(
		"""
		Returns the position of the item in the list, or -1 if the item is not in the list.

		It uses 1-based indexing.
		""",
		categoryName: "List",
		searchKeywords: [
			"indices"
		],
		resultValueName: "Index of List Item"
	)

	@Parameter(title: "List")
	var list: [String]

	@Parameter(
		title: "Item",
		inputOptions: .init(keyboardType: .default)
	)
	var item: String

	static var parameterSummary: some ParameterSummary {
		Summary("Get the index of \(\.$item) in \(\.$list)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Int> {
		// TODO: The return value cannot be an optional so we return -1.
		// Update: This is now possible, but it would be a breaking change to change it. I can consider creating a new action for this in the future and deprecate the old one.
		let result = list.firstIndex { $0 == item }.flatMap { $0 + 1 } ?? -1
		return .result(value: result)
	}
}
