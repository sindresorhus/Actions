import AppIntents
import CoreLocation

@available(macOS, unavailable)
struct GetCompassHeading: AppIntent {
	static let title: LocalizedStringResource = "Get Compass Heading (iOS-only)"

	static let description = IntentDescription(
		"""
		Returns the current compass heading, in magnetic or true north format.

		Magnetic heading aligns with traditional compasses and maps, while true north is crucial for accurate astronomical alignments and specific surveying tasks.
		""",
		categoryName: "Location",
		searchKeywords: [
			"location",
			"direction"
		]
	)

	@Parameter(title: "Heading Type", default: .magnetic)
	var headingType: HeadingType_AppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Get \(\.$headingType) compass heading")
	}

	@MainActor
	func perform() async throws -> some IntentResult & ReturnsValue<Measurement<UnitAngle>> {
		if headingType == .trueNorth {
			CLLocationManager().requestWhenInUseAuthorization()

			let status = CLLocationManager().authorizationStatus
			guard status == .authorizedWhenInUse || status == .authorizedAlways else {
				throw "Location permission not granted.".toError
			}
		}

		guard let heading = try await CLLocationManager.headingUpdates().first() else {
			throw "Failed to get heading.".toError
		}

		let headingAngle: Measurement<UnitAngle> = switch headingType {
		case .magnetic:
			.init(value: heading.magneticHeading, unit: .degrees)
		case .trueNorth:
			.init(value: heading.trueHeading, unit: .degrees)
		}

		return .result(value: headingAngle)
	}
}

@available(macOS, unavailable)
enum HeadingType_AppEnum: String, AppEnum {
	case magnetic
	case trueNorth

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Heading Type"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.magnetic: "Magnetic",
		.trueNorth: "True North"
	]
}
