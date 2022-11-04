import AppIntents

struct GetHighResolutionTimestamp: AppIntent {
	static let title: LocalizedStringResource = "Get High-Resolution Timestamp"

	static let description = IntentDescription(
"""
Returns a timestamp representing the current instant in nanoseconds.

Example: 434055845120916

The most common use-case is to substract two instances of this to get a highly accurate difference.

The timestamp is not meant to be stored for a long time. It's only unique for the current computer session.
""",
		categoryName: "Date"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Get high-resolution timestamp")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Int> {
		let result = Int(clamping: clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW))
		return .result(value: result)
	}
}
