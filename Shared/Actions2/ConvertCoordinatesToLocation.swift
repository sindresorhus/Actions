import AppIntents
import CoreLocation

struct ConvertCoordinatesToLocation: AppIntent {
	static let title: LocalizedStringResource = "Convert Coordinates to Location"

	static let description = IntentDescription(
"""
Returns the location at the given latitude and longitude.

Tip: Use the built-in “Get Details of Locations” action to get more details from the location.
""",
		categoryName: "Miscellaneous"
	)

	@Parameter(title: "Latitude", controlStyle: .field)
	var latitude: Double

	@Parameter(title: "Longitude", controlStyle: .field)
	var longitude: Double

	static var parameterSummary: some ParameterSummary {
		Summary("Get location at coordinates \(\.$latitude), \(\.$longitude)")
	}

	@MainActor
	func perform() async throws -> some IntentResult & ReturnsValue<CLLocation> {
		let placemarks = try await CLGeocoder().reverseGeocodeLocation(.init(latitude: latitude, longitude: longitude))

		guard let placemark = placemarks.first else {
			throw NSError.appError("No known location at this coordinate.")
		}

		return .result(value: placemark)
	}
}
