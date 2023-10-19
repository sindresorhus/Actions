import AppIntents

struct IsShakingDevice: AppIntent {
	static let title: LocalizedStringResource = "Is Shaking Device"

	static let description = IntentDescription(
"""
Returns whether you are currently shaking the device.

If no shaking is detect within 2 seconds, it returns “false”.

On macOS, it always returns “false”.
""",
		categoryName: "Device"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		#if os(macOS)
		.result(value: false)
		#else
		guard Device.isAccelerometerAvailable else {
			return .result(value: false)
		}

		let result = try await firstOf {
			try await Device.didShake.values.first()
			return true
		} or: {
			try? await Task.sleep(for: .seconds(2))
			return false
		}

		return .result(value: result)
		#endif
	}
}
