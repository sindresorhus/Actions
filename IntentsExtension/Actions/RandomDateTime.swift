import Foundation

@MainActor
final class RandomDateTimeIntentHandler: NSObject, RandomDateTimeIntentHandling {
	func handle(intent: RandomDateTimeIntent) async -> RandomDateTimeIntentResponse {
		guard
			let start = intent.start,
			let end = intent.end
		else {
			return .init(code: .failure, userActivity: nil)
		}

		let response = RandomDateTimeIntentResponse(code: .success, userActivity: nil)
		response.result = DateComponents.random(start: start, end: end, for: .current)
		return response
	}
}
