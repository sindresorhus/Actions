import AppIntents
import SwiftUI

struct IsDeviceOrientation: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "IsDeviceOrientationIntent"

	static let title: LocalizedStringResource = "Is Device Orientation"

	static let description = IntentDescription(
"""
Returns whether the device is in the chosen orientation.

On macOS it always returns “false”.
""",
		categoryName: "Device"
	)

	@Parameter(title: "Orientation")
	var orientation: IsDeviceOrientationAppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Is the device in \(\.$orientation) orientation?")
	}

	private func check(_ uiDeviceOrientation: UIDeviceOrientation) -> Bool {
		switch orientation {
		case .portrait:
			return uiDeviceOrientation == .portrait
		case .portraitUpsideDown:
			return uiDeviceOrientation == .portraitUpsideDown
		case .landscapeLeft:
			return uiDeviceOrientation == .landscapeLeft
		case .landscapeRight:
			return uiDeviceOrientation == .landscapeRight
		case .faceUp:
			return uiDeviceOrientation == .faceUp
		case .faceDown:
			return uiDeviceOrientation == .faceDown
		case .anyPortrait:
			return uiDeviceOrientation.isPortrait
		case .anyLandscape:
			return uiDeviceOrientation.isLandscape
		case .faceUpOrDown:
			return uiDeviceOrientation.isFlat
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		#if canImport(UIKit)
		do {
			let result = check(try await UIDevice.current.orientationBetter)
			return .result(value: result)
		} catch {
			return .result(value: false)
		}
		#else
		return .result(value: false)
		#endif
	}
}

enum IsDeviceOrientationAppEnum: String, AppEnum {
	case portrait
	case portraitUpsideDown
	case landscapeLeft
	case landscapeRight
	case faceUp
	case faceDown
	case anyPortrait
	case anyLandscape
	case faceUpOrDown

	static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Is Device Orientation")

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.portrait: "Portrait",
		.portraitUpsideDown: "Portrait Upside Down",
		.landscapeLeft: "Landscape Left",
		.landscapeRight: "Landscape Right",
		.faceUp: "Face Up",
		.faceDown: "Face Down",
		.anyPortrait: "Any Portrait",
		.anyLandscape: "Any Landscape",
		.faceUpOrDown: "Face Up or Down"
	]
}
