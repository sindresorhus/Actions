import AppIntents

struct RandomFloatingPointNumberIntent: AppIntent {
	static let title: LocalizedStringResource = "Get Random Floating-Point Number"

	static let description = IntentDescription(
		"Returns a random floating-point number between the given minimum and maximum value.",
		categoryName: "Random",
		resultValueName: "Random Floating-Point Number"
	)

	@Parameter(title: "Minimum", controlStyle: .field)
	var minimum: Double

	@Parameter(title: "Maximum", controlStyle: .field)
	var maximum: Double

	@Parameter(
		title: "Seed",
		description: "When specified, the returned number will always be the same if the seed is the same.",
		inputOptions: String.IntentInputOptions(
			keyboardType: .default,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var seed: String?

	static var parameterSummary: some ParameterSummary {
		Summary("Get a random floating-point number between \(\.$minimum) and \(\.$maximum)") {
			\.$seed
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Double> {
		var generator = SeededRandomNumberGenerator.seededOrNot(seed: seed?.nilIfEmptyOrWhitespace)
		return .result(value: .random(in: .fromGraceful(minimum, maximum), using: &generator))
	}
}
