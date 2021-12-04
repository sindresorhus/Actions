import SwiftUI

@MainActor
final class IsSilentModeOnIntentHandler: NSObject, IsSilentModeOnIntentHandling {
	func handle(intent: IsSilentModeOnIntent) async -> IsSilentModeOnIntentResponse {
		let response = IsSilentModeOnIntentResponse(code: .success, userActivity: nil)
		response.result = await Device.isSilentModeEnabled as NSNumber
		return response
	}
}
