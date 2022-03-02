import SwiftUI

@MainActor
final class SymbolImageIntentHandler: NSObject, SymbolImageIntentHandling {
	func handle(intent: SymbolImageIntent) async -> SymbolImageIntentResponse {
		let response = SymbolImageIntentResponse(code: .success, userActivity: nil)

		guard let symbolName = intent.symbolName else {
			return response
		}

		let size = intent.size as? Double ?? 128

		guard size <= 2000 else {
			return .failure(failure: "The maximum size is 2000")
		}

		var configuration = XImage.SymbolConfiguration(pointSize: size, weight: .regular)

		switch intent.rendering {
		case .unknown, .monochrome:
			if
				let hexString = intent.monochromeColor,
				let color = XColor(hexString: hexString)
			{
				configuration = configuration.applying(XImage.SymbolConfiguration(paletteColors: [color]))
			}
		case .hierarchical:
			if
				let hexString = intent.hierarchicalColor,
				let color = XColor(hexString: hexString)
			{
				configuration = configuration.applying(XImage.SymbolConfiguration(hierarchicalColor: color))
			}
		case .palette:
			if let colors = (intent.paletteColors?.compactMap { XColor(hexString: $0) }) {
				configuration = configuration.applying(XImage.SymbolConfiguration(paletteColors: colors))
			}
		case .multicolor: // TODO: Does not work on macOS. (macOS 12.2)
			configuration = configuration.applying(XImage.SymbolConfiguration.preferringMulticolor())
		}

		guard var image = XImage(systemName: symbolName) else {
			return .failure(failure: "No SF Symbol with the given name or it requires a newer operating system version")
		}

		image = image.withConfiguration(configuration)

		#if canImport(AppKit)
		// See: https://developer.apple.com/forums/thread/663728
		image = image.normalizingImage()
		#endif

		response.result = image.toINFile(filename: symbolName)

		return response
	}
}
