import AppIntents

struct RemoveDuplicateLinesIntent: AppIntent {
	static let title: LocalizedStringResource = "Remove Duplicate Lines"

	static let description = IntentDescription(
		"Removes duplicate lines from the input text. Empty or whitespace-only lines are not considered duplicates.",
		categoryName: "Text",
		resultValueName: "Text with Deduplicated Lines"
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
