import AppIntents
import NaturalLanguage

struct GetParagraphsFromTextIntent: AppIntent {
	static let title: LocalizedStringResource = "Get Paragraphs from Text"

	static let description = IntentDescription(
		"""
		Returns the text split into paragraphs.

		Related action: Get Sentences from Text
		""",
		categoryName: "Text",
		searchKeywords: [
			"segmentation",
			"segmenter",
			"tokenize",
			"tokenizer"
		],
		resultValueName: "Paragraphs"
	)

	@Parameter(title: "Text", inputOptions: .init(multiline: true))
	var text: String

	@Parameter(
		title: "Language",
		description: "Defaults to the system language."
	)
	var language: NLLanguageAppEntity?

	static var parameterSummary: some ParameterSummary {
		Summary("Get paragraphs from \(\.$text)") {
			\.$language
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[String]> {
		let result = text.segments(.paragraph, language: language?.toNative)
		return .result(value: result)
	}
}
