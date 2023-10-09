import AppIntents

struct GetUnsplashImage: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GetUnsplashImageIntent"

	static let title: LocalizedStringResource = "Get Unsplash Image"

	static let description = IntentDescription(
"""
Returns a random image from Unsplash.

For example, use it together with the built-in “Set Wallpaper” action.
""",
		categoryName: "Web"
	)

	@Parameter(title: "Keywords", default: [])
	var keywords: [String]

	@Parameter(title: "Only Featured Images", default: true)
	var onlyFeaturedImages: Bool

	@Parameter(title: "Size", default: .any)
	var size: UnsplashImageSizeAppEnum

	@Parameter(title: "Width")
	var sizeWidth: Int?

	@Parameter(title: "Height")
	var sizeHeight: Int?

	static var parameterSummary: some ParameterSummary {
		// This fails on Xcode 14.3
//		When(\.$size, .equalTo, .custom) {
//			Summary("Get Unsplash image") {
//				\.$keywords
//				\.$onlyFeaturedImages
//				\.$size
//				\.$sizeWidth
//				\.$sizeHeight
//			}
//		} otherwise: {
//			Summary("Get Unsplash image") {
//				\.$keywords
//				\.$onlyFeaturedImages
//				\.$size
//			}
//		}
		Switch(\.$size) {
			Case(.custom) {
				Summary("Get Unsplash image") {
					\.$keywords
					\.$onlyFeaturedImages
					\.$size
					\.$sizeWidth
					\.$sizeHeight
				}
			}
			DefaultCase {
				Summary("Get Unsplash image") {
					\.$keywords
					\.$onlyFeaturedImages
					\.$size
				}
			}
		}
	}

	@MainActor
	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		var url = URL("https://source.unsplash.com")
			.appendingPathComponent(onlyFeaturedImages ? "featured" : "random")

		switch size {
		case .any:
			break
		case .screenSize:
			guard let screen = XScreen.screens2.first else {
				throw "Could not get the screen size.".toError
			}

			let size = screen.nativeSize
			url = url.appendingPathComponent("\(Int(size.width))x\(Int(size.height))")
		case .custom:
			guard
				let width = sizeWidth?.nilIfZero,
				let height = sizeHeight?.nilIfZero
			else {
				throw "You must specify both “width” and “height”.".toError
			}

			url = url.appendingPathComponent("\(Int(width))x\(Int(height))")
		}

		if let keywords = keywords.nilIfEmpty {
			let string = keywords.map(\.trimmed).joined(separator: ",")
			url = url.appendingQueryItem(name: string, value: nil)
		}

		var imageURL = try await URLSession.shared.betterDownload(from: url).url

		// When an image cannot be found, the status code is still 200, so we detect it from the filename instead, and retry.
		if imageURL.filenameWithoutExtension == "source-404" {
			imageURL = try await URLSession.shared.betterDownload(from: url).url
		}

		let result = imageURL.toIntentFile.removingOnCompletion()

		return .result(value: result)
	}
}

enum UnsplashImageSizeAppEnum: String, AppEnum {
	case any
	case screenSize
	case custom

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Unsplash Image Size"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.any: "Any",
		.screenSize: "Screen Size",
		.custom: "Custom"
	]
}
