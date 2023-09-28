import AppIntents

struct TransformLists: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "TransformListsIntent"

	static let title: LocalizedStringResource = "Transform Lists"

	static let description = IntentDescription(
"""
Transforms items of two lists.

Note that duplicates will be removed from the result.

Tap and hold a list parameter to select a variable to a list. Don't quick tap it.

Note: If you get the error “The operation failed because Shortcuts couldn't convert from Text to NSString.”, just change the preview to show a list view instead. This is a bug in the Shortcuts app.

Known limitation: It does not work with iTunes Media items.
""",
		categoryName: "List"
	)

	@Parameter(title: "Operation", default: .intersection)
	var type: OperationTypeAppEnum

	@Parameter(title: "List 1", supportedTypeIdentifiers: ["public.item"])
	var list1: [IntentFile]

	@Parameter(title: "List 2", supportedTypeIdentifiers: ["public.item"])
	var list2: [IntentFile]

	static var parameterSummary: some ParameterSummary {
		Switch(\.$type) {
			Case(.subtraction) {
				Summary("Get items from \(\.$list1) that are not in \(\.$list2)") {
					\.$type
				}
			}
			Case(.intersection) {
				Summary("Get items that are in both \(\.$list1) and \(\.$list2)") {
					\.$type
				}
			}
			Case(.symmetricDifference) {
				Summary("Get items that are not in both \(\.$list1) and \(\.$list2)") {
					\.$type
				}
			}
			DefaultCase {
				Summary()
			}
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		let set1 = Set(list1.map(\.data))
		let set2 = Set(list2.map(\.data))

		let set3: Set<Data> = switch type {
		case .subtraction:
			set1.subtracting(set2)
		case .intersection:
			set1.intersection(set2)
		case .symmetricDifference:
			set1.symmetricDifference(set2)
		}

		let inputFiles = list1 + list2

		let result = set3.map { data in
			inputFiles.first { $0.data == data }
		}
			.compact()

		return .result(value: result)
	}
}

enum OperationTypeAppEnum: String, AppEnum {
	case subtraction
	case intersection
	case symmetricDifference

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Operation Type"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.subtraction: "Subtraction",
		.intersection: "Intersection",
		.symmetricDifference: "Symmetric difference"
	]
}
