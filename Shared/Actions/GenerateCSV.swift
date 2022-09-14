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

	@Parameter(title: "Dictionaries", supportedTypeIdentifiers: ["public.data"])
	var dictionaries: [IntentFile]

	@Parameter(title: "Delimiter", default: .comma)
	var delimiter: CSVDelimiterAppEnum

	@Parameter(
		title: "Custom Delimiter",
		inputOptions: .init(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var customDelimiter: String?

	static var parameterSummary: some ParameterSummary {
		When(\.$delimiter, .equalTo, .custom) {
			Summary("Generate CSV from \(\.$dictionaries)") {
				\.$delimiter
				\.$customDelimiter
			}
		} otherwise: {
			Summary {
				\.$dictionaries
				\.$delimiter
			}
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		let json = dictionaries.compactMap { $0.data.toString }.joined(separator: ",")
		let dataFrame = try DataFrame(jsonData: "[\(json)]".toData)
		let finalDelimiter = try delimiter.character(customDelimiter: customDelimiter)

		let result = try dataFrame
			.csvRepresentation(options: .init(delimiter: finalDelimiter))
			.toIntentFile(contentType: .commaSeparatedText)

		return .result(value: result)
	}
}
