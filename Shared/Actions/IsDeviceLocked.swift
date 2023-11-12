import AppIntents
import SwiftUI

struct IsDeviceLocked: AppIntent {
	static let title: LocalizedStringResource = "Is Device Locked"

	static let description = IntentDescription(
		"""
		Returns whether the device is currently locked.

		Limitations:
		- It takes about 10 seconds from when you lock the screen until the device is actually locked.
		- This will not work if you don't have any authentication (passcode, Face ID, or Touch ID) for the device.
		""",
		categoryName: "Device"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Is device locked? (PLEASE READ THE ACTION DESCRIPTION)")
	}

	@MainActor
	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: !XApplication.shared.isProtectedDataAvailable)
	}
}
