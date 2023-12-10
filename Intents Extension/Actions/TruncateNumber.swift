import AppIntents

struct TruncateNumber: AppIntent {
	static let title: LocalizedStringResource = "Truncate Number"

	static let description = IntentDescription(
		"""
		Removes the fractional part of the given number.

		Example: 3.4 => 3
		Example: 3.457 => 3.45
		""",
		categoryName: "Number",
		searchKeywords: [
			"decimal",
			"fraction",
			"remove",
			"strip",
			"whole",
			"integer"
		],
		resultValueName: "Truncated Number"
	)

	@Parameter(title: "Number")
	var number: Double

	// It returns `NaN` for decimal places higher than 300. We limit it to 100 just to be safe.
	@Parameter(title: "Decimal Places", default: 0, inclusiveRange: (0, 100))
	var decimalPlaces: Int

	static var parameterSummary: some ParameterSummary {
		Summary("Truncate \(\.$number) to \(\.$decimalPlaces) decimal places")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Double> {
		.result(value: number.truncated(toDecimalPlaces: decimalPlaces))
	}
}
