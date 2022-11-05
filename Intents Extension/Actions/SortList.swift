import AppIntents

struct SortList: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "SortListIntent"

	static let title: LocalizedStringResource = "Sort List"

	static let description = IntentDescription(
		"Sorts the input list.",
		categoryName: "List"
	)

	@Parameter(title: "List", description: "A list of text and/or numbers.")
	var list: [String]

	@Parameter(
		title: "Sort Order",
		default: true,
		displayName: Bool.IntentDisplayName(true: "Ascending", false: "Descending")
	)
	var ascending: Bool

	@Parameter(title: "Sort Type", default: .natural)
	var sortType: SortTypeAppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Sort \(\.$list) in \(\.$ascending) order") {
			\.$sortType
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[String]> {
		let sortedList = list.sorted(
			type: sortType.toNative,
			order: ascending ? .forward : .reverse
		)

		return .result(value: sortedList)
	}
}

enum SortTypeAppEnum: String, AppEnum {
	case natural
	case localized
	case localizedCaseInsensitive
	case number

	static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Sort Type")

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.natural: "Natural",
		.localized: "Localized",
		.localizedCaseInsensitive: "Localized Case Insensitive",
		.number: "Number"
	]
}

extension SortTypeAppEnum {
	var toNative: SortType {
		switch self {
		case .natural:
			return .natural
		case .localized:
			return .localized
		case .localizedCaseInsensitive:
			return .localizedCaseInsensitive
		case .number:
			return .number
		}
	}
}
