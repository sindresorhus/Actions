#if os(macOS)
import AppIntents

// NOTE: This has to be an in-app intent as extensions seem to not inherit the print entitlement. (macOS 13.1)

@available(iOS, unavailable)
struct GetPrinters: AppIntent, DeprecatedAppIntent {
	static let title: LocalizedStringResource = "Get Printers (macOS-only)"

	static let description = IntentDescription(
		"""
		Returns the available printers.

		Use the built-in “Show Result” action to inspect the individual properties.
		""",
		categoryName: "Device",
		searchKeywords: [
			"printer",
			"print"
		]
	)

	static var deprecation = IntentDeprecation(message: "Deprecated. Replaced by the “Find Printer” action.")

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

@available(iOS, unavailable)
struct PrinterAppEntityQuery: EnumerableEntityQuery {
	static let findIntentDescription = IntentDescription(
		"""
		Returns the available printers.

		Use the built-in “Show Result” action to inspect the individual properties.
		""",
		categoryName: "Device",
		searchKeywords: [
			"printer",
			"print"
		]
	)

	func allEntities() -> [PrinterAppEntity] {
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

@available(iOS, unavailable)
struct PrinterAppEntity: AppEntity {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Printer"

	static let defaultQuery = PrinterAppEntityQuery()

	@Property(title: "Name")
	var name: String

	@Property(title: "Identifier")
	var id: String

	@Property(title: "State\u{200B}") // We include a zero-width character to prevent the Shortcuts app from translating it to "County".
	var state: State

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
		self.name = printer.name ?? "<Unknown>"
		self.id = printer.id
		self.state = .init(printer.state)
		self.isDefault = printer.isDefault
		self.isRemote = printer.isRemote
		self.location = printer.location
		self.makeAndModel = printer.makeAndModel
		self.deviceURL = printer.deviceURL
	}

	var displayRepresentation: DisplayRepresentation {
		.init(
			title: "\(name)",
			subtitle: isDefault ? "\(state.localizedStringResource), Default" : "\(state.localizedStringResource)"
		)
	}
}

extension PrinterAppEntity {
	enum State: String, AppEnum {
		case idle
		case processing
		case stopped

		static let typeDisplayRepresentation: TypeDisplayRepresentation = "Printer State"

		static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
			.idle: "Idle",
			.processing: "Processing",
			.stopped: "Stopped"
		]
	}
}

extension PrinterAppEntity.State {
	init(_ native: Printer.State) {
		switch native {
		case .idle:
			self = .idle
		case .processing:
			self = .processing
		case .stopped:
			self = .stopped
		}
	}
}
#endif
