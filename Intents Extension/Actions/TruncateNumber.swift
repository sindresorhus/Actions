import AppIntents

struct TruncateNumber: AppIntent {
	static let title: LocalizedStringResource = "Truncate Number"

	static let description = IntentDescription(
"""
Removes the fractional part of the given number.

Example: 3.4 => 3
""",
		categoryName: "Text",
		searchKeywords: [
			"decimal",
			"fraction",
			"remove",
			"strip",
			"whole",
			"integer"
		]
	)

	@Parameter(title: "Number")
	var number: Double

	static var parameterSummary: some ParameterSummary {
		Summary("Truncate \(\.$number)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Double> {
		.result(value: number.rounded(.towardZero))
	}
}
