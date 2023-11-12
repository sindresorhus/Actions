import AppIntents

@available(macOS, unavailable)
struct IsSilentModeOnIntent: AppIntent {
	static let title: LocalizedStringResource = "Is Silent Mode On (iOS-only)"

	static let description = IntentDescription(
		"""
		Returns whether the silent switch (mute) is enabled on the device.

		Known limitation: This will return true even if silent mode is not enabled if it's run while Voice Memos is recording.
		""",
		categoryName: "Device"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Is silent mode on?")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: await Device.isSilentModeEnabled)
	}
}
