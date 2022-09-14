import AppIntents

@available(macOS, unavailable)
struct IsConnectedToVPN: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "IsConnectedToVPNIntent"

	static let title: LocalizedStringResource = "Is Connected to VPN (iOS-only)"

	static let description = IntentDescription(
		"Returns whether the device is connected to a VPN.",
		categoryName: "Device"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: Device.isConnectedToVPN)
	}
}
