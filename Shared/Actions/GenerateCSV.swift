import AppIntents
import TabularData

struct GenerateCSV: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GenerateCSVIntent"

	static let title: LocalizedStringResource = "Generate CSV"

	static let description = IntentDescription(
"""
Generates a CSV file from a list of dictionaries.

The keys of the dictionaries are the CSV headers.

The dictionaries must have the same shape.
""",
		categoryName: "Parse / Generate"
	)

	@Parameter(title: "Dictionaries", supportedTypeIdentifiers: ["public.json"])
	var dictionaries: [IntentFile]

	@Parameter(
		title: "Keys",
		description: "By default, all keys are included. Here, you can specify which keys to include and in what order.",
		default: []
	)
	var keys: [String]

	@Parameter(title: "Delimiter", default: .comma)
	var delimiter: CSVDelimiterAppEnum

	@Parameter(
		title: "Custom Delimiter",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var customDelimiter: String?

	static var parameterSummary: some ParameterSummary {
		// This fails on Xcode 14.3
//		When(\.$delimiter, .equalTo, .custom) {
//			Summary("Generate CSV from \(\.$dictionaries)") {
//				\.$delimiter
//				\.$customDelimiter
//				\.$keys
//			}
//		} otherwise: {
//			Summary("Generate CSV from \(\.$dictionaries)") {
//				\.$delimiter
//				\.$keys
//			}
//		}
		Switch(\.$delimiter) {
			Case(.custom) {
				Summary("Generate CSV from \(\.$dictionaries)") {
					\.$delimiter
					\.$customDelimiter
					\.$keys
				}
			}
			DefaultCase {
				Summary("Generate CSV from \(\.$dictionaries)") {
					\.$delimiter
					\.$keys
				}
			}
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		let json = dictionaries.compactMap(\.data.toString).joined(separator: ",")
		var dataFrame = try DataFrame(jsonData: "[\(json)]".toData)

		// Shortcuts can leave keys empty sometimes and `.selecting()` throws an excepting if trying to use those.
		let keys = keys.filter { !$0.isEmptyOrWhitespace }

		if !keys.isEmpty, !dataFrame.isEmpty {
			let columnNames = Set(dataFrame.columns.map(\.name))

			// We have to guard the given key too as `.selecting()` throws an exception if the key does not exist.
			for key in keys where !columnNames.contains(key) {
				throw "The key “\(key)” does not exist in the given dictionaries.".toError
			}

			dataFrame = dataFrame.selecting(columnNames: keys)
		}

		let finalDelimiter = try delimiter.character(customDelimiter: customDelimiter)

		let result = try dataFrame
			.csvRepresentation(options: .init(delimiter: finalDelimiter))
			.toIntentFile(contentType: .commaSeparatedText, filename: UUID().uuidString) // TODO: The UUID works around a bug in iOS 16.1 where it doesn't generate unique names.

		return .result(value: result)
	}
}
