import AppIntents

struct TransformText: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "TransformTextIntent"

	static let title: LocalizedStringResource = "Transform Text"

	static let description = IntentDescription(
		"Transforms the input text to camel case, pascal case, snake case, constant case, or dash case. It also has transliteration transformations.",
		categoryName: "Text"
	)

	@Parameter(title: "Text")
	var text: String

	@Parameter(title: "Transformation")
	var transformation: TransformationAppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Transform \(\.$text) using \(\.$transformation)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		let value: String? = {
			switch transformation {
			case .camelCase:
				return text.camelCasing()
			case .pascalCase:
				return text.pascalCasing()
			case .snakeCase:
				return text.snakeCasing()
			case .constantCase:
				return text.constantCasing()
			case .dashCase:
				return text.dashCasing()
			case .transliterateLatinToArabic:
				return text.applyingTransform(.latinToArabic, reverse: false)
			case .transliterateLatinToCyrillic:
				return text.applyingTransform(.latinToCyrillic, reverse: false)
			case .transliterateLatinToGreek:
				return text.applyingTransform(.latinToGreek, reverse: false)
			case .transliterateLatinToHebrew:
				return text.applyingTransform(.latinToHebrew, reverse: false)
			case .transliterateLatinToHangul:
				return text.applyingTransform(.latinToHangul, reverse: false)
			case .transliterateLatinToHiragana:
				return text.applyingTransform(.latinToHiragana, reverse: false)
			case .transliterateLatinToThai:
				return text.applyingTransform(.latinToThai, reverse: false)
			case .transliterateHiraganaToKatakana:
				return text.applyingTransform(.hiraganaToKatakana, reverse: false)
			case .transliterateMandarinToLatin:
				return text.applyingTransform(.mandarinToLatin, reverse: false)
			case .transliterateToLatin:
				return text.applyingTransform(.toLatin, reverse: false)
			case .stripDiacritics:
				return text.applyingTransform(.stripDiacritics, reverse: false)
			}
		}()

		// TODO: Should it throw if nil?

		return .result(value: value ?? "")
	}
}

enum TransformationAppEnum: String, AppEnum {
	case camelCase
	case pascalCase
	case snakeCase
	case constantCase
	case dashCase
	case transliterateLatinToArabic
	case transliterateLatinToCyrillic
	case transliterateLatinToGreek
	case transliterateLatinToHebrew
	case transliterateLatinToHangul
	case transliterateLatinToHiragana
	case transliterateLatinToThai
	case transliterateHiraganaToKatakana
	case transliterateMandarinToLatin
	case transliterateToLatin
	case stripDiacritics

	static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Transformation")

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.camelCase: "camelCase",
		.pascalCase: "PascalCase",
		.snakeCase: "snake_case",
		.constantCase: "CONSTANT_CASE",
		.dashCase: "dash-case",
		.transliterateLatinToArabic: "Transliterate Latin to Arabic",
		.transliterateLatinToCyrillic: "Transliterate Latin to Cyrillic",
		.transliterateLatinToGreek: "Transliterate Latin to Greek",
		.transliterateLatinToHebrew: "Transliterate Latin to Hebrew",
		.transliterateLatinToHangul: "Transliterate Latin to Hangul",
		.transliterateLatinToHiragana: "Transliterate Latin to Hiragana",
		.transliterateLatinToThai: "Transliterate Latin to Thai",
		.transliterateHiraganaToKatakana: "Transliterate Hiragana to Katakana",
		.transliterateMandarinToLatin: "Transliterate Mandarin to Latin",
		.transliterateToLatin: "Transliterate to Latin",
		.stripDiacritics: "Strip Diacritics"
	]
}
