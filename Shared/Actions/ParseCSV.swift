import AppIntents
import TabularData

struct ParseCSV: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "ParseCSVIntent"

	static let title: LocalizedStringResource = "Parse CSV"

	static let description = IntentDescription(
		"Parses CSV into a list of dictionaries.",
		categoryName: "Parse / Generate"
	)

	@Parameter(
		title: "CSV",
		description: "Accepts a file or text. Tap the parameter to select a file. Tap and hold to select a variable to some text.",
		supportedTypeIdentifiers: [
			"public.comma-separated-values-text",
			"public.tab-separated-values-text"
		]
	)
	var file: IntentFile

	@Parameter(title: "First Row Is Header", default: true)
	var hasHeader: Bool

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
//			Summary("Parse \(\.$file)") {
//				\.$delimiter
//				\.$hasHeader
//				\.$customDelimiter
//			}
//		} otherwise: {
//			Summary("Parse \(\.$file)") {
//				\.$hasHeader
//				\.$delimiter
//			}
//		}
		Switch(\.$delimiter) {
			Case(.custom) {
				Summary("Parse \(\.$file)") {
					\.$delimiter
					\.$hasHeader
					\.$customDelimiter
				}
			}
			DefaultCase {
				Summary("Parse \(\.$file)") {
					\.$hasHeader
					\.$delimiter
				}
			}
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		// TODO: Document what the auto-generated headers will look like: `Column 0`, etc.

		let finalDelimiter = try delimiter.character(customDelimiter: customDelimiter)

		let dataFrame = try DataFrame(
			csvData: file.data,
			options: .init(
				hasHeaderRow: hasHeader,
				// We intentionally do not parse booleans as `DataFrame` cannot handle parsing them from JSON in "GenerateCSV". (macOS 12.3)
				// https://github.com/feedback-assistant/reports/issues/299
//					trueEncodings: ["true", "TRUE", "True"],
//					falseEncodings: ["false", "FALSE", "False"],
				trueEncodings: [],
				falseEncodings: [],
				delimiter: finalDelimiter
			)
		)

		// TODO: We cannot return a JSON array as the Shortcuts app crashes. (macOS 12.2)
//			response.result = try JSONSerialization.data(
//				withJSONObject: dataFrame.toArray(),
//				options: .prettyPrinted
//			)
//				.toINFile(
//					contentType: .json,
//					filename: file.filenameWithoutExtension
//				)

		let result = try dataFrame.rows.indexed().map {
			try JSONSerialization.data(
				withJSONObject: $0.1.toDictionary(),
				options: .prettyPrinted
			)
				.toIntentFile(contentType: .json, filename: "Row \($0.0 + 1)")
		}

		return .result(value: result)
	}
}

enum CSVDelimiterAppEnum: String, AppEnum {
	case comma
	case tab
	case custom

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "CSV Delimiter"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.comma: "Comma",
		.tab: "Tab",
		.custom: "Custom"
	]
}

extension CSVDelimiterAppEnum {
	func character(customDelimiter: String?) throws -> Character {
		switch self {
		case .comma:
			return ","
		case .tab:
			return "\t"
		case .custom:
			guard
				let delimiter = customDelimiter,
				delimiter.count == 1,
				let character = delimiter.first
			else {
				throw "Invalid delimiter. The delimiter should be a single character.".toError
			}

			return character
		}
	}
}
