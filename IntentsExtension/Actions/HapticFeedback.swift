import Foundation

@MainActor
final class HapticFeedbackIntentHandler: NSObject, HapticFeedbackIntentHandling {
	func handle(intent: HapticFeedbackIntent) async -> HapticFeedbackIntentResponse {
		.init(code: .continueInApp, userActivity: nil)
	}
}
