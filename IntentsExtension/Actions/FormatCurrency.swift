import Foundation
import Intents

@MainActor
final class FormatCurrencyIntentHandler: NSObject, FormatCurrencyIntentHandling {
	func provideCurrencyOptionsCollection(for intent: FormatCurrencyIntent) async throws -> INObjectCollection<Currency_> {
		let items = Locale.currencyCodesWithLocalizedNameAndRegionName.map { currencyCode, localizedCurrencyName, localizedRegionName in
			let currency = Currency_(
				identifier: currencyCode,
				display: "\(currencyCode) — \(localizedCurrencyName)",
				subtitle: localizedRegionName,
				image: nil
			)
			currency.code = currencyCode
			return currency
		}

		return .init(items: items)
	}

	func handle(intent: FormatCurrencyIntent) async -> FormatCurrencyIntentResponse {
		let response = FormatCurrencyIntentResponse(code: .success, userActivity: nil)

		let currencyCode = intent.currency?.code ?? Locale.current.currencyCode ?? "USD"

		if let amount = intent.amount as? Double {
			let currency = amount.formatted(.currency(code: currencyCode))
			response.result = currency
		}

		return response
	}
}
