import AppIntents

struct RemoveDuplicateLines: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "RemoveDuplicateLinesIntent"

	static let title: LocalizedStringResource = "Remove Duplicate Lines"

	static let description = IntentDescription(
		"Removes duplicate lines from the input text. Empty or whitespace-only lines are not considered duplicates.",
		categoryName: "Text"
	)

	@Parameter(title: "Text")
	var text: String

	@Parameter(title: "Case Insensitive", default: false)
	var caseInsensitive: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("Remove duplicate lines from \(\.$text)") {
			\.$caseInsensitive
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		.result(value: text.localizedRemovingDuplicateLines(caseInsensitive: caseInsensitive))
	}
}
