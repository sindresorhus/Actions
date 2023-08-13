import AppIntents
import CoreImage

struct InvertImages: AppIntent {
	static let title: LocalizedStringResource = "Invert Images"

	static let description = IntentDescription(
"""
Invert the colors of the input images.
""",
		categoryName: "Image"
	)

	@Parameter(
		title: "Images",
		supportedTypeIdentifiers: ["public.image"]
	)
	var images: [IntentFile]

	static var parameterSummary: some ParameterSummary {
		Summary("Invert \(\.$images)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		let result = try images.map {
			guard
				let file = try CIImage.from($0.data)
					.inverted?
					.pngData()?
					// We use a unique filename as it seems to not be able to handle multiple runs with the same filename. (iOS 16.0)
					.toIntentFile(contentType: .png, filename: UUID().uuidString)
//					.toIntentFile(contentType: .png, filename: $0.filename)
			else {
				throw "Failed to invert image.".toError
			}

			return file
		}

		return .result(value: result)
	}
}
