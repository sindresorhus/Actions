import AppIntents

struct IsTimeIntent: AppIntent {
	static let title: LocalizedStringResource = "Is Time"

	static let description = IntentDescription(
		"""
		Checks if the input time corresponds to the current hour and minute.
		""",
		categoryName: "Date"
	)

	@Parameter(
		title: "Time",
		description: "For example: 22:30 or 10:30 PM",
		kind: .time
	)
	var time: Date

	static var parameterSummary: some ParameterSummary {
		Summary("Is the current time \(\.$time)?")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: Calendar.current.matchesHourAndMinute(of: time))
	}
}
