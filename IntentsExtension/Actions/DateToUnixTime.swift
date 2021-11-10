import SwiftUI

@MainActor
final class DateToUnixTimeIntentHandler: NSObject, DateToUnixTimeIntentHandling {
	func handle(intent: DateToUnixTimeIntent) async -> DateToUnixTimeIntentResponse {
		let response = DateToUnixTimeIntentResponse(code: .success, userActivity: nil)
		// We convert to Int to get a whole number.
		response.result = Int((intent.date?.date ?? .now).timeIntervalSince1970) as NSNumber?
		return response
	}
}
