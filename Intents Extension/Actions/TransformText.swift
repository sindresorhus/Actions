import AppIntents

struct TransformTextIntent: AppIntent {
	static let title: LocalizedStringResource = "Transform Text"

	static let description = IntentDescription(
		"Transforms the input text to camel case, pascal case, snake case, constant case, or dash case. It also has transliteration transformations.",
		categoryName: "Text",
		searchKeywords: [
			"camelcase",
			"pascalcase",
			"snakecase",
			"constantcase",
			"dashcase",
			"case",
			"camel",
			"pascal",
			"snake",
			"constant",
			"dash",
			"slugify",
			"slug",
			"transliterate",
			"latin",
			"ascii",
			"diacritic"
		],
		resultValueName: "Transformed Text"
	)

	@Parameter(title: "Text")
	var text: String

	@Parameter(title: "Transformation")
	var transformation: TransformationAppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Transform \(\.$text) using \(\.$transformation)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String?> {
		let value: String? = switch transformation {
			case .camelCase:
				text.camelCasing()
			case .pascalCase:
				text.pascalCasing()
			case .snakeCase:
				text.snakeCasing()
			case .constantCase:
				text.constantCasing()
			case .dashCase:
				text.dashCasing()
			case .slugify:
				text.slugified()
			case .stripPunctation:
				text.replacing(/\p{Punct}/, with: "")
			case .stripDiacritics:
				text.applyingTransform(.stripDiacritics, reverse: false)
			case .transliterateToLatin:
				text.applyingTransform(.toLatin, reverse: false)
			case .transliterateLatinToArabic:
				text.applyingTransform(.latinToArabic, reverse: false)
			case .transliterateLatinToCyrillic:
				text.applyingTransform(.latinToCyrillic, reverse: false)
			case .transliterateLatinToGreek:
				text.applyingTransform(.latinToGreek, reverse: false)
			case .transliterateLatinToHebrew:
				text.applyingTransform(.latinToHebrew, reverse: false)
			case .transliterateLatinToHangul:
				text.applyingTransform(.latinToHangul, reverse: false)
			case .transliterateLatinToHiragana:
				text.applyingTransform(.latinToHiragana, reverse: false)
			case .transliterateLatinToThai:
				text.applyingTransform(.latinToThai, reverse: false)
			case .transliterateHiraganaToKatakana:
				text.applyingTransform(.hiraganaToKatakana, reverse: false)
			case .transliterateMandarinToLatin:
				text.applyingTransform(.mandarinToLatin, reverse: false)
			}

		// TODO: Should it throw if nil?

		return .result(value: value)
	}
}

enum TransformationAppEnum: String, AppEnum {
	case camelCase
	case pascalCase
	case snakeCase
	case constantCase
	case dashCase
	case slugify
	case stripPunctation
	case stripDiacritics
	case transliterateToLatin
	case transliterateLatinToArabic
	case transliterateLatinToCyrillic
	case transliterateLatinToGreek
	case transliterateLatinToHebrew
	case transliterateLatinToHangul
	case transliterateLatinToHiragana
	case transliterateLatinToThai
	case transliterateHiraganaToKatakana
	case transliterateMandarinToLatin

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Transformation"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.camelCase: "camelCase",
		.pascalCase: "PascalCase",
		.snakeCase: "snake_case",
		.constantCase: "CONSTANT_CASE",
		.dashCase: "dash-case",
		.slugify: .init(
			title: "Slugify",
			subtitle: "“Sø’r āē 拼!” → “sor-ae-pin”"
		),
		.stripPunctation: .init(
			title: "Strip Punctation",
			subtitle: "“I’m hungry!” → “Im hungry”"
		),
		.stripDiacritics: "Strip Diacritics",
		.transliterateToLatin: "Transliterate to Latin",
		.transliterateLatinToArabic: "Transliterate Latin to Arabic",
		.transliterateLatinToCyrillic: "Transliterate Latin to Cyrillic",
		.transliterateLatinToGreek: "Transliterate Latin to Greek",
		.transliterateLatinToHebrew: "Transliterate Latin to Hebrew",
		.transliterateLatinToHangul: "Transliterate Latin to Hangul",
		.transliterateLatinToHiragana: "Transliterate Latin to Hiragana",
		.transliterateLatinToThai: "Transliterate Latin to Thai",
		.transliterateHiraganaToKatakana: "Transliterate Hiragana to Katakana",
		.transliterateMandarinToLatin: "Transliterate Mandarin to Latin"
	]
}
