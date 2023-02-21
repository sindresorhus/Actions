import AppIntents

struct IsReachable: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "IsReachableIntent"

	static let title: LocalizedStringResource = "Is Web Server Reachable"

	static let description = IntentDescription(
"""
Returns whether the web server at the given host or URL is reachable.

Use the “Is Online” action if you just want to check whether your computer is online.

Use the "Is Host Reachable" action if you want to check reachability with a host that is not a web server.
""",
		categoryName: "Device"
	)

	@Parameter(
		title: "Host",
		description: "A domain (sindresorhus.com), URL (https://sindresorhus.com/actions), or IP address (172.67.135.124).",
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

	@Parameter(
		title: "Require success (2xx) status code",
		default: true
	)
	var requireSuccessStatusCode: Bool

	@Parameter(
		title: "Use GET instead of HEAD",
		description: "While the HEAD HTTP method is faster and widely supported, there are some scenarios involving proxies where using the GET method could work better.",
		default: false
	)
	var useGetMethod: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("Is web server at \(\.$host) reachable?") {
			\.$timeout
			\.$requireSuccessStatusCode
			\.$useGetMethod
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		guard let url = URL(humanString: host) else {
			throw "Invalid host.".toError
		}

		let result = await URLSession.shared.isReachable(
			url,
			method: useGetMethod ? .get : .head,
			timeout: timeout.timeIntervalToDuration,
			requireSuccessStatusCode: requireSuccessStatusCode
		)

		return .result(value: result)
	}
}
