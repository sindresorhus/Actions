import Foundation
import NaturalLanguage
import Intents

@MainActor
final class GetRelatedWordsIntentHandler: NSObject, GetRelatedWordsIntentHandling {
	func provideLanguageOptionsCollection(for intent: GetRelatedWordsIntent) async throws -> INObjectCollection<NLLanguage_> {
		let items: [NLLanguage_] = NLEmbedding.supportedLanguage.map {
			let language = NLLanguage_(identifier: $0.rawValue, display: $0.localizedName)

			if $0 == .english {
				language.subtitleString = "(Default)"
			}

			return language
		}

		return .init(items: items)
	}

	func handle(intent: GetRelatedWordsIntent) async -> GetRelatedWordsIntentResponse {
		let response = GetRelatedWordsIntentResponse(code: .success, userActivity: nil)

		guard let word = intent.word else {
			return response
		}

		// It seems to never return more than 50 items.
		let maximumCount = intent.maximumCount as? Int ?? 50

		let language = intent.language?.identifier.map { NLLanguage($0) } ?? .english

		response.result = NLEmbedding
			.wordEmbedding(for: language)?
			.neighbors(for: word, maximumCount: maximumCount)
			.map(\.0)

		return response
	}
}
