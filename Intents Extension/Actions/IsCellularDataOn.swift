import AppIntents

struct IsCellularDataOn: AppIntent {
	static let title: LocalizedStringResource = "Is Cellular Data On"

	static let description = IntentDescription(
		"""
		Returns whether cellular data is enabled on the device.

		On macOS, it always returns false.
		""",
		categoryName: "Device"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		// Give the system time to change the mode when used in an automation.
		sleep(.milliseconds(30))

		return .result(value: await Device.isCellularDataEnabled)
	}
}
