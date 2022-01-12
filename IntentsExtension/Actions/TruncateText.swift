import Foundation

@MainActor
final class TruncateTextIntentHandler: NSObject, TruncateTextIntentHandling {
	func handle(intent: TruncateTextIntent) async -> TruncateTextIntentResponse {
		guard let maximumLength = intent.maximumLength as? Int else {
			return .init(code: .success, userActivity: nil)
		}

		let response = TruncateTextIntentResponse(code: .success, userActivity: nil)

		response.result = intent.text?.truncating(
			to: maximumLength,
			truncationIndicator: intent.truncationIndicator ?? "…"
		)

		return response
	}
}
