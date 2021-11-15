import Foundation

@MainActor
final class IsDarkModeIntentHandler: NSObject, IsDarkModeIntentHandling {
	func handle(intent: IsDarkModeIntent) async -> IsDarkModeIntentResponse {
		let response = IsDarkModeIntentResponse(code: .success, userActivity: nil)
		response.result = SSApp.isDarkMode as NSNumber
		return response
	}
}
