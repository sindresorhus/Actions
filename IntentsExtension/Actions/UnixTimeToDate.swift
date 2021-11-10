import SwiftUI

@MainActor
final class UnixTimeToDateIntentHandler: NSObject, UnixTimeToDateIntentHandling {
	func handle(intent: UnixTimeToDateIntent) async -> UnixTimeToDateIntentResponse {
		let response = UnixTimeToDateIntentResponse(code: .success, userActivity: nil)

		if let unixTime = intent.unixTime as? TimeInterval {
			response.result = Calendar.current.dateComponents(in: .current, from: Date(timeIntervalSince1970: unixTime))
		} else {
			response.result = Calendar.current.dateComponents(in: .current, from: .now)
		}

		return response
	}
}
