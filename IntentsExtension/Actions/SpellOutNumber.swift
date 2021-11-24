import SwiftUI
import Intents

@MainActor
final class SpellOutNumberIntentHandler: NSObject, SpellOutNumberIntentHandling {
	func provideLocaleOptionsCollection(for intent: SpellOutNumberIntent) async throws -> INObjectCollection<Locale_> {
		let items = Locale.all
			.sorted(by: \.localizedName)
			.prepending(.posix)
			.map {
				Locale_(
					identifier: $0.identifier,
					display: $0.localizedName,
					subtitle: $0.identifier,
					image: nil
				)
			}

		return .init(items: items)
	}

	func handle(intent: SpellOutNumberIntent) async -> SpellOutNumberIntentResponse {
		let response = SpellOutNumberIntentResponse(code: .success, userActivity: nil)

		if let number = intent.number {
			let formatter = NumberFormatter()
			formatter.numberStyle = .spellOut
			formatter.formattingContext = .beginningOfSentence

			if let localeIdentifier = intent.locale?.identifier {
				formatter.locale = Locale(identifier: localeIdentifier)
			}

			response.result = formatter.string(from: number)
		}

		return response
	}
}
