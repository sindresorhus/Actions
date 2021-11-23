import Foundation

@MainActor
final class RemoveNonPrintableCharactersIntentHandler: NSObject, RemoveNonPrintableCharactersIntentHandling {
	func handle(intent: RemoveNonPrintableCharactersIntent) async -> RemoveNonPrintableCharactersIntentResponse {
		let response = RemoveNonPrintableCharactersIntentResponse(code: .success, userActivity: nil)
		response.result = intent.text?.removingCharactersWithoutDisplayWidth()
		return response
	}
}
