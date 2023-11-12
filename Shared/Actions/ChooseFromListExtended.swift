import AppIntents
import SwiftUI

struct ChooseFromListExtendedIntent: AppIntent {
	static let title: LocalizedStringResource = "Choose from List (Extended)"

	static let description = IntentDescription(
		"""
		Presents a searchable list where you can select one or multiple items.

		It also supports setting a timeout and interactively adding custom items.

		This is an extended version of the built-in “Choose from List” action.

		IMPORTANT: Add the “Wait to Return” and “Get Clipboard” actions after this one.

		Note: If you get the error “The operation failed because Shortcuts couldn't convert from Text to NSString.”, just change the preview to show a list view instead. This is a bug in the Shortcuts app.
		""",
		categoryName: "Utility",
		searchKeywords: [
			"fuzzy",
			"find"
		]
	)

	static let openAppWhenRun = true

	@Parameter(title: "List")
	var list: [String]

	@Parameter(title: "Prompt", description: "Keep it short.")
	var prompt: String?

	@Parameter(title: "Message", description: "Shown above the choices. This one can be longer. For example, use it to show instructions.")
	var message: String?

	@Parameter(title: "Select Multiple", default: false)
	var selectMultiple: Bool

	@Parameter(title: "Select All Initially", default: false)
	var selectAllInitially: Bool

	@Parameter(title: "Allow Custom Items", default: false)
	var allowCustomItems: Bool

	@Parameter(title: "Use Timeout", default: false)
	var useTimeout: Bool

	@Parameter(
		title: "Timeout",
		defaultValue: 10,
		defaultUnit: .seconds,
		supportsNegativeNumbers: false
	)
	var timeout: Measurement<UnitDuration>?

	@Parameter(title: "Return Value on Timeout", default: .nothing)
	var timeoutReturnValue: ChooseFromListTimeoutValueAppEnum

	static var parameterSummary: some ParameterSummary {
		When(\.$selectMultiple, .equalTo, true) {
			When(\.$useTimeout, .equalTo, true) {
				Summary("Choose from \(\.$list)") {
					\.$prompt
					\.$message
					\.$selectMultiple
					\.$selectAllInitially
					\.$useTimeout
					\.$timeout
					\.$timeoutReturnValue
					\.$allowCustomItems
				}
			} otherwise: {
				Summary("Choose from \(\.$list)") {
					\.$prompt
					\.$message
					\.$selectMultiple
					\.$selectAllInitially
					\.$useTimeout
					\.$allowCustomItems
				}
			}
		} otherwise: {
			When(\.$useTimeout, .equalTo, true) {
				Summary("Choose from \(\.$list)") {
					\.$prompt
					\.$message
					\.$selectMultiple
					\.$useTimeout
					\.$timeout
					\.$timeoutReturnValue
					\.$allowCustomItems
				}
			} otherwise: {
				Summary("Choose from \(\.$list)") {
					\.$prompt
					\.$message
					\.$selectMultiple
					\.$useTimeout
					\.$allowCustomItems
				}
			}
		}
	}

	@MainActor
	func perform() async throws -> some IntentResult {
		withoutAnimation {
			AppState.shared.chooseFromListData = .init(
				list: list,
				title: prompt?.nilIfEmptyOrWhitespace,
				message: message?.nilIfEmptyOrWhitespace,
				selectMultiple: selectMultiple,
				selectAllInitially: selectAllInitially,
				allowCustomItems: allowCustomItems,
				timeout: useTimeout ? timeout?.converted(to: .seconds).value.timeIntervalToDuration : nil,
				timeoutReturnValue: timeoutReturnValue
			)
		}

		return .result()
	}
}

enum ChooseFromListTimeoutValueAppEnum: String, AppEnum {
	case nothing
	case firstItem
	case lastItem
	case randomItem

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Choose from List Timeout Value"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.nothing: "Nothing",
		.firstItem: "First Item",
		.lastItem: "Last Item",
		.randomItem: "Random Item"
	]
}
