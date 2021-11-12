import Foundation

@MainActor
final class TruncateListIntentHandler: NSObject, TruncateListIntentHandling {
	func handle(intent: TruncateListIntent) async -> TruncateListIntentResponse {
		let response = TruncateListIntentResponse(code: .success, userActivity: nil)

		guard let list = intent.list else {
			return response
		}

		guard let limit = intent.limit as? Int else {
			response.result = list
			return response
		}

		response.result = Array(list.prefix(limit))

		return response
	}
}
