import AppIntents

struct IsOnlineIntent: AppIntent {
	static let title: LocalizedStringResource = "Is Online"

	static let description = IntentDescription(
		"Returns whether the computer is online. It tries to connect to one or more servers to ensure you're actually online.",
		categoryName: "Device"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Is online?")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: Reachability.isOnlineExtensive())
	}
}
