import AppIntents

// TODO: Rename the intent to `GetRandomInstant`.
struct RandomDateTimeIntent: AppIntent {
	static let title: LocalizedStringResource = "Get Random Date and Time"

	static let description = IntentDescription(
		"Returns a random date and time in the given range.",
		categoryName: "Random",
		resultValueName: "Random Date and Time"
	)

	@Parameter(title: "Start")
	var start: Date

	@Parameter(title: "End")
	var end: Date

	static var parameterSummary: some ParameterSummary {
		Summary("Get a random date and time between \(\.$start) and \(\.$end)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Date> {
		.result(value: .random(in: .fromGraceful(start, end)))
	}
}
