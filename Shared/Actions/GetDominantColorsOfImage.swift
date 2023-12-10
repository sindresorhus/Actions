import AppIntents
import CoreImage

struct GetDominantColorsOfImage: AppIntent {
	static let title: LocalizedStringResource = "Get Dominant Colors of Image"

	static let description = IntentDescription(
		"""
		Returns the dominant colors of the image.

		You could use this to make a palette of the main colors in an image.

		Dominant color is the most seen color in an image, while average color is all the colors in an image mixed into one.

		Note: The Shortcuts output preview is buggy and shows the colors in random order. Switch to the list view for a stable order in the preview.
		""",
		categoryName: "Color",
		searchKeywords: [
			"colour",
			"primary",
			"palette",
			"average"
		],
		resultValueName: "Dominant Colors of Image"
	)

	@Parameter(
		title: "Image",
		supportedTypeIdentifiers: ["public.image"]
	)
	var image: IntentFile

	@Parameter(
		title: "Count",
		description: "The number of colors to return. The colors are ordered by most dominant first. Max 128.",
		default: 5,
		inclusiveRange: (1, 128)
	)
	var count: Int

	static var parameterSummary: some ParameterSummary {
		Summary("Get \(\.$count) dominant colors of \(\.$image)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[ColorAppEntity]> {
		let colors = try CIImage.from(image.data)
			.dominantColors(count: count)
			.map { ColorAppEntity($0) }

		return .result(value: colors)
	}
}
