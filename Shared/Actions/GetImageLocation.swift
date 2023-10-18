import AppIntents
import CoreImage

// Note: This is not in the app extension as it reads `IntentFile#data` which could potentially be huge.

struct GetImageLocation: AppIntent {
	static let title: LocalizedStringResource = "Get Image Location"

	static let description = IntentDescription(
"""
Returns the capture location of the image from Exif metadata, if any.

The return value is in the format “-77.0364, 38.8951” (latitude, longitude).

See the “Set Image Location” action for the inverse.
""",
		categoryName: "File"
	)

	@Parameter(title: "Image", supportedTypeIdentifiers: ["public.image"])
	var image: IntentFile

	static var parameterSummary: some ParameterSummary {
		Summary("Get the location of \(\.$image)")
	}

	// TODO: Use optional string when targeting macOS 14.
	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		let result = CGImage.location(ofImage: image.data)?.formatted ?? ""
		return .result(value: result)
	}
}
