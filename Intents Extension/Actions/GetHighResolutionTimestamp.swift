import AppIntents

struct GetHighResolutionTimestamp: AppIntent {
	static let title: LocalizedStringResource = "Get High-Resolution Timestamp"

	static let description = IntentDescription(
		"""
		Returns a timestamp representing the current instant in nanoseconds.

		Example: 434055845120916

		The most common use-case is to subtract two instances of this to get a highly accurate difference.

		The timestamp is not meant to be stored for a long time. It's only unique for the current computer session.
		""",
		categoryName: "Date",
		resultValueName: "High-Resolution Timestamp"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Get high-resolution timestamp")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Int> {
		.result(value: Device.timestamp)
	}
}
