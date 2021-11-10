import SwiftUI

@MainActor
final class SampleColorIntentHandler: NSObject, SampleColorIntentHandling {
	func handle(intent: SampleColorIntent) async -> SampleColorIntentResponse {
		guard let color = await NSColorSampler().sample() else {
			return .init(code: .failure, userActivity: nil)
		}

		let response = SampleColorIntentResponse(code: .success, userActivity: nil)
		response.result = Color_(color)
		return response
	}
}
