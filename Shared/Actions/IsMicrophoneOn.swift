import AppIntents

// NOTE: The check only works when run in the main app.

@available(iOS, unavailable)
@available(visionOS, unavailable)
struct IsMicrophoneOnIntent: AppIntent {
	static let title: LocalizedStringResource = "Is Microphone On"

	static let description = IntentDescription(
		"""
		Returns whether any microphone on the computer is on.
		""",
		categoryName: "Device"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		#if os(macOS)
		.result(value: Device.isAnyMicrophoneOn)
		#else
		.result(value: false)
		#endif
	}
}
