import Foundation

@MainActor
final class RandomTextIntentHandler: NSObject, RandomTextIntentHandling {
	func resolveLength(for intent: RandomTextIntent) async -> RandomTextLengthResolutionResult {
		guard
			let length = intent.length as? Int,
			length > 0
		else {
			return .unsupported(forReason: .lessThanMinimumValue)
		}

		// Higher lengths than this exceed the allowed memory usage.
		guard length <= 999_999 else {
			return .unsupported(forReason: .greaterThanMaximumValue)
		}

		return .success(with: length)
	}

	func resolveCustomCharacters(for intent: RandomTextIntent) async -> RandomTextCustomCharactersResolutionResult {
		guard let customCharacters = intent.customCharacters?.nilIfEmptyOrWhitespace else {
			return .unsupported(forReason: .empty)
		}

		return .success(with: customCharacters)
	}

	func handle(intent: RandomTextIntent) async -> RandomTextIntentResponse {
		let length = intent.length as? Int ?? 10
		var characters = String.RandomCharacters()

		if intent.lowercase?.boolValue == true {
			characters.insert(.lowercase)
		}

		if intent.uppercase?.boolValue == true {
			characters.insert(.uppercase)
		}

		if intent.digits?.boolValue == true {
			characters.insert(.digits)
		}

		let response = RandomTextIntentResponse(code: .success, userActivity: nil)

		// TODO: This can be simplified with Swift 5.7 to not use type-eraser. `some RandomNumberGenerator`.
		var generator: AnyRandomNumberGenerator = {
			if let seed = intent.seed?.nilIfEmptyOrWhitespace {
				return SeededRandomNumberGenerator(seed: seed).eraseToAny()
			} else {
				return SystemRandomNumberGenerator().eraseToAny()
			}
		}()

		if intent.useCustomCharacters?.boolValue == true {
			response.result = String.random(
				length: length,
				characters: intent.customCharacters ?? "🦄",
				using: &generator
			)
		} else {
			guard !characters.isEmpty else {
				return .failure(failure: "You must enable at least one of “Lowercase”, “Uppercase”, and “Digits”.")
			}

			response.result = String.random(
				length: length,
				characters: characters,
				using: &generator
			)
		}

		return response
	}
}
