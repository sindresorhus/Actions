import AppIntents

@available(macOS, unavailable)
struct IsSilentModeOn: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "IsSilentModeOnIntent"

	static let title: LocalizedStringResource = "Is Silent Mode On (iOS-only)"

	static let description = IntentDescription(
		"Returns whether the silent switch (mute) is enabled on the device.",
		categoryName: "Device"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Is silent mode on?")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: await Device.isSilentModeEnabled)
	}
}
