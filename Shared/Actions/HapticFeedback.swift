import AppIntents

@available(macOS, unavailable)
struct HapticFeedbackIntent: AppIntent {
	static let title: LocalizedStringResource = "Generate Haptic Feedback (iOS-only)"

	static let description = IntentDescription(
		"""
		Generate haptic feedback (vibrate).

		The action has to momentarily open the main app as haptic feedback can only be generated from the app.

		Not supported on iPad. Requires iPhone 8 or later.

		On macOS, it does nothing.
		""",
		categoryName: "Device"
	)

	static let openAppWhenRun = true

	@Parameter(title: "Type")
	var type: HapticFeedbackTypeAppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Generate \(\.$type) haptic feedback (PLEASE READ THE ACTION DESCRIPTION)")
	}

	@MainActor
	func perform() async throws -> some IntentResult {
		#if canImport(UIKit)
		try? await Task.sleep(for: .seconds(0.5)) // This seems to only be required in release builds.
		Device.hapticFeedback(type.toNative)
		try? await Task.sleep(for: .seconds(0.5))
		ShortcutsApp.open()
		#endif

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

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Haptic Feedback Type"

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
			.success
		case .warning:
			.warning
		case .error:
			.error
		case .selection:
			.selection
		case .soft:
			.soft
		case .light:
			.light
		case .medium:
			.medium
		case .heavy:
			.heavy
		case .rigid:
			.rigid
		}
	}
}
#endif
