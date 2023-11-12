import AppIntents

@available(iOS, unavailable)
struct IsScreenLockedIntent: AppIntent {
	static let title: LocalizedStringResource = "Is Screen Locked (macOS-only)"

	static let description = IntentDescription(
		"Returns whether the screen is locked.",
		categoryName: "Device"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Is the screen locked?")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: Device.isScreenLocked)
	}
}
