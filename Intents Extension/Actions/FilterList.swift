import AppIntents

struct FilterListIntent: AppIntent {
	static let title: LocalizedStringResource = "Filter List"

	static let description = IntentDescription(
		"""
		Choose which items to keep or discard in the input list based on a condition.

		Note: If you get the error “The operation failed because Shortcuts couldn't convert from Text to NSString.”, just change the preview to show a list view instead. This is a bug in the Shortcuts app.
		""",
		categoryName: "List",
		resultValueName: "Filtered List"
	)

	@Parameter(title: "List", description: "A list of text and/or numbers.")
	var list: [String]

	@Parameter(
		title: "Keep",
		default: true,
		displayName: Bool.IntentDisplayName(true: "Keep", false: "Remove")
	)
	var shouldKeep: Bool

	@Parameter(title: "Condition", default: .contains)
	var condition: FilterConditionAppEnum

	@Parameter(
		title: "Text",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var matchText: String

	@Parameter(title: "Case Sensitive", default: false)
	var caseSensitive: Bool

	@Parameter(title: "Limit", default: false)
	var shouldLimit: Bool

	@Parameter(title: "Maximum Results", default: 4)
	var limit: Int

	static var parameterSummary: some ParameterSummary {
		When(\.$shouldLimit, .equalTo, true) {
			Summary("\(\.$shouldKeep) items in \(\.$list) that \(\.$condition) \(\.$matchText)") {
				\.$shouldLimit
				\.$limit
				\.$caseSensitive
			}
		} otherwise: {
			Summary("\(\.$shouldKeep) items in \(\.$list) that \(\.$condition) \(\.$matchText)") {
				\.$shouldLimit
				\.$caseSensitive
			}
		}
	}

	private func isMatch(_ item: String) throws -> Bool {
		let item = caseSensitive ? item : item.lowercased()
		let matchText = caseSensitive ? matchText : matchText.lowercased()

		switch condition {
		case .contains:
			return item.contains(matchText)
		case .beginsWith:
			return item.hasPrefix(matchText)
		case .endsWith:
			return item.hasSuffix(matchText)
		case .regex:
			return try Regex(matchText).firstMatch(in: item) != nil
		case .is:
			return item == matchText
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[String]> {
		var newList = try list.filter { shouldKeep ? try isMatch($0) : try !isMatch($0) }

		if shouldLimit {
			newList = Array(newList.prefix(limit))
		}

		return .result(value: newList)
	}
}

enum FilterConditionAppEnum: String, AppEnum {
	case contains
	case beginsWith
	case endsWith
	case regex
	case `is`

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Filter Condition"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.contains: "contains",
		.beginsWith: "begins with",
		.endsWith: "ends with",
		.regex: "matches regex",
		.is: "is"
	]
}
