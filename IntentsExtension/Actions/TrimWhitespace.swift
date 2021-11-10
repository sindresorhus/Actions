import Foundation

@MainActor
final class TrimWhitespaceIntentHandler: NSObject, TrimWhitespaceIntentHandling {
	func handle(intent: TrimWhitespaceIntent) async -> TrimWhitespaceIntentResponse {
		let response = TrimWhitespaceIntentResponse(code: .success, userActivity: nil)
		response.result = intent.text?.trimmingCharacters(in: .whitespacesAndNewlines)
		return response
	}
}
