import AppIntents
import CoreImage

struct GetAverageColorOfImage: AppIntent {
	static let title: LocalizedStringResource = "Get Average Color of Image"

	static let description = IntentDescription(
		"Returns the average color of the image.",
		categoryName: "Image",
		searchKeywords: [
			"colour"
		]
	)

	@Parameter(
		title: "Image",
		supportedTypeIdentifiers: ["public.image"]
	)
	var image: IntentFile

	static var parameterSummary: some ParameterSummary {
		Summary("Get average color of \(\.$image)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<ColorAppEntity> {
		guard let image = CIImage(data: image.data) else {
			throw "Invalid or unsupported image.".toError
		}

		guard let color = image.averageColor() else {
			throw "Failed to get average color from image.".toError
		}

		return .result(value: .init(color))
	}
}
