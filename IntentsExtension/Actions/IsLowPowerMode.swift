import Foundation

@MainActor
final class IsLowPowerModeIntentHandler: NSObject, IsLowPowerModeIntentHandling {
	func handle(intent: IsLowPowerModeIntent) async -> IsLowPowerModeIntentResponse {
		let response = IsLowPowerModeIntentResponse(code: .success, userActivity: nil)
		response.result = ProcessInfo.processInfo.isLowPowerModeEnabled as NSNumber
		return response
	}
}
