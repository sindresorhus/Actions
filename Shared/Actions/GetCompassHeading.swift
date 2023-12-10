import AppIntents
import CoreLocation

@available(macOS, unavailable)
struct GetCompassHeading: AppIntent {
	static let title: LocalizedStringResource = "Get Compass Heading (iOS-only)"

	static let description = IntentDescription(
		"""
		Returns the current compass heading, in magnetic or true north format.

		The returned value is in degrees. The value 0 means the device is pointed toward north, 90 means it is pointed due east, 180 means it is pointed due south, and so on.

		Magnetic heading aligns with traditional compasses and maps, while true north is crucial for accurate astronomical alignments and specific surveying tasks.
		""",
		categoryName: "Location",
		searchKeywords: [
			"location",
			"direction"
		],
		resultValueName: "Compass Heading"
	)

	@Parameter(title: "Heading Type", default: .magnetic)
	var headingType: CompassHeadingType_AppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Get \(\.$headingType) compass heading")
	}

	// The intent crashes with a that we defined a different `ReturnsValue` type than what we returned if we use `Measurement<UnitAngle>`. (iOS 17.1)
	@MainActor
//	func perform() async throws -> some IntentResult & ReturnsValue<Measurement<UnitAngle>> {
	func perform() async throws -> some IntentResult & ReturnsValue<Double> {
		if headingType == .trueNorth {
			CLLocationManager().requestWhenInUseAuthorization()

			let status = CLLocationManager().authorizationStatus
			guard status == .authorizedWhenInUse || status == .authorizedAlways else {
				throw "Location permission not granted. You can grant access in “Settings › Actions”.".toError
			}
		}

		guard let heading = try await CLLocationManager.headingUpdates().first() else {
			throw "Failed to get heading.".toError
		}

//		let headingAngle: Measurement<UnitAngle> = switch headingType {
//		case .magnetic:
//			.init(value: heading.magneticHeading, unit: .degrees)
//		case .trueNorth:
//			.init(value: heading.trueHeading, unit: .degrees)
//		}

		let headingAngle = switch headingType {
		case .magnetic:
			heading.magneticHeading
		case .trueNorth:
			heading.trueHeading
		}

		return .result(value: headingAngle)
	}
}

@available(macOS, unavailable)
enum CompassHeadingType_AppEnum: String, AppEnum {
	case magnetic
	case trueNorth

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Compass Heading Type"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.magnetic: "Magnetic",
		.trueNorth: "True North"
	]
}
