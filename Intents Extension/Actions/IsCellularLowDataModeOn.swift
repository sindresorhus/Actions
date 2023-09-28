import AppIntents

struct IsCellularLowDataModeOn: AppIntent {
	static let title: LocalizedStringResource = "Is Cellular Low Data Mode On"

	static let description = IntentDescription(
"""
Returns whether cellular low data mode is enabled on the device.

On macOS, it always returns false.
""",
		categoryName: "Device"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		// Give the system time to change the mode when used in an automation.
		sleep(.milliseconds(30))

		return .result(value: await Device.isCellularLowDataModeEnabled)
	}
}
