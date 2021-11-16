import Foundation

@MainActor
final class IsConnectedToVPNIntentHandler: NSObject, IsConnectedToVPNIntentHandling {
	func handle(intent: IsConnectedToVPNIntent) async -> IsConnectedToVPNIntentResponse {
		let response = IsConnectedToVPNIntentResponse(code: .success, userActivity: nil)
		response.result = Device.isConnectedToVPN as NSNumber
		return response
	}
}
