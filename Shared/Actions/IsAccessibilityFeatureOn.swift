import AppIntents
import SwiftUI

// Note: This is intentionally not in the app extension because when it's in the extension it return outdated values. On macOS, it get stuck forever on the previous value, and on iOS it gets stuck for one time. (iOS 17.0)

struct IsAccessibilityFeatureOn: AppIntent {
	static let title: LocalizedStringResource = "Is Accessibility Feature On"

	static let description = IntentDescription(
"""
Returns whether a certain accessibility feature is enabled.

NOTE: The “Assistive Touch” check only works when “Guided Access” is enabled.

On macOS, only the following are available. The rest always return false.
- Reduce Motion
- Reduce Transparency
- Invert Colors
- Increase Contrast
- Differentiate without Color
- VoiceOver
- Switch Control
""",
		categoryName: "Device",
		searchKeywords: [
			"accessibility",
			"gray",
			"grey",
			"grayscale",
			"greyscale",
			"reduce",
			"voiceover"
		]
	)

	@Parameter(title: "Feature")
	var feature: AccessibilityFeature_AppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Is the \(\.$feature) accessibility feature on?")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		let result = switch feature {
		case .assistiveTouch:
			XAccessibility.isAssistiveTouchRunning
		case .boldText:
			XAccessibility.isBoldTextEnabled
		case .closedCaptioning:
			XAccessibility.isClosedCaptioningEnabled
		case .increaseContrast:
			XAccessibility.isIncreaseContrastEnabled
		case .grayscale:
			XAccessibility.isGrayscaleEnabled
		case .guidedAccess:
			XAccessibility.isGuidedAccessEnabled
		case .invertColors:
			XAccessibility.isInvertColorsEnabled
		case .monoAudio:
			XAccessibility.isMonoAudioEnabled
		case .onOffSwitchLabels:
			XAccessibility.isOnOffSwitchLabelsEnabled
		case .reduceMotion:
			XAccessibility.isReduceMotionEnabled
		case .reduceTransparency:
			XAccessibility.isReduceTransparencyEnabled
		case .shakeToUndo:
			XAccessibility.isShakeToUndoEnabled
		case .speakScreen:
			XAccessibility.isSpeakScreenEnabled
		case .speakSelection:
			XAccessibility.isSpeakSelectionEnabled
		case .switchControlRunning:
			XAccessibility.isSwitchControlRunning
		case .videoAutoplay:
			XAccessibility.isVideoAutoplayEnabled
		case .voiceOverRunning:
			XAccessibility.isVoiceOverRunning
		case .differentiateWithoutColor:
			XAccessibility.shouldDifferentiateWithoutColor
		case .buttonShapes:
			XAccessibility.buttonShapesEnabled
		case .prefersCrossFadeTransitions:
			XAccessibility.prefersCrossFadeTransitions
		}

		return .result(value: result)
	}
}

enum AccessibilityFeature_AppEnum: String, AppEnum {
	case assistiveTouch
	case boldText
	case closedCaptioning
	case increaseContrast
	case grayscale
	case guidedAccess
	case invertColors
	case monoAudio
	case onOffSwitchLabels
	case reduceMotion
	case reduceTransparency
	case shakeToUndo
	case speakScreen
	case speakSelection
	case switchControlRunning
	case videoAutoplay
	case voiceOverRunning
	case differentiateWithoutColor
	case buttonShapes
	case prefersCrossFadeTransitions

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Accessibility Feature"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.assistiveTouch: "Assistive Touch",
		.boldText: "Bold Text",
		.closedCaptioning: "Closed Captioning",
		.increaseContrast: "Increase Contrast",
		.grayscale: "Grayscale",
		.guidedAccess: "Guided Access",
		.invertColors: "Invert Colors",
		.monoAudio: "Mono Audio",
		.onOffSwitchLabels: "On/Off Switch Labels",
		.reduceMotion: "Reduce Motion",
		.reduceTransparency: "Reduce Transparency",
		.shakeToUndo: "Shake to Undo",
		.speakScreen: "Speak Screen",
		.speakSelection: "Speak Selection",
		.switchControlRunning: "Switch Control",
		.videoAutoplay: "Video Autoplay",
		.voiceOverRunning: "VoiceOver",
		.differentiateWithoutColor: "Differentiate without Color",
		.buttonShapes: "Button Shapes",
		.prefersCrossFadeTransitions: "Prefer Cross-Fade Transitions"
	]
}
