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
		]
	)

	@Parameter(title: "List")
	var list: [String]

	@Parameter(title: "Item")
	var item: String

	static var parameterSummary: some ParameterSummary {
		Summary("Get the index of \(\.$item) in \(\.$list)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Int> {
		// TODO: The return value cannot be an optional so we return -1. (iOS 16.0)
		let result = list.firstIndex { $0 == item }.flatMap { $0 + 1 } ?? -1
		return .result(value: result)
	}
}
