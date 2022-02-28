import Foundation

@MainActor
final class CreateColorImageIntentHandler: NSObject, CreateColorImageIntentHandling {
	func handle(intent: CreateColorImageIntent) async -> CreateColorImageIntentResponse {
		let alpha = intent.opacity as? Double ?? 1

		guard
			let hexString = intent.color,
			let color = XColor(hexString: hexString, alpha: alpha),
			let width = intent.width as? Int,
			let height = intent.height as? Int,
			width <= 8000,
			height <= 8000
		else {
			return .init(code: .success, userActivity: nil)
		}

		let response = CreateColorImageIntentResponse(code: .success, userActivity: nil)

		response.result = XImage.color(
			color,
			size: .init(width: width, height: height),
			scale: 1
		)
			.toINFile()

		return response
	}
}
