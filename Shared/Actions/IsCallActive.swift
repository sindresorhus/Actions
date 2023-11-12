import AppIntents

struct IsCallActive: AppIntent {
	static let title: LocalizedStringResource = "Is Call Active"

	static let description = IntentDescription(
		"""
		Returns whether the device is on a call (phone, FaceTime, VoIP, etc).

		On macOS, it always returns “false”.
		""",
		categoryName: "Device"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: Device.hasActiveCall)
	}
}
