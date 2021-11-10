import Foundation

@MainActor
final class RemoveEmptyLinesIntentHandler: NSObject, RemoveEmptyLinesIntentHandling {
	func handle(intent: RemoveEmptyLinesIntent) async -> RemoveEmptyLinesIntentResponse {
		let response = RemoveEmptyLinesIntentResponse(code: .success, userActivity: nil)
		response.result = intent.text?.removingEmptyLines()
		return response
	}
}
