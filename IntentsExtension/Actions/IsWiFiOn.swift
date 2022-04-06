import Foundation

@MainActor
final class IsWiFiOnIntentHandler: NSObject, IsWiFiOnIntentHandling {
	func handle(intent: IsWiFiOnIntent) async -> IsWiFiOnIntentResponse {
		let response = IsWiFiOnIntentResponse(code: .success, userActivity: nil)
		response.result = Device.isWiFiOn as NSNumber
		return response
	}
}
