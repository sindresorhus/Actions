import AppIntents

struct IsShakingDevice: AppIntent {
	static let title: LocalizedStringResource = "Is Shaking Device"

	static let description = IntentDescription(
		"""
		Returns whether you are currently shaking the device.

		If no shaking is detect within 2 seconds, it returns “false”.

		On macOS and visionOS, it always returns “false”.
		""",
		categoryName: "Device",
		searchKeywords: [
			"shake",
			"gesture",
			"motion",
			"accelerometer"
		]
	)

	@Parameter(
		title: "Timeout (seconds)",
		description: "How long it should wait before giving up detecting a shake gesture. The maximum is 28.",
		default: 2,
		controlStyle: .field,
		inclusiveRange: (0, 28)
	)
	var timeout: Double

	static var parameterSummary: some ParameterSummary {
		Summary("Is shaking device?") {
			\.$timeout
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		#if os(macOS) || os(visionOS)
		.result(value: false)
		#else
		if SSApp.isiOSOnVision {
			return .result(value: false)
		}

		guard Device.isAccelerometerAvailable else {
			return .result(value: false)
		}

		let result = try await firstOf {
			try await Device.didShake.first()
			return true
		} or: {
			try? await Task.sleep(for: .seconds(timeout))
			return false
		}

		return .result(value: result)
		#endif
	}
}
