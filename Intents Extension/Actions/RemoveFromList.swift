import AppIntents

struct RemoveFromList: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "RemoveFromListIntent"

	static let title: LocalizedStringResource = "Remove from List"

	static let description = IntentDescription(
"""
Removes items from the input list.

It uses 1-based indexing.

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

	@Parameter(title: "Action", default: .firstItem)
	var action: RemoveFromListActionAppEnum

	// TODO: If we specify inclusiveRange, it doesn't work if the action is `index`, since it would want us to specify `rangeLowerBound` too, which is not visible. (iOS 16.0)
	@Parameter(title: "Index", controlStyle: .field/*, inclusiveRange: (1, 999_999)*/)
	var index: Int?

	@Parameter(title: "Start Index", controlStyle: .field/*, inclusiveRange: (1, 999_999)*/)
	var rangeLowerBound: Int?

	@Parameter(title: "End Index", controlStyle: .field/*, inclusiveRange: (1, 999_999)*/)
	var rangeUpperBound: Int?

	@Parameter(title: "Count", default: 1/*, inclusiveRange: (0, 999_999)*/)
	var randomItemCount: Int?

	static var parameterSummary: some ParameterSummary {
		Switch(\.$action) {
			Case(.index) {
				Summary("Remove \(\.$action) \(\.$index) from \(\.$list)")
			}
			Case(.range) {
				Summary("Remove \(\.$action) \(\.$rangeLowerBound) to \(\.$rangeUpperBound) from \(\.$list)")
			}
			Case(.randomItems) {
				Summary("Remove \(\.$randomItemCount) \(\.$action) from \(\.$list)")
			}
			DefaultCase {
				Summary("Remove \(\.$action) from \(\.$list)")
			}
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		// TODO: We do not support removing multiple indices for `.index` as there is a bug in Shortcuts on macOS 12.0.1 where it does not correctly allow multiple values in the UI.

		let result: [IntentFile] = try {
			guard !list.isEmpty else {
				return []
			}

			switch action {
			case .firstItem:
				return Array(list.dropFirst())
			case .lastItem:
				return Array(list.dropLast())
			case .index:
				guard
					let index,
					list.indices.contains(index - 1) // Account for 1-based indexing.
				else {
					throw "You must specify a valid index.".toError
				}

				// Account for 1-based indexing.
				return list.removing(atIndices: [index - 1])
			case .range:
				guard
					let rangeLowerBound,
					let rangeUpperBound,
					list.indices.contains(rangeLowerBound - 1), // Account for 1-based indexing.
					list.indices.contains(rangeUpperBound - 1)
				else {
					throw "You must specify a valid range.".toError
				}

				// Account for 1-based indexing.
				let range = ClosedRange.fromGraceful(rangeLowerBound - 1, rangeUpperBound - 1)

				return list.removingSubrange(range)
			case .randomItems:
				guard
					let randomItemCount,
					randomItemCount >= 0
				else {
					throw "You must specify a count of 0 or higher".toError
				}

				let indices = list.uniqueRandomIndices(maxCount: randomItemCount)
				return list.removing(atIndices: indices)
			}
		}()

		return .result(value: result)
	}
}

enum RemoveFromListActionAppEnum: String, AppEnum {
	case firstItem
	case lastItem
	case index
	case range
	case randomItems

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Remove from List Action"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.firstItem: "First Item",
		.lastItem: "Last Item",
		.index: "Item at Index",
		.range: "Items in Range",
		.randomItems: "Random Items"
	]
}
