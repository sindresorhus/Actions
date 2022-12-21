#if canImport(AppKit)
import AppIntents

@available(iOS, unavailable)
struct SetDefaultPrinter: AppIntent {
	static let title: LocalizedStringResource = "Set Default Printer (macOS-only)"

	static let description = IntentDescription(
		"Sets the default printer.",
		categoryName: "Device",
		searchKeywords: [
			"printers",
			"print"
		]
	)

	@Parameter(title: "Printer")
	var printer: PrinterAppEntity

	static var parameterSummary: some ParameterSummary {
		Summary("Set \(\.$printer) as default printer")
	}

	func perform() async throws -> some IntentResult {
		Printer
			.all()
			.first { $0.id == printer.id }?
			.setAsDefault()

		return .result()
	}
}
#endif
