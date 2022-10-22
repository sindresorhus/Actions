import AppIntents

struct IsReachable: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "IsReachableIntent"

	static let title: LocalizedStringResource = "Is Reachable"

	static let description = IntentDescription(
"""
Returns whether the web server at the given host is reachable.

Use the “Is Online” action if you just want to check whether your computer is online.
""",
		categoryName: "Device"
	)

	@Parameter(
		title: "Host",
		description: "A domain like “google.com”, a URL like “https://google.com”, or an IP address.",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var host: String

	@Parameter(title: "Timeout (seconds)", default: 10)
	var timeout: Double // TODO: Would be nice if this could be the `Duration` type.

	static var parameterSummary: some ParameterSummary {
		Summary("Is \(\.$host) reachable?") {
			\.$timeout
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		guard let url = URL(humanString: host) else {
			throw "Invalid host.".toError
		}

		let result = await URLSession.shared.isReachable(url, timeout: timeout)

		return .result(value: result)
	}
}
