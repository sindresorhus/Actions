import AppIntents

struct ConvertDateToUnixTime: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "DateToUnixTimeIntent"

	static let title: LocalizedStringResource = "Convert Date to Unix Time"

	static let description = IntentDescription(
"""
Returns the Unix time for the input date.

Example: 1663178163

Tip: Write “current date” as the date to get it for the current date and time.

Unix time (also known as Epoch time) is a system for describing a point in time — the number of seconds that have elapsed since the Unix epoch.
""",
		categoryName: "Date"
	)

	@Parameter(title: "Date")
	var date: Date

	static var parameterSummary: some ParameterSummary {
		Summary("Convert \(\.$date) to Unix time")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Int> {
		.result(value: Int(date.timeIntervalSince1970))
	}
}
