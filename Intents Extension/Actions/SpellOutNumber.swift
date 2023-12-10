import AppIntents

struct SpellOutNumberIntent: AppIntent {
	static let title: LocalizedStringResource = "Spell Out Number"

	static let description = IntentDescription(
		"""
		Spells out the input number.

		For example, 1000 becomes “one thousand”.

		If a locale is not specified, the system locale is used.
		""",
		categoryName: "Formatting",
		resultValueName: "Spelled Out Number"
	)

	@Parameter(title: "Number")
	var number: Int

	@Parameter(title: "Locale")
	var locale: LocaleAppEntity?

	static var parameterSummary: some ParameterSummary {
		Summary("Spell out \(\.$number)") {
			\.$locale
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String?> {
		let formatter = NumberFormatter()
		formatter.numberStyle = .spellOut

		if let localeIdentifier = locale?.id {
			formatter.locale = Locale(identifier: localeIdentifier)
		}

		let result = formatter.string(from: number as NSNumber)

		return .result(value: result)
	}
}

struct LocaleAppEntity: AppEntity {
	struct LocaleAppEntityQuery: EntityQuery {
		private func allEntities() -> [LocaleAppEntity] {
			Locale.all
				.sorted(by: \.localizedName)
				.prepending(.posix)
				.map(LocaleAppEntity.init)
		}

		func entities(for identifiers: [LocaleAppEntity.ID]) async throws -> [LocaleAppEntity] {
			allEntities().filter { identifiers.contains($0.id) }
		}

		func suggestedEntities() async throws -> [LocaleAppEntity] {
			allEntities()
		}
	}

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Locale"

	static let defaultQuery = LocaleAppEntityQuery()

	private let localizedName: String

	let id: String

	init(_ locale: Locale) {
		self.id = locale.identifier
		self.localizedName = locale.localizedName
	}

	var displayRepresentation: DisplayRepresentation {
		.init(title: "\(localizedName)")
	}
}
