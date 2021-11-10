import Foundation

@MainActor
final class RemoveDuplicatesFromListIntentHandler: NSObject, RemoveDuplicatesFromListIntentHandling {
	func handle(intent: RemoveDuplicatesFromListIntent) async -> RemoveDuplicatesFromListIntentResponse {
		let response = RemoveDuplicatesFromListIntentResponse(code: .success, userActivity: nil)
		response.result = intent.list?.removingDuplicates(by: \.data)
		return response
	}
}
