import AppIntents

struct GetQueryItemValueFromURL: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GetQueryItemValueFromURLIntent"

	static let title: LocalizedStringResource = "Get Query Item Value from URL"

	static let description = IntentDescription(
		"Returns the value of the first query item with the given name from the input URL.",
		categoryName: "URL"
	)

	@Parameter(title: "URL")
	var url: URL

	@Parameter(
		title: "Name",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var queryItemName: String

	static var parameterSummary: some ParameterSummary {
		Summary("Get value of first query item named \(\.$queryItemName) from \(\.$url)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		// TODO: Returning nil is currently not supported, so we just fall back to empty string.
		.result(value: url.queryItemValue(forName: queryItemName) ?? "")
	}
}
