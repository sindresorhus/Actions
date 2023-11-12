import AppIntents
import SwiftUI

struct IsDeviceOrientationIntent: AppIntent {
	static let title: LocalizedStringResource = "Is Device Orientation"

	static let description = IntentDescription(
		"""
		Returns whether the device is in the chosen orientation.

		On macOS, it always returns false.
		""",
		categoryName: "Device"
	)

	@Parameter(title: "Orientation")
	var orientation: IsDeviceOrientationAppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Is the device in \(\.$orientation) orientation?")
	}

	#if canImport(UIKit)
	private func check(_ uiDeviceOrientation: UIDeviceOrientation) -> Bool {
		switch orientation {
		case .portrait:
			uiDeviceOrientation == .portrait
		case .portraitUpsideDown:
			uiDeviceOrientation == .portraitUpsideDown
		case .landscapeLeft:
			uiDeviceOrientation == .landscapeLeft
		case .landscapeRight:
			uiDeviceOrientation == .landscapeRight
		case .faceUp:
			uiDeviceOrientation == .faceUp
		case .faceDown:
			uiDeviceOrientation == .faceDown
		case .anyPortrait:
			uiDeviceOrientation.isPortrait
		case .anyLandscape:
			uiDeviceOrientation.isLandscape
		case .faceUpOrDown:
			uiDeviceOrientation.isFlat
		}
	}
	#endif

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		#if canImport(UIKit)
		do {
			let result = check(try await Device.orientation)
			return .result(value: result)
		} catch {
			return .result(value: false)
		}
		#else
		.result(value: false)
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

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Is Device Orientation"

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
