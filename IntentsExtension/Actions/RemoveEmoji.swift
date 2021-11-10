import Foundation

@MainActor
final class RemoveEmojiIntentHandler: NSObject, RemoveEmojiIntentHandling {
	func handle(intent: RemoveEmojiIntent) async -> RemoveEmojiIntentResponse {
		let response = RemoveEmojiIntentResponse(code: .success, userActivity: nil)
		response.result = intent.text?.removingEmoji()
		return response
	}
}
