import AppIntents
import SwiftUI

struct GetDeviceOrientation: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GetDeviceOrientationIntent"

	static let title: LocalizedStringResource = "Get Device Orientation"

	static let description = IntentDescription(
"""
Returns the orientation of the device.

For example, whether the device is portrait or facing down.

Possible values:
- unknown
- portrait
- portraitUpsideDown
- landscapeLeft
- landscapeRight
- faceUp
- faceDown

On macOS, it always returns “unknown”.
""",
		categoryName: "Device"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<DeviceOrientationAppEnum> {
		#if canImport(UIKit)
		do {
			return .result(value: .init(try await UIDevice.current.orientationBetter))
		} catch {
			return .result(value: .unknown)
		}
		#else
		.result(value: .unknown)
		#endif
	}
}

enum DeviceOrientationAppEnum: String, AppEnum {
	case unknown
	case portrait
	case portraitUpsideDown
	case landscapeLeft
	case landscapeRight
	case faceUp
	case faceDown

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Device Orientation"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.unknown: "unknown",
		.portrait: "portrait",
		.portraitUpsideDown: "portraitUpsideDown",
		.landscapeLeft: "landscapeLeft",
		.landscapeRight: "landscapeRight",
		.faceUp: "faceUp",
		.faceDown: "faceDown"
	]
}

#if canImport(UIKit)
@available(macOS, unavailable)
extension DeviceOrientationAppEnum {
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
#endif
