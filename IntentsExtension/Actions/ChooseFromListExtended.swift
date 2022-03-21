import Foundation

@MainActor
final class ChooseFromListExtendedIntentHandler: NSObject, ChooseFromListExtendedIntentHandling {
	func handle(intent: ChooseFromListExtendedIntent) async -> ChooseFromListExtendedIntentResponse {
		.init(code: .continueInApp, userActivity: ChooseFromListExtendedIntent.nsUserActivity)
	}
}
