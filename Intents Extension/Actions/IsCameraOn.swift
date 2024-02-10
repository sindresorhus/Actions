import AppIntents

@available(iOS, unavailable)
@available(visionOS, unavailable)
struct IsCameraOn: AppIntent {
	static let title: LocalizedStringResource = "Is Camera On"

	static let description = IntentDescription(
		"""
		Returns whether any camera on the computer is on.
		""",
		categoryName: "Device"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		#if os(macOS)
		.result(value: Device.isAnyCameraOn)
		#else
		.result(value: false)
		#endif
	}
}
