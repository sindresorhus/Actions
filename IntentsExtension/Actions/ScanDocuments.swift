import Foundation

@MainActor
final class ScanDocumentsIntentHandler: NSObject, ScanDocumentsIntentHandling {
	func handle(intent: ScanDocumentsIntent) async -> ScanDocumentsIntentResponse {
		.init(code: .continueInApp, userActivity: ScanDocumentsIntent.nsUserActivity)
	}
}
