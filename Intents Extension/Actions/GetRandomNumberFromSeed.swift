import AppIntents

struct GetRandomNumberFromSeed: AppIntent {
	static let title: LocalizedStringResource = "Get Random Number from Seed"

	static let description = IntentDescription(
		"Returns a random number between the given minimum and maximum value.",
		categoryName: "Random"
	)

	@Parameter(title: "Minimum", controlStyle: .field)
	var minimum: Int

	@Parameter(title: "Maximum", controlStyle: .field)
	var maximum: Int

	@Parameter(
		title: "Seed",
		description: "When specified, the returned number will always be the same if the seed is the same.",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var seed: String?

	static var parameterSummary: some ParameterSummary {
		Summary("Get a random number between \(\.$minimum) and \(\.$maximum) from \(\.$seed)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Int> {
		var generator = SeededRandomNumberGenerator.seededOrNot(seed: seed?.nilIfEmptyOrWhitespace)
		return .result(value: .random(in: .fromGraceful(minimum, maximum), using: &generator))
	}
}
