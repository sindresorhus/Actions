import Foundation

@MainActor
final class PrettyPrintDictionariesIntentHandler: NSObject, PrettyPrintDictionariesIntentHandling {
	func handle(intent: PrettyPrintDictionariesIntent) async -> PrettyPrintDictionariesIntentResponse {
		let response = PrettyPrintDictionariesIntentResponse(code: .success, userActivity: nil)

		guard let dictionaries = intent.dictionary?.nilIfEmpty else {
			return response
		}

		do {
			response.result = try dictionaries.map { try $0.prettyFormatJSON() }
		} catch {
			return .failure(failure: error.presentableMessage)
		}

		return response
	}
}
