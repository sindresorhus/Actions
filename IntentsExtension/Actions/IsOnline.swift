import SwiftUI

@MainActor
final class IsOnlineIntentHandler: NSObject, IsOnlineIntentHandling {
	func handle(intent: IsOnlineIntent) async -> IsOnlineIntentResponse {
		let response = IsOnlineIntentResponse(code: .success, userActivity: nil)
		response.result = Reachability.isOnlineExtensive() as NSNumber
		return response
	}
}
