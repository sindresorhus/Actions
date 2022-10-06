import AppIntents

struct ClampNumber: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "ClampNumberIntent"

	static let title: LocalizedStringResource = "Clamp Number"

	static let description = IntentDescription(
"""
Clamps the input number to above or equal to the given minimum number and below or equal to the given maximum number.

For example, if you provide 10 as the number, 4 as minimum, and 8 as maximum, you will get 8 back.
""",
		categoryName: "Number"
	)

	@Parameter(title: "Number", controlStyle: .field)
	var number: Double

	@Parameter(title: "Minimum", controlStyle: .field)
	var minimum: Double

	@Parameter(title: "Maximum", controlStyle: .field)
	var maximum: Double

	static var parameterSummary: some ParameterSummary {
		Summary("Clamp \(\.$number) to be within \(\.$minimum) and \(\.$maximum)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Double> {
		.result(value: number.clamped(to: .fromGraceful(minimum, maximum)))
	}
}
