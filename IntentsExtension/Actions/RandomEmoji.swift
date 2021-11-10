import Foundation

@MainActor
final class RandomEmojiIntentHandler: NSObject, RandomEmojiIntentHandling {
	func handle(intent: RandomEmojiIntent) async -> RandomEmojiIntentResponse {
		let response = RandomEmojiIntentResponse(code: .success, userActivity: nil)
		response.result = String.randomEmoticon()
		return response
	}
}
