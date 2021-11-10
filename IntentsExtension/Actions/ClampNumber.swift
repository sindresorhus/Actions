import Foundation

@MainActor
final class ClampNumberIntentHandler: NSObject, ClampNumberIntentHandling {
	func handle(intent: ClampNumberIntent) async -> ClampNumberIntentResponse {
		guard
			let number = intent.number as? Double,
			let minimum = intent.minimum as? Double,
			let maximum = intent.maximum as? Double
		else {
			return .init(code: .failure, userActivity: nil)
		}

		let response = ClampNumberIntentResponse(code: .success, userActivity: nil)
		response.result = number.clamped(to: .fromGraceful(minimum, maximum)) as NSNumber
		return response
	}
}
