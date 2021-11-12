import Foundation

@MainActor
final class GetEmojisIntentHandler: NSObject, GetEmojisIntentHandling {
	func handle(intent: GetEmojisIntent) async -> GetEmojisIntentResponse {
		let response = GetEmojisIntentResponse(code: .success, userActivity: nil)
		response.result = intent.text?.emojis.map(String.init)
		return response
	}
}
