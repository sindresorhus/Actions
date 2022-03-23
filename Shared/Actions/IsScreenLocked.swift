import Foundation

@MainActor
final class IsScreenLockedIntentHandler: NSObject, IsScreenLockedIntentHandling {
	func handle(intent: IsScreenLockedIntent) async -> IsScreenLockedIntentResponse {
		let response = IsScreenLockedIntentResponse(code: .success, userActivity: nil)
		response.result = Device.isScreenLocked as NSNumber
		return response
	}
}
