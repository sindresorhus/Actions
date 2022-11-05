import AppIntents

struct FormatNumberCompact: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "FormatNumberCompactIntent"

	static let title: LocalizedStringResource = "Format Number — Compact"

	static let description = IntentDescription(
"""
Formats the number into text using a compact style.

For example, 3420 becomes “3.4 thousand” or “3.4K”.
""",
		categoryName: "Formatting"
	)

	@Parameter(title: "Number")
	var number: Double

	@Parameter(title: "Abbreviated Unit", default: false)
	var abbreviatedUnit: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("Format \(\.$number) with compact style") {
			\.$abbreviatedUnit
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		// TODO: It crashes if we use `String?` as return value, so for now, we use an empty string.
		let result = number.formatWithCompactStyle(abbreviatedUnit: abbreviatedUnit) ?? ""
		return .result(value: result)
	}
}
