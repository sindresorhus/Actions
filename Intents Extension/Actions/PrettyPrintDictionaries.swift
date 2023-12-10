import AppIntents

struct PrettyPrintDictionariesIntent: AppIntent {
	static let title: LocalizedStringResource = "Pretty Print Dictionaries"

	static let description = IntentDescription(
		"Formats dictionaries (JSON) to be prettier and more readable.",
		categoryName: "Formatting",
		resultValueName: "Pretty Printed Dictionaries"
	)

	@Parameter(
		title: "Dictionary",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var dictionaries: [String]

	static var parameterSummary: some ParameterSummary {
		Summary("Pretty print \(\.$dictionaries)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[String]> {
		let result = try dictionaries.map { try $0.prettyFormatJSON() }
		return .result(value: result)
	}
}
