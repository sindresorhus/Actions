import Foundation

@MainActor
final class RandomBooleanIntentHandler: NSObject, RandomBooleanIntentHandling {
	func handle(intent: RandomBooleanIntent) async -> RandomBooleanIntentResponse {
		let response = RandomBooleanIntentResponse(code: .success, userActivity: nil)
		response.result = Bool.random() as NSNumber
		return response
	}
}
