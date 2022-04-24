import Foundation

@MainActor
final class GetQueryItemsFromURLAsDictionaryIntentHandler: NSObject, GetQueryItemsFromURLAsDictionaryIntentHandling {
	func handle(intent: GetQueryItemsFromURLAsDictionaryIntent) async -> GetQueryItemsFromURLAsDictionaryIntentResponse {
		let response = GetQueryItemsFromURLAsDictionaryIntentResponse(code: .success, userActivity: nil)

		do {
			response.result = try intent.url?.queryDictionary.toINFile()
		} catch {
			return .failure(failure: error.presentableMessage)
		}

		return response
	}
}
