import AppIntents

struct GetBooleanFromInput: AppIntent {
	static let title: LocalizedStringResource = "Get Boolean from Input"

	static let description = IntentDescription(
"""
Converts boolean-like text values (for example, “true”, “no”, “1”) into their corresponding boolean representation.

This can be useful when an action expects a proper boolean type and you only have some boolean-like text value.
""",
		categoryName: "Parse / Generate"
	)

	@Parameter(
		title: "Boolean-like Text",
		description: "Accepts the following text values with any casing: true, false, yes, no, 1, 0"
	)
	var booleanString: String

	static var parameterSummary: some ParameterSummary {
		Summary("Get boolean from \(\.$booleanString)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		switch booleanString.trimmed.lowercased() {
		case "true", "yes", "1":
			return .result(value: true)
		case "false", "no", "0":
			return .result(value: false)
		default:
			throw "Could not detect a boolean value.".toError
		}
	}
}
