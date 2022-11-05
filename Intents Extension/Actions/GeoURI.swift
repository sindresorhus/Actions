import AppIntents
import CoreLocation

struct GeoURI: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GeoURIIntent"

	static let title: LocalizedStringResource = "Convert Location to Geo URI"

	static let description = IntentDescription(
		"Returns the geo URI for the given location.",
		categoryName: "Location"
	)

	@Parameter(title: "Location")
	var location: CLPlacemark

	@Parameter(title: "Include Accuracy", default: true)
	var includeAccuracy: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("Get the geo URI for \(\.$location)") {
			\.$includeAccuracy
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<URL> {
		guard let result = location.location?.geoURI(includeAccuracy: includeAccuracy) else {
			throw "Failed to get the latitude and longitude for the given the location.".toError
		}

		return .result(value: result)
	}
}
