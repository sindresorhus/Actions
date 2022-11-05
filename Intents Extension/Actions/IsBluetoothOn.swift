import AppIntents

struct IsBluetoothOn: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "IsBluetoothOnIntent"

	static let title: LocalizedStringResource = "Is Bluetooth On"

	static let description = IntentDescription(
"""
Returns whether Bluetooth is on or off.

NOTE: You need to allow Bluetooth permission in the main app before using this action.
""",
		categoryName: "Device"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: try await Bluetooth.isOn())
	}
}
