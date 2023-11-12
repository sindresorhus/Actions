import AppIntents
import Network

// Note: This has to be in the main app target so that it's able to show the prompt to request access to the local network.

struct IsHostReachable: AppIntent {
	static let title: LocalizedStringResource = "Is Host Reachable"

	static let description = IntentDescription(
		"""
		Returns whether the host at the given domain or IP address is reachable.

		Use the “Is Web Server Reachable” action if the host is a web server.
		""",
		categoryName: "Device"
	)

	@Parameter(
		title: "Host",
		description: "A domain (sindresorhus.com) or IP address (172.67.135.124).",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var host: String

	@Parameter(
		title: "Port",
		controlStyle: .field,
		inclusiveRange: (1, 65_535)
	)
	var port: Int

	@Parameter(title: "Timeout (seconds)", default: 10)
	var timeout: Double // TODO: Would be nice if this could be the `Duration` type.

	@Parameter(
		title: "Debug",
		description: "Throw errors instead of simply returning “false”. Can be useful for debugging.",
		default: false
	)
	var debugMode: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("Is \(\.$host) at port \(\.$port) reachable?") {
			\.$timeout
			\.$debugMode
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		guard let port = NWEndpoint.Port(rawValue: .init(clamping: port)) else {
			throw "Invalid port.".toError
		}

		let connection = NWConnection(
			host: .init(host),
			port: port,
			using: .tcp
		)

		let result = try await {
			do {
				try await connection.connect(timeout: timeout.timeIntervalToDuration)
				return true
			} catch {
				if debugMode {
					throw error
				}

				return false
			}
		}()

		return .result(value: result)
	}
}
