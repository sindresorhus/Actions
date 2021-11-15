import Foundation

@MainActor
final class WriteTextIntentHandler: NSObject, WriteTextIntentHandling {
	func handle(intent: WriteTextIntent) async -> WriteTextIntentResponse {
		.init(code: .continueInApp, userActivity: WriteTextIntent.nsUserActivity)
	}
}
