import AppIntents
import CoreImage

struct BlurImages: AppIntent {
	static let title: LocalizedStringResource = "Blur Images"

	static let description = IntentDescription(
		"Apply gaussian blur to the input images.",
		categoryName: "Image",
		resultValueName: "Blurred Images"
	)

	@Parameter(
		title: "Images",
		supportedTypeIdentifiers: ["public.image"]
	)
	var images: [IntentFile]

	@Parameter(
		title: "Amount",
		description: "For example, 10% blur will look the same regardless of the dimensions of the image. If you specify it as a variable, it should be a number from 0 to 1.",
		controlStyle: .slider,
		inclusiveRange: (0, 1)
	)
	var amount: Double

	static var parameterSummary: some ParameterSummary {
		Summary("Apply \(\.$amount) blur to \(\.$images)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		guard amount > 0 else {
			return .result(value: images)
		}

		let result = try images.map {
			guard
				let file = try CIImage.from($0.data)
					.gaussianBlurred(fractionalAmount: amount)
					.pngData()?
					// We use a unique filename as it seems to not be able to handle multiple runs with the same filename. (iOS 16.0)
					.toIntentFile(contentType: .png, filename: UUID().uuidString)
//					.toIntentFile(contentType: .png, filename: $0.filename)
			else {
				throw "Failed to blur image.".toError
			}

			return file
		}

		return .result(value: result)
	}
}
