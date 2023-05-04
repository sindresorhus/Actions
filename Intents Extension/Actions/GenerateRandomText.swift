import AppIntents

struct GenerateRandomText: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "RandomTextIntent"

	static let title: LocalizedStringResource = "Generate Random Text"

	static let description = IntentDescription(
"""
Generates random text of the given length.

This can be useful as a placeholder, token, etc.
""",
		categoryName: "Random"
	)

	// We set an upper bound to not exceed allowed memory usage.
	@Parameter(title: "Length", default: 10, inclusiveRange: (0, 999_999))
	var length: Int

	@Parameter(title: "Lowercase", default: true)
	var lowercase: Bool

	@Parameter(title: "Uppercase", default: true)
	var uppercase: Bool

	@Parameter(title: "Digits", default: true)
	var digits: Bool

	@Parameter(title: "Use Custom Characters", default: false)
	var useCustomCharacters: Bool

	@Parameter(
		title: "Custom Characters",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var customCharacters: String?

	@Parameter(
		title: "Seed",
		description: "When specified, the returned text will always be the same if the seed is the same.",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var seed: String?

	static var parameterSummary: some ParameterSummary {
		When(\.$useCustomCharacters, .equalTo, true) {
			Summary("Random text of \(\.$length) characters") {
				\.$useCustomCharacters
				\.$customCharacters
				\.$seed
			}
		} otherwise: {
			Summary("Random text of \(\.$length) characters") {
				\.$lowercase
				\.$uppercase
				\.$digits
				\.$useCustomCharacters
				\.$seed
			}
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		var characters = String.RandomCharacters()

		if lowercase {
			characters.insert(.lowercase)
		}

		if uppercase {
			characters.insert(.uppercase)
		}

		if digits {
			characters.insert(.digits)
		}

		var generator = SeededRandomNumberGenerator.seededOrNot(seed: seed?.nilIfEmptyOrWhitespace)

		let result = try {
			if useCustomCharacters {
				guard let customCharacters = customCharacters?.nilIfEmptyOrWhitespace else {
					throw "You must specify some custom characters.".toError
				}

				return String.random(
					length: length,
					characters: customCharacters,
					using: &generator
				)
			}

			guard !characters.isEmpty else {
				throw "You must enable at least one of “Lowercase”, “Uppercase”, and “Digits”.".toError
			}

			return String.random(
				length: length,
				characters: characters,
				using: &generator
			)
		}()

		return .result(value: result)
	}
}
