import SwiftUI

@MainActor
final class GetUnsplashImageIntentHandler: NSObject, GetUnsplashImageIntentHandling {
	func handle(intent: GetUnsplashImageIntent) async -> GetUnsplashImageIntentResponse {
		let response = GetUnsplashImageIntentResponse(code: .success, userActivity: nil)

		let onlyFeaturedImages = intent.onlyFeaturedImages as? Bool ?? false

		var url = URL("https://source.unsplash.com")
			.appendingPathComponent(onlyFeaturedImages ? "featured" : "random")

		switch intent.size {
		case .unknown, .any:
			break
		case .screenSize:
			guard let screen = XScreen.screens.first else {
				return .failure(failure: "Could not get the screen size.")
			}

			let size = screen.nativeSize
			url = url.appendingPathComponent("\(Int(size.width))x\(Int(size.height))")
		case .custom:
			guard
				let width = (intent.sizeWidth as? Int)?.nilIfZero,
				let height = (intent.sizeHeight as? Int)?.nilIfZero
			else {
				return .failure(failure: "You must specify both “width” and “height”.")
			}

			url = url.appendingPathComponent("\(Int(width))x\(Int(height))")
		}

		if let keywords = intent.keywords?.nilIfEmpty {
			let string = keywords.map(\.trimmed).joined(separator: ",")
			url = url.appendingQueryItem(name: string, value: nil)
		}

		do {
			var imageURL = try await URLSession.shared.betterDownload(from: url).url

			// When an image cannot be found, the status code is still 200, so we detect it from the filename instead, and retry.
			if imageURL.filenameWithoutExtension == "source-404" {
				imageURL = try await URLSession.shared.betterDownload(from: url).url
			}

			response.result = imageURL.toINFile
		} catch {
			return .failure(failure: error.presentableMessage)
		}

		return response
	}
}
