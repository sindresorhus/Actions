import AppIntents

struct RemoveNonPrintableCharacters: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "RemoveNonPrintableCharactersIntent"

	static let title: LocalizedStringResource = "Remove Non-Printable Characters"

	static let description = IntentDescription(
"""
Removes non-printable (invisible) Unicode characters from the input text, excluding normal whitespace characters.

This can be useful to clean up input text which might contain things like left-to-right embedding, control characters, etc.
""",
		categoryName: "Text"
	)

	@Parameter(title: "Text")
	var text: String

	static var parameterSummary: some ParameterSummary {
		Summary("Remove non-printable characters in \(\.$text)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		.result(value: text.removingCharactersWithoutDisplayWidth())
	}
}
