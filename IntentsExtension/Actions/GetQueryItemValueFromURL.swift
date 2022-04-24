import Foundation

@MainActor
final class GetQueryItemValueFromURLIntentHandler: NSObject, GetQueryItemValueFromURLIntentHandling {
	func handle(intent: GetQueryItemValueFromURLIntent) async -> GetQueryItemValueFromURLIntentResponse {
		let response = GetQueryItemValueFromURLIntentResponse(code: .success, userActivity: nil)

		guard
			let url = intent.url,
			let queryItemName = intent.queryItemName
		else {
			return response
		}

		response.result = url.queryItemValue(forName: queryItemName)

		return response
	}
}
