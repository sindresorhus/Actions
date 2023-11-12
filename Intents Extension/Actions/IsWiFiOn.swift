import AppIntents

@available(iOS, unavailable)
struct IsWiFiOnIntent: AppIntent {
	static let title: LocalizedStringResource = "Is Wi-Fi On (macOS-only)"

	static let description = IntentDescription(
		"""
		Returns whether Wi-Fi is turned on.

		It returns false if the device does not support Wi-Fi.

		Use the “Is Online” action if you simply want to check for internet connectivity.
		""",
		categoryName: "Device"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Is Wi-Fi on?")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: Device.isWiFiOn)
	}
}
