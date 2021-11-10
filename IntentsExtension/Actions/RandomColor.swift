import Foundation

@MainActor
final class RandomColorIntentHandler: NSObject, RandomColorIntentHandling {
	func handle(intent: RandomColorIntent) async -> RandomColorIntentResponse {
		let response = RandomColorIntentResponse(code: .success, userActivity: nil)
		response.result = Color_(.randomAvoidingBlackAndWhite())
		return response
	}
}
