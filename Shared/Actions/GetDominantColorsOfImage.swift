import AppIntents
import DominantColors

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

	@Parameter(
		title: "Exclude White",
		description: "Exclude white colors.",
		default: false
	)
	var excludeWhite: Bool

	@Parameter(
		title: "Exclude Black",
		description: "Exclude black colors.",
		default: false
	)
	var excludeBlack: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("Get \(\.$count) dominant colors of \(\.$image)") {
			\.$excludeWhite
			\.$excludeBlack
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[ColorAppEntity]> {
		guard let image = XImage(data: image.data)?.cgImage else {
			throw "Failed to load image.".toError
		}

		let colors = try DominantColors
			.dominantColors(
				image: image,
				quality: .high,
				algorithm: .CIEDE2000,
				maxCount: count,
				options: [
					excludeWhite ? .excludeWhite : nil,
					excludeBlack ? .excludeBlack : nil
				].compact()
			)
			.map {
				ColorAppEntity($0.toResolvedColor)
			}

		return .result(value: colors)
	}
}
