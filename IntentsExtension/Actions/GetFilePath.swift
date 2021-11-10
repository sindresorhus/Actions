import Foundation

@MainActor
final class GetFilePathIntentHandler: NSObject, GetFilePathIntentHandling {
	func handle(intent: GetFilePathIntent) async -> GetFilePathIntentResponse {
		guard let url = intent.file?.fileURL else {
			return .init(code: .failure, userActivity: nil)
		}

		let response = GetFilePathIntentResponse(code: .success, userActivity: nil)

		switch intent.type {
		case .unknown, .path:
			response.result = url.path
		case .url:
			response.result = url.absoluteString
		case .tildePath:
			response.result = url.tildePath
		}

		return response
	}
}
