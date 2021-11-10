import Foundation

@MainActor
final class ReverseListIntentHandler: NSObject, ReverseListIntentHandling {
	func handle(intent: ReverseListIntent) async -> ReverseListIntentResponse {
		let response = ReverseListIntentResponse(code: .success, userActivity: nil)
		response.result = intent.list?.reversed()
		return response
	}
}
