import Foundation

@MainActor
final class RemoveDuplicateLinesIntentHandler: NSObject, RemoveDuplicateLinesIntentHandling {
	func handle(intent: RemoveDuplicateLinesIntent) async -> RemoveDuplicateLinesIntentResponse {
		let caseInsensitive = intent.caseInsensitive as? Bool ?? false
		let response = RemoveDuplicateLinesIntentResponse(code: .success, userActivity: nil)
		response.result = intent.text?.localizedRemovingDuplicateLines(caseInsensitive: caseInsensitive)
		return response
	}
}
