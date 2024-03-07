import AppIntents
import NaturalLanguage

struct GetSentencesFromTextIntent: AppIntent {
	static let title: LocalizedStringResource = "Get Sentences from Text"

	static let description = IntentDescription(
		"""
		Returns the text split into sentences.

		Related action: Get Paragraphs from Text
		""",
		categoryName: "Text",
		searchKeywords: [
			"segmentation",
			"segmenter",
			"tokenize",
			"tokenizer"
		],
		resultValueName: "Sentences"
	)

	@Parameter(title: "Text")
	var text: String

	@Parameter(
		title: "Language",
		description: "Defaults to the system language."
	)
	var language: NLLanguageAppEntity?

	static var parameterSummary: some ParameterSummary {
		Summary("Get sentences from \(\.$text)") {
			\.$language
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[String]> {
		let result = text.segments(.sentence, language: language?.toNative)
		return .result(value: result)
	}
}
