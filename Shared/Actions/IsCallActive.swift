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
		guard Locale.current.region != .chinaMainland else {
			throw "This action is not available in China. The Chinese Ministry of Industry and Information Technology (MIIT) requested that CallKit functionality be deactivated in all apps available on the China App Store.".toError
		}

		return .result(value: Device.hasActiveCall)
	}
}
