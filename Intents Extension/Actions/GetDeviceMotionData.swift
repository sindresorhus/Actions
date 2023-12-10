import AppIntents
import CoreMotion

// - Magnetic Field: Three-dimensional magnetometer data measured in microteslas.

@available(macOS, unavailable)
struct GetDeviceMotionData: AppIntent {
	static let title: LocalizedStringResource = "Get Device Motion Data (iOS-only)"

	static let description = IntentDescription(
		"""
		Returns measurements of the acceleration, rotation rate, and attitude of the device.

		Data:
		- User Acceleration: Acceleration that the user is giving to the device.
		- Gravity: Gravity acceleration vector expressed in the device's reference frame.
		- Rotation Rate: Bias-corrected gyroscope data measuring rotation around three axes.
		- Attitude: Orientation of the device relative to the device's reference frame.
			- Roll: Rotation around a longitudinal axis that passes through the device from its top to bottom.
			- Pitch: Rotation around a lateral axis that passes through the device from side to side.
			- Yaw: Rotation around its vertical axis, originating at its center of gravity and directed downwards.
			- Quaternion: Orientation in 3D space as a quaternion, providing a compact and efficient way to describe its rotation relative to the device's reference frame.

		Google “CMDeviceMotion” for more info about this data.

		Use the built-in “Show Result” action to inspect the individual properties.

		NOTE: On iOS, the action can only run for maximum 30 seconds, so the interval times sample count must be less than that.
		""",
		categoryName: "Device",
		searchKeywords: [
			"motion",
			"movement",
			"accelerometer",
			"gyro",
			"attitude",
			"gravity",
			"rotation",
			"sensor"
		],
		resultValueName: "Device Motion Data"
	)

	@Parameter(
		title: "Sample Count",
		default: 1,
		controlStyle: .field,
		inclusiveRange: (1, 9999)
	)
	var sampleCount: Int

	@Parameter(
		title: "Interval (seconds)",
		description: "Time between capturing samples.",
		default: 0.1,
		inclusiveRange: (0, 9999)
	)
	var interval: Double

	static var parameterSummary: some ParameterSummary {
		Summary("Get device motion data") {
			\.$sampleCount
			\.$interval
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[DeviceMotion_AppEntity]> {
		#if os(macOS)
		return .result(value: [])
		#else
		let samples = try await Device
			.motionUpdates(interval: .seconds(interval))
			.prefix(sampleCount)
			.map { DeviceMotion_AppEntity($0) }
			.toArray()

		return .result(value: samples)
		#endif
	}
}

struct DeviceMotion_AppEntity: TransientAppEntity {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Device Motion"

	// Properties could really use a description field...

	@Property(title: "Timestamp")
	var timestamp: Double

	@Property(title: "User Acceleration X")
	var userAccelerationX: Measurement<UnitAcceleration>

	@Property(title: "User Acceleration Y")
	var userAccelerationY: Measurement<UnitAcceleration>

	@Property(title: "User Acceleration Z")
	var userAccelerationZ: Measurement<UnitAcceleration>

	@Property(title: "Gravity X")
	var gravityX: Measurement<UnitAcceleration>

	@Property(title: "Gravity Y")
	var gravityY: Measurement<UnitAcceleration>

	@Property(title: "Gravity Z")
	var gravityZ: Measurement<UnitAcceleration>

	@Property(title: "Rotation Rate X")
	var rotationRateX: Double

	@Property(title: "Rotation Rate Y")
	var rotationRateY: Double

	@Property(title: "Rotation Rate Z")
	var rotationRateZ: Double

	@Property(title: "Attitude - Roll")
	var attitudeRoll: Measurement<UnitAngle>

	@Property(title: "Attitude - Pitch")
	var attitudePitch: Measurement<UnitAngle>

	@Property(title: "Attitude - Yaw")
	var attitudeYaw: Measurement<UnitAngle>

	@Property(title: "Attitude - Quaternion W")
	var attitudeQuaternionW: Double

	@Property(title: "Attitude - Quaternion X")
	var attitudeQuaternionX: Double

	@Property(title: "Attitude - Quaternion Y")
	var attitudeQuaternionY: Double

	@Property(title: "Attitude - Quaternion Z")
	var attitudeQuaternionZ: Double

	// These seem to always be 0.
//	@Property(title: "Magnetic Field X")
//	var magneticFieldX: Double
//
//	@Property(title: "Magnetic Field Y")
//	var magneticFieldY: Double
//
//	@Property(title: "Magnetic Field Z")
//	var magneticFieldZ: Double
//
//	@Property(title: "Magnetic Field Calibration Accuracy")
//	var magneticFieldCalibrationAccuracy: MagneticFieldCalibrationAccuracy_AppEnum

	var displayRepresentation: DisplayRepresentation {
		.init(title: "Device Motion - \(timestamp)")
	}
}

extension String {
	var toLocalizedStringResource: LocalizedStringResource { "\(self)" }
}

extension DeviceMotion_AppEntity {
	init(_ deviceMotion: CMDeviceMotion) {
		self.timestamp = deviceMotion.timestamp
		self.userAccelerationX = .init(value: deviceMotion.userAcceleration.x, unit: .gravity)
		self.userAccelerationY = .init(value: deviceMotion.userAcceleration.y, unit: .gravity)
		self.userAccelerationZ = .init(value: deviceMotion.userAcceleration.z, unit: .gravity)
		self.gravityX = .init(value: deviceMotion.gravity.x, unit: .gravity)
		self.gravityY = .init(value: deviceMotion.gravity.y, unit: .gravity)
		self.gravityZ = .init(value: deviceMotion.gravity.z, unit: .gravity)
		self.rotationRateX = deviceMotion.rotationRate.x
		self.rotationRateY = deviceMotion.rotationRate.y
		self.rotationRateZ = deviceMotion.rotationRate.z
		self.attitudeRoll = .init(value: deviceMotion.attitude.roll, unit: .radians)
		self.attitudePitch = .init(value: deviceMotion.attitude.pitch, unit: .radians)
		self.attitudeYaw = .init(value: deviceMotion.attitude.yaw, unit: .radians)
		self.attitudeQuaternionW = deviceMotion.attitude.quaternion.w
		self.attitudeQuaternionX = deviceMotion.attitude.quaternion.x
		self.attitudeQuaternionY = deviceMotion.attitude.quaternion.y
		self.attitudeQuaternionZ = deviceMotion.attitude.quaternion.z
//		self.magneticFieldX = deviceMotion.magneticField.field.x
//		self.magneticFieldY = deviceMotion.magneticField.field.y
//		self.magneticFieldZ = deviceMotion.magneticField.field.z
//		self.magneticFieldCalibrationAccuracy = .init(deviceMotion.magneticField.accuracy)
	}
}

//enum MagneticFieldCalibrationAccuracy_AppEnum: String, AppEnum {
//	case uncalibrated
//	case low
//	case medium
//	case high
//
//	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Magnetic Field Calibration Accuracy"
//
//	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
//		.uncalibrated: "Uncalibrated",
//		.low: "Low",
//		.medium: "Medium",
//		.high: "High"
//	]
//}
//
//extension MagneticFieldCalibrationAccuracy_AppEnum {
//	init(_ native: CMMagneticFieldCalibrationAccuracy) {
//		switch native {
//		case .uncalibrated:
//			self = .uncalibrated
//		case .low:
//			self = .low
//		case .medium:
//			self = .medium
//		case .high:
//			self = .high
//		@unknown default:
//			self = .uncalibrated
//		}
//	}
//}
