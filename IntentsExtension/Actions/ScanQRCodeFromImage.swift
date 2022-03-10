import CoreImage
import Foundation
import Intents

@MainActor
final class ScanQRCodeFromImageIntentHandler: NSObject, ScanQRCodeFromImageIntentHandling {
	func handle(intent: ScanQRCodeFromImageIntent) async -> ScanQRCodeFromImageIntentResponse {
		guard let image = intent.image?.data else {
			return .failure(failure: "Failed to obtain an image input.")
		}

		guard let detector = CIDetector(ofType: CIDetectorTypeQRCode,
		                                context: nil,
		                                options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
			let ciImage = CIImage(data: image) else { return .failure(failure: "Failed to initialize QR Code scanner.") }

		let response = ScanQRCodeFromImageIntentResponse(code: .success, userActivity: nil)

		guard let features = detector.features(in: ciImage) as? [CIQRCodeFeature],
		      let message = features.first?.messageString
		else {
			response.result = nil
			return response
		}

		response.result = message
		return response
	}
}
