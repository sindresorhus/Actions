import AppIntents
import NetworkExtension

@available(macOS, unavailable)
struct JoinWiFiIntent: AppIntent {
	static let title: LocalizedStringResource = "Join Wi-Fi"

	static let description = IntentDescription(
		"""
		Joins the given Wi-Fi network.

		NOTE: The prompt to join a Wi-Fi network can only be presented in an app, so the action has to open the Actions app momentarily and then it switches back to the Shortcuts app. If you're running the shortcut in the background, you may want to add the “Go to Home Screen” action after this one. It is not possible to join a Wi-Fi network without the join prompt.
		""",
		categoryName: "Device",
		searchKeywords: [
			"wifi",
			"network",
			"internet",
			"connect"
		]
	)

	static let openAppWhenRun = true

	@Parameter(
		title: "Name (SSID)",
		inputOptions: .init(
			capitalizationType: .none,
			multiline: false,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var ssid: String

	@Parameter(
		title: "Password",
		inputOptions: .init(
			capitalizationType: .none,
			multiline: false,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var password: String

	@Parameter(
		title: "Wait for Connection",
		description: "Whether the action should wait for the connection to complete before continuing. Setting this to false means you will not be notified of any connection errors.",
		default: true
	)
	var waitForConnection: Bool

	@Parameter(
		title: "Is WEP",
		description: "Set this to true if the network is WEP, otherwise it is assumed to be WPA/WPA2/WPA3.",
		default: false
	)
	var isWEP: Bool

	@Parameter(
		title: "Is Hidden",
		description: "Whether the Wi-Fi name (SSID) is hidden. Setting this to true makes the system perform an active scan for the SSID.",
		default: false
	)
	var isHidden: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("Join Wi-Fi named \(\.$ssid)") {
			\.$password
			\.$waitForConnection
			\.$isWEP
			\.$isHidden
		}
	}

	@MainActor
	func perform() async throws -> some IntentResult {
		Task {
			ShortcutsApp.open()
		}

		if waitForConnection {
			try await join()
		} else {
			Task {
				try await join()
			}
		}

		return .result()
	}

	private func join() async throws {
		#if !os(macOS)
		let configuration = NEHotspotConfiguration(
			ssid: ssid,
			passphrase: password,
			isWEP: isWEP
		)
		configuration.joinOnce = true
		configuration.hidden = isHidden

		try await NEHotspotConfigurationManager.shared.apply(configuration)
		#endif
	}
}
