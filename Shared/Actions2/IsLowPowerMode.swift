import AppIntents

struct IsLowPowerMode: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "IsLowPowerModeIntent"

	static let title: LocalizedStringResource = "Is Low Power Mode On"

	static let description = IntentDescription(
		"Returns whether low power mode is enabled on the device.",
		categoryName: "Device"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: ProcessInfo.processInfo.isLowPowerModeEnabled)
	}
}
