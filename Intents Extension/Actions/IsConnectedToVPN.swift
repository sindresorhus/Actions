import AppIntents

@available(macOS, unavailable)
struct IsConnectedToVPN: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "IsConnectedToVPNIntent"

	static let title: LocalizedStringResource = "Is Connected to VPN (iOS-only)"

	static let description = IntentDescription(
"""
Returns whether the device is connected to a VPN.

Note: There are some VPN protocols it is not able to detect. If the check is not working, try selecting a different VPN protocol in your VPN provider's app if possible. For example, the WireGuard protocol is known to not be detectable, while OpenVPN, IKEv2, and IPSec are detectable.
""",
		categoryName: "Device"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: Device.isConnectedToVPN)
	}
}
