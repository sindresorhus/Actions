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

	@Parameter(title: "Ascending", default: true)
//	@Parameter(title: "Sort Order", default: true, displayName: .init(true: "Ascending", false: "Descending"))
	var ascending: Bool

	@Parameter(title: "Sort Type", default: .natural)
	var sortType: SortTypeAppEnum

	static var parameterSummary: some ParameterSummary {
		// TODO: iOS 16.0 only shows "On" for ascending even though we have specified a `displayName`.
//		Summary("Sort \(\.$list) in \(\.$ascending) order") {
//			\.$sortType
//		}
		Summary("Sort \(\.$list)") {
			\.$ascending
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

	static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Sort Type")

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.natural: "Natural",
		.localized: "Localized",
		.localizedCaseInsensitive: "Localized Case Insensitive"
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
		}
	}
}
