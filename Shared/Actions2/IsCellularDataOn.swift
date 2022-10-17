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

	static var parameterSummary: some ParameterSummary {
		Summary("Is cellular data on?")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: await Device.isCellularDataEnabled)
	}
}
