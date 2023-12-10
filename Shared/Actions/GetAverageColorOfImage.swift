import AppIntents
import CoreImage

struct GetAverageColorOfImage: AppIntent {
	static let title: LocalizedStringResource = "Get Average Color of Image"

	static let description = IntentDescription(
		"""
		Returns the average color of the image.

		Average color is all the colors in an image mixed into one, while dominant color is the most seen color in an image.
		""",
		categoryName: "Color",
		searchKeywords: [
			"colour"
		],
		resultValueName: "Average Color of Image"
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
		let color = try CIImage.from(image.data).averageColor()
		return .result(value: .init(color))
	}
}
