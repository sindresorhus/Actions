import Foundation

@MainActor
final class ShuffleListIntentHandler: NSObject, ShuffleListIntentHandling {
	func handle(intent: ShuffleListIntent) async -> ShuffleListIntentResponse {
		let response = ShuffleListIntentResponse(code: .success, userActivity: nil)
		response.result = intent.list?.shuffled()
		return response
	}
}
