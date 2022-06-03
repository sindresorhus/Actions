import Foundation
import Intents

@MainActor
final class TransformTextIntentHandler: NSObject, TransformTextIntentHandling {
	func resolveText(for intent: TransformTextIntent) async -> INStringResolutionResult {
		guard
			let text = intent.text,
			!text.isEmpty
		else {
			return .needsValue()
		}

		return .success(with: text)
	}

	func resolveTransformation(for intent: TransformTextIntent) async -> TransformationResolutionResult {
		guard intent.transformation != .unknown else {
			return .needsValue()
		}

		return .success(with: intent.transformation)
	}

	func handle(intent: TransformTextIntent) async -> TransformTextIntentResponse {
		let response = TransformTextIntentResponse(code: .success, userActivity: nil)

		switch intent.transformation {
		case .unknown:
			return .init(code: .failure, userActivity: nil)
		case .camelCase:
			response.result = intent.text?.camelCasing()
		case .pascalCase:
			response.result = intent.text?.pascalCasing()
		case .snakeCase:
			response.result = intent.text?.snakeCasing()
		case .constantCase:
			response.result = intent.text?.constantCasing()
		case .dashCase:
			response.result = intent.text?.dashCasing()
		case .transliterateToArabic:
			response.result = intent.text?.applyingTransform(.latinToArabic, reverse: false)
		case .transliterateToCyrillic:
			response.result = intent.text?.applyingTransform(.latinToCyrillic, reverse: false)
		case .transliterateToGreek:
			response.result = intent.text?.applyingTransform(.latinToGreek, reverse: false)
		case .transliterateToHebrew:
			response.result = intent.text?.applyingTransform(.latinToHebrew, reverse: false)
		case .transliterateToLatin:
			response.result = intent.text?.applyingTransform(.toLatin, reverse: false)
		}

		return response
	}
}
