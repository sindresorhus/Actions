import Foundation

@MainActor
final class GenerateUUIDIntentHandler: NSObject, GenerateUUIDIntentHandling {
	func handle(intent: GenerateUUIDIntent) async -> GenerateUUIDIntentResponse {
		let response = GenerateUUIDIntentResponse(code: .success, userActivity: nil)
		response.result = UUID().uuidString
		return response
	}
}
