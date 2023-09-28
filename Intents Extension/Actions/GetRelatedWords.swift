import AppIntents
import NaturalLanguage

struct GetRelatedWords: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GetRelatedWordsIntent"

	static let title: LocalizedStringResource = "Get Related Words"

	static let description = IntentDescription(
"""
Returns words related to the input word.

For example, given the word “horse”, it would return stallion, racehorse, pony, etc.
""",
		categoryName: "Text"
	)

	@Parameter(
		title: "Word",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var word: String

	// TODO: We have to set a default, otherwise it's `0`. (iOS 16.0)
	// It seems to never return more than 50 items.
	@Parameter(title: "Maximum Count", default: 50, inclusiveRange: (0, 50))
	var maximumCount: Int

	@Parameter(title: "Language")
	var language: NLLanguageAppEntity?

	static var parameterSummary: some ParameterSummary {
		Summary("Get words related to \(\.$word)") {
			\.$maximumCount
			\.$language
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[String]> {
		let nlLanguage = language.flatMap { NLLanguage($0.id) } ?? .english

		let result = NLEmbedding
			.wordEmbedding(for: nlLanguage)?
			.neighbors(for: word.lowercased(), maximumCount: maximumCount)
			.map(\.0)
				?? []

		return .result(value: result)
	}
}

struct NLLanguageAppEntity: AppEntity {
	struct NLLanguageEntityQuery: EntityQuery {
		private func allEntities() -> [NLLanguageAppEntity] {
			NLEmbedding.supportedLanguage.map(NLLanguageAppEntity.init)
		}

		func entities(for identifiers: [NLLanguageAppEntity.ID]) async throws -> [NLLanguageAppEntity] {
			allEntities().filter { identifiers.contains($0.id) }
		}

		func suggestedEntities() async throws -> [NLLanguageAppEntity] {
			allEntities()
		}
	}

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Language"

	static let defaultQuery = NLLanguageEntityQuery()

	private let isDefault: Bool

	let id: String
	let localizedName: String

	init(_ nlLanguage: NLLanguage) {
		self.id = nlLanguage.rawValue
		self.localizedName = nlLanguage.localizedName
		self.isDefault = nlLanguage == .english
	}

	var displayRepresentation: DisplayRepresentation {
		.init(
			title: "\(localizedName)",
			subtitle: isDefault ? "(Default)" : nil
		)
	}
}
