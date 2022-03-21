import Foundation
import TabularData

@MainActor
final class GenerateCSVIntentHandler: NSObject, GenerateCSVIntentHandling {
	func handle(intent: GenerateCSVIntent) async -> GenerateCSVIntentResponse {
		let response = GenerateCSVIntentResponse(code: .success, userActivity: nil)

		guard let dictionaries = intent.dictionaries else {
			return response
		}

		do {
			let delimiter: Character = try {
				switch intent.delimiter {
				case .unknown, .comma:
					return ","
				case .tab:
					return "\t"
				case .custom:
					guard
						let delimiter = intent.customDelimiter,
						delimiter.count == 1,
						let character = delimiter.first
					else {
						throw NSError.appError("Invalid delimiter. The delimiter should be a single character.")
					}

					return character
				}
			}()

			let json = dictionaries.compactMap { $0.data.toString }.joined(separator: ",")
			let dataFrame = try DataFrame(jsonData: "[\(json)]".toData)

			response.result = try dataFrame
				.csvRepresentation(options: .init(delimiter: delimiter))
				.toINFile(contentType: .commaSeparatedText)
		} catch {
			return .failure(failure: error.presentableMessage)
		}

		return response
	}
}
