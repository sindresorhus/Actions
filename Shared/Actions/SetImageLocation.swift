import AppIntents
import CoreImage

// Note: This is not in the app extension as it reads `IntentFile#data` which could potentially be huge.

struct SetImageLocation: AppIntent {
	static let title: LocalizedStringResource = "Set Image Location"

	static let description = IntentDescription(
"""
Sets the capture location (Exif metadata) of the input images.

Note: It only modifies the image in the workflow, not the original image.

See the “Get Image Location” action for the inverse.
""",
		categoryName: "File"
	)

	@Parameter(
		title: "Latitude & Longitude",
		description: "Example: -77.0364, 38.8951"
	)
	var coordinateString: String

	@Parameter(title: "Image", supportedTypeIdentifiers: ["public.image"])
	var images: [IntentFile]

	static var parameterSummary: some ParameterSummary {
		Summary("Set location to \(\.$coordinateString) for \(\.$images)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		guard let coordinate = LocationCoordinate2D.parse(coordinateString) else {
			throw "Invalid coordinate.".toError
		}

		let result = try images.map { file in
			try file.withData { data in
				try CGImage.setLocation(coordinate, forImageData: &data)
			}
		}

		return .result(value: result)
	}
}
