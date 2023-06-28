import AppIntents

struct WaitMilliseconds: AppIntent {
	static let title: LocalizedStringResource = "Wait Milliseconds"

	static let description = IntentDescription(
"""
Waits for the specified number of milliseconds before continuing with the next action.

It is guaranteed to take at least the given amount of milliseconds. Sometimes it may take slightly longer.

Use the built-in “Wait” action for durations longer than 1 second.
""",
		categoryName: "Miscellaneous"
	)

	@Parameter(title: "Duration")
	var duration: Int

	static var parameterSummary: some ParameterSummary {
		Summary("Wait \(\.$duration) milliseconds")
	}

	@MainActor
	func perform() async throws -> some IntentResult {
		// We use this as it's slightly more accurate than the async version.
		sleep(.milliseconds(duration))

		return .result()
	}
}
