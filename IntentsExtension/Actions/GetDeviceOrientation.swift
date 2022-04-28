import UIKit

extension DeviceOrientation_ {
	fileprivate init(_ uiDeviceOrientation: UIDeviceOrientation) {
		switch uiDeviceOrientation {
		case .unknown:
			self = .unknown
		case .portrait:
			self = .portrait
		case .portraitUpsideDown:
			self = .portraitUpsideDown
		case .landscapeLeft:
			self = .landscapeLeft
		case .landscapeRight:
			self = .landscapeRight
		case .faceUp:
			self = .faceUp
		case .faceDown:
			self = .faceDown
		@unknown default:
			assertionFailure()
			self = .unknown
		}
	}
}

@MainActor
final class GetDeviceOrientationIntentHandler: NSObject, GetDeviceOrientationIntentHandling {
	func handle(intent: GetDeviceOrientationIntent) async -> GetDeviceOrientationIntentResponse {
		let response = GetDeviceOrientationIntentResponse(code: .success, userActivity: nil)

		do {
			response.result = .init(try await UIDevice.current.orientationBetter)
		} catch {
			return .failure(failure: error.presentableMessage)
		}

		return response
	}
}
