import Foundation
import Intents

@MainActor
final class SendFeedbackIntentHandler: NSObject, SendFeedbackIntentHandling {
	func resolveEmail(for intent: SendFeedbackIntent) async -> SendFeedbackEmailResolutionResult {
		guard
			let email = intent.email?.nilIfEmptyOrWhitespace?.trimmingCharacters(in: .whitespaces),
			email.contains("@")
		else {
			return .unsupported(forReason: .invalid)
		}

		return .success(with: email)
	}

	func resolveMessage(for intent: SendFeedbackIntent) async -> SendFeedbackMessageResolutionResult {
		guard let message = intent.message?.nilIfEmptyOrWhitespace else {
			return .unsupported(forReason: .empty)
		}

		return .success(with: message)
	}


	func handle(intent: SendFeedbackIntent) async -> SendFeedbackIntentResponse {
		guard
			let email = intent.email,
			let message = intent.message
		else {
			return .init(code: .failure, userActivity: nil)
		}

		do {
			try await SSApp.sendFeedback(email: email, message: message)
		} catch {
			return .failure(failure: error.presentableMessage)
		}

		let response = SendFeedbackIntentResponse(code: .success, userActivity: nil)
		response.result = "Thanks for your feedback 🙌"
		return response
	}
}
