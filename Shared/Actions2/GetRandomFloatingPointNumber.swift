import AppIntents

struct GetRandomFloatingPointNumber: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "RandomFloatingPointNumberIntent"

	static let title: LocalizedStringResource = "Get Random Floating-Point Number"

	static let description = IntentDescription(
		"Returns a random floating-point number between the given minimum and maximum value.",
		categoryName: "Random"
	)

	@Parameter(title: "Minimum", controlStyle: .field)
	var minimum: Double

	@Parameter(title: "Maximum", controlStyle: .field)
	var maximum: Double

	static var parameterSummary: some ParameterSummary {
		Summary("Get a random floating-point number between \(\.$minimum) and \(\.$maximum)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Double> {
		.result(value: .random(in: .fromGraceful(minimum, maximum)))
	}
}
