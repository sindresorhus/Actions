import AppIntents
import SwiftUI

@available(iOS, unavailable)
struct GetModifierKeyState: AppIntent {
	static let title: LocalizedStringResource = "Get Modifier Key State"

	static let description = IntentDescription(
		"""
		Returns which modifier keys are currently pressed.

		This can be useful to have alternative behavior when, for example, the user presses the Option key.

		Supported modifier keys:
		- Shift
		- Control
		- Option
		- Command
		- Function
		""",
		categoryName: "Device",
		searchKeywords: [
			"keyboard",
			"shortcut",
			"hotkey"
		],
		resultValueName: "Modifier Key State"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Get state of modifier keys")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<ModifierKeyState_AppEntity> {
		.result(value: .init())
	}
}

// Note: It should be possible to support iOS, but I don't have a physical keyboard to test with (doesn't work in the simulator), so I'm leaving it out for now.
// `GCKeyboard.coalesced?.keyboardInput?.button(forKeyCode: .leftShift)?.isPressed`s

struct ModifierKeyState_AppEntity: TransientAppEntity {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Modifier Key State"

	@Property(title: "Shift")
	var shift: Bool

	@Property(title: "Control")
	var control: Bool

	@Property(title: "Option")
	var option: Bool

	@Property(title: "Command")
	var command: Bool

	@Property(title: "Function (Fn)")
	var function: Bool

	var displayRepresentation: DisplayRepresentation {
		.init(
			title: "Modifier keys",
			subtitle:
				"""
				Shift: \("\(shift)")
				Control: \("\(control)")
				Option: \("\(option)")
				Command: \("\(command)")
				Function: \("\(function)")
				"""
		)
	}

	init() {
		#if os(macOS)
		let flags = NSEvent.modifierFlags

		// I am intentionally excluding `.capsLock` because it's confusing since it works differently. It doesn't mean "pressed", it means "on".

		self.shift = flags.contains(.shift)
		self.control = flags.contains(.control)
		self.option = flags.contains(.option)
		self.command = flags.contains(.command)
		self.function = flags.contains(.function)
		#else
		self.shift = false
		self.control = false
		self.option = false
		self.command = false
		self.function = false
		#endif
	}
}
