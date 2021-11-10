import Foundation

@MainActor
final class GetUniformTypeIdentifierIntentHandler: NSObject, GetUniformTypeIdentifierIntentHandling {
	func handle(intent: GetUniformTypeIdentifierIntent) async -> GetUniformTypeIdentifierIntentResponse {
		let response = GetUniformTypeIdentifierIntentResponse(code: .success, userActivity: nil)
		response.result = intent.file?.typeIdentifier
		return response
	}
}
