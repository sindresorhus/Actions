import Foundation

@MainActor
final class IsReachableIntentHandler: NSObject, IsReachableIntentHandling {
	func handle(intent: IsReachableIntent) async -> IsReachableIntentResponse {
		let response = IsReachableIntentResponse(code: .success, userActivity: nil)

		guard let host = intent.host else {
			return response
		}

		guard let url = URL(humanString: host) else {
			return .failure(failure: "Invalid host")
		}

		let timeout = intent.timeout as? Double ?? 10

		response.result = await URLSession.shared.isReachable(url, timeout: timeout) as NSNumber

		return response
	}
}
