import Foundation

@MainActor
final class ShuffleListIntentHandler: NSObject, ShuffleListIntentHandling {
	func handle(intent: ShuffleListIntent) async -> ShuffleListIntentResponse {
		let response = ShuffleListIntentResponse(code: .success, userActivity: nil)

		guard var list = intent.list?.shuffled() else {
			return response
		}

		if
			intent.shouldLimit?.boolValue == true,
			let limit = intent.limit as? Int
		{
			list = Array(list.prefix(limit))
		}

		response.result = list
		return response
	}
}
