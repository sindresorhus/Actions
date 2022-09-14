import AppIntents

struct HapticFeedback: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "HapticFeedbackIntent"

	static let title: LocalizedStringResource = "Generate Haptic Feedback (iOS-only)"

	static let description = IntentDescription(
"""
Generate haptic feedback (vibrate).

The action has to momentarily open the main app as haptic feedback can only be generated from the app.

Not supported on i​Pad. Requires i​Phone 8 or later.

On macOS, it does nothing.
""",
	categoryName: "Device"
	)

	static let openAppWhenRun = true

	@Parameter(title: "Type")
	var type: HapticFeedbackTypeAppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Generate \(\.$type) haptic feedback")
	}

	func perform() async throws -> some IntentResult {
		Device.hapticFeedback(type.toNative)
		try? await Task.sleep(seconds: 1)
		await ShortcutsApp.open()
		return .result()
	}
}

enum HapticFeedbackTypeAppEnum: String, AppEnum {
	case success
	case warning
	case error
	case selection
	case soft
	case light
	case medium
	case heavy
	case rigid

	static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Haptic Feedback Type")

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.success: "success",
		.warning: "warning",
		.error: "error",
		.selection: "selection",
		.soft: "soft",
		.light: "light",
		.medium: "medium",
		.heavy: "heavy",
		.rigid: "rigid"
	]
}

#if canImport(UIKit)
extension HapticFeedbackTypeAppEnum {
	var toNative: Device.HapticFeedback {
		switch self {
		case .success:
			return .success
		case .warning:
			return .warning
		case .error:
			return .error
		case .selection:
			return .selection
		case .soft:
			return .soft
		case .light:
			return .light
		case .medium:
			return .medium
		case .heavy:
			return .heavy
		case .rigid:
			return .rigid
		}
	}
}
#endif
