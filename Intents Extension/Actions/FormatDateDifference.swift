import AppIntents

struct FormatDateDifferenceIntent: AppIntent {
	static let title: LocalizedStringResource = "Format Date Difference"

	static let description = IntentDescription(
		"""
		Formats the difference of one date relative to another date.

		For example, “Yesterday” or “2 weeks ago”.
		""",
		categoryName: "Formatting",
		resultValueName: "Formatted Date Difference"
	)

	@Parameter(title: "First Date")
	var firstDate: Date

	@Parameter(title: "Second Date")
	var secondDate: Date

	static var parameterSummary: some ParameterSummary {
		Summary("Format the difference of \(\.$firstDate) relative to \(\.$secondDate)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		let formatted = RelativeDateTimeFormatter().localizedString(for: firstDate, relativeTo: secondDate)
		return .result(value: formatted)
	}
}
