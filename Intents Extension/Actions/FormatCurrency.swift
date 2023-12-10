import AppIntents

struct FormatCurrencyIntent: AppIntent {
	static let title: LocalizedStringResource = "Format Currency"

	static let description = IntentDescription(
		"Formats the input amount as currency.",
		categoryName: "Formatting",
		resultValueName: "Formatted Currency"
	)

	// We are intentionally not using `IntentCurrencyAmount` as it has bad UX and also doesn't allow not specifying a currency.
	@Parameter(title: "Amount")
	var amount: Double

	@Parameter(title: "Currency", description: "Uses the currency of the system locale if not specified.")
	var currency: CurrencyAppEntity?

	static var parameterSummary: some ParameterSummary {
		Summary("Format \(\.$amount) as currency") {
			\.$currency
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		let currencyCode = currency?.id ?? Locale.current.currency?.identifier ?? "USD"
		let result = amount.formatted(.currency(code: currencyCode))
		return .result(value: result)
	}
}

struct CurrencyAppEntity: AppEntity {
	struct CurrencyEntityQuery: EntityQuery {
		private func allEntities() -> [CurrencyAppEntity] {
			Locale.currencyWithLocalizedNameAndRegionName.map { currency, localizedCurrencyName, localizedRegionName in
				.init(
					id: currency.identifier,
					localizedCurrencyName: localizedCurrencyName,
					localizedRegionName: localizedRegionName
				)
			}
		}

		func entities(for identifiers: [CurrencyAppEntity.ID]) async throws -> [CurrencyAppEntity] {
			allEntities().filter { identifiers.contains($0.id) }
		}

		func suggestedEntities() async throws -> [CurrencyAppEntity] {
			allEntities()
		}
	}

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Currency"

	static let defaultQuery = CurrencyEntityQuery()

	let id: String

	private let localizedCurrencyName: String
	private let localizedRegionName: String

	init(id: String, localizedCurrencyName: String, localizedRegionName: String) {
		self.id = id
		self.localizedCurrencyName = localizedCurrencyName
		self.localizedRegionName = localizedRegionName
	}

	var displayRepresentation: DisplayRepresentation {
		// TODO: Use SF Symbols to add an icon for available currencies.
		.init(
			title: "\(id) — \(localizedCurrencyName)",
			subtitle: "\(localizedRegionName)"
		)
	}
}
