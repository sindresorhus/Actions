import CoreImage

@MainActor
final class ScanQRCodesInImageIntentHandler: NSObject, ScanQRCodesInImageIntentHandling {
	func handle(intent: ScanQRCodesInImageIntent) async -> ScanQRCodesInImageIntentResponse {
		let response = ScanQRCodesInImageIntentResponse(code: .success, userActivity: nil)

		guard let image = intent.image?.data else {
			return response
		}

		guard let ciImage = CIImage(data: image) else {
			return .failure(failure: "Invalid image.")
		}

		let multiple = intent.multiple as? Bool ?? false
		let messages = ciImage.readMessageForQRCodes()

		response.result = multiple ? messages : messages.first.map { [$0] }

		return response
	}
}
