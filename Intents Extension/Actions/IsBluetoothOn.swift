import AppIntents

struct IsBluetoothOnIntent: AppIntent {
	static let title: LocalizedStringResource = "Is Bluetooth On"

	static let description = IntentDescription(
		"""
		Returns whether Bluetooth is on or off.

		NOTE: You need to allow the Bluetooth permission in the main app before using this action.
		""",
		categoryName: "Bluetooth"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: try await Bluetooth.isOn())
	}
}
