import UIKit

@MainActor
final class IsDeviceOrientationIntentHandler: NSObject, IsDeviceOrientationIntentHandling {
	func handle(intent: IsDeviceOrientationIntent) async -> IsDeviceOrientationIntentResponse {
		let response = IsDeviceOrientationIntentResponse(code: .success, userActivity: nil)

		func check(_ orientation: UIDeviceOrientation) -> Bool {
			switch intent.orientation {
			case .unknown:
				return orientation == .unknown
			case .portrait:
				return orientation == .portrait
			case .portraitUpsideDown:
				return orientation == .portraitUpsideDown
			case .landscapeLeft:
				return orientation == .landscapeLeft
			case .landscapeRight:
				return orientation == .landscapeRight
			case .faceUp:
				return orientation == .faceUp
			case .faceDown:
				return orientation == .faceDown
			case .anyPortrait:
				return orientation.isPortrait
			case .anyLandscape:
				return orientation.isLandscape
			case .faceUpOrDown:
				return orientation.isFlat
			}
		}

		do {
			let orientation = try await UIDevice.current.orientationBetter
			response.result = check(orientation) as NSNumber
		} catch {
			return .failure(failure: error.presentableMessage)
		}

		return response
	}
}
