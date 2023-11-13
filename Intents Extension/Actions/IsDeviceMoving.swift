import AppIntents

struct IsDeviceMoving: AppIntent {
	static let title: LocalizedStringResource = "Is Device Moving"

	static let description = IntentDescription(
		"""
		Returns whether the device is currently moving.

		If no movement is detect within 1 second, it returns “false”.

		This can be useful to detect whether the device is in use or not.

		On macOS, it always returns “false”.
		""",
		categoryName: "Device",
		searchKeywords: [
			"movement",
			"motion",
			"accelerometer",
			"still",
			"gyro"
		]
	)

	@Parameter(
		title: "Timeout (seconds)",
		description: "How long it should wait before giving up waiting for the device to move. The maximum is 30.",
		default: 1,
		controlStyle: .field,
		inclusiveRange: (0, 30)
	)
	var timeout: Double

	@Parameter(
		title: "Minimum Acceleration",
		description: "Defines the threshold acceleration in units of gravitational force (G's) required to register as movement. A higher threshold requires more significant movements to trigger detection, whereas a lower threshold is more sensitive to minor movements. Default: 0.01.",
		default: 0.01,
		controlStyle: .field,
		inclusiveRange: (0, 20)
	)
	var minAcceleration: Double

	static var parameterSummary: some ParameterSummary {
		Summary("Is device moving?") {
			\.$timeout
			\.$minAcceleration
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		#if os(macOS)
		.result(value: false)
		#else
		let result = try await firstOf {
			_ = try await Device.isMovingUpdates(minAcceleration: minAcceleration).first { $0 }
			return true
		} or: {
			try? await Task.sleep(for: .seconds(timeout))
			return false
		}

		return .result(value: result)
		#endif
	}
}
