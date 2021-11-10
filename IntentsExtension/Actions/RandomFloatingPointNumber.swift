import Foundation

@MainActor
final class RandomFloatingPointNumberIntentHandler: NSObject, RandomFloatingPointNumberIntentHandling {
	func handle(intent: RandomFloatingPointNumberIntent) async -> RandomFloatingPointNumberIntentResponse {
		guard
			let minimum = intent.minimum as? Double,
			let maximum = intent.maximum as? Double
		else {
			return .init(code: .failure, userActivity: nil)
		}

		let response = RandomFloatingPointNumberIntentResponse(code: .success, userActivity: nil)
		response.result = Double.random(in: .fromGraceful(minimum, maximum)) as NSNumber
		return response
	}
}
