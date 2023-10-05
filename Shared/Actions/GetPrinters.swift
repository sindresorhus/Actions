#if os(macOS)
import AppIntents

// NOTE: This has to be an in-app intent as extensions seem to not inherit the print entitlement. (macOS 13.1)

@available(iOS, unavailable)
struct GetPrinters: AppIntent {
	static let title: LocalizedStringResource = "Get Printers (macOS-only)"

	static let description = IntentDescription(
"""
Returns the available printers.

Use the built-in "Show Result" action to inspect the individual properties.
""",
		categoryName: "Device",
		searchKeywords: [
			"printer",
			"print"
		]
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Get printers")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[PrinterAppEntity]> {
		let result = Printer
			.all()
			.map(PrinterAppEntity.init)

		return .result(value: result)
	}
}

struct PrinterAppEntityQuery: EntityQuery {
	private func allEntities() -> [PrinterAppEntity] {
		Printer
			.all()
			.map(PrinterAppEntity.init)
	}

	func entities(for identifiers: [PrinterAppEntity.ID]) async throws -> [PrinterAppEntity] {
		allEntities().filter { identifiers.contains($0.id) }
	}

	func suggestedEntities() async throws -> [PrinterAppEntity] {
		allEntities()
	}
}

struct PrinterAppEntity: AppEntity {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Printer"

	static let defaultQuery = PrinterAppEntityQuery()

	private let name: String
	private let state: String

	let id: String

	@Property(title: "Identifier")
	var identifier: String

	@Property(title: "Is Default")
	var isDefault: Bool

	@Property(title: "Is Remote")
	var isRemote: Bool

	@Property(title: "Location")
	var location: String?

	@Property(title: "Make & Model")
	var makeAndModel: String?

	@Property(title: "Device URL")
	var deviceURL: URL?

	init(_ printer: Printer) {
		self.id = printer.id
		self.name = printer.name ?? "<Unknown>"
		self.state = printer.state.title
		self.identifier = printer.id
		self.isDefault = printer.isDefault
		self.isRemote = printer.isRemote
		self.location = printer.location
		self.makeAndModel = printer.makeAndModel
		self.deviceURL = printer.deviceURL
	}

	var displayRepresentation: DisplayRepresentation {
		.init(
			title: "\(name)",
			subtitle: isDefault ? "\(state), Default" : "\(state)"
		)
	}
}
#endif
