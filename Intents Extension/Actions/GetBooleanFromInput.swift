import AppIntents

struct GetBooleanFromInput: AppIntent {
	static let title: LocalizedStringResource = "Get Boolean from Input"

	static let description = IntentDescription(
		"""
		Converts boolean-like text values (for example, “true”, “no”, “1”) into their corresponding boolean representation.

		If no boolean could be detected, it returns an empty result.

		This can be useful when an action expects a proper boolean type and you only have some boolean-like text value.
		""",
		categoryName: "Parse / Generate",
		resultValueName: "Boolean"
	)

	@Parameter(
		title: "Boolean-like Text",
		description: "Accepts the following text values with any casing: true, false, yes, no, 1, 0"
	)
	var booleanString: String

	static var parameterSummary: some ParameterSummary {
		Summary("Get boolean from \(\.$booleanString)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool?> { // swiftlint:disable:this discouraged_optional_boolean
		// We return optional boolean as Shortcuts does not have a way to catch errors.
		// swiftlint:disable:next discouraged_optional_boolean
		let result: Bool? = switch booleanString.trimmed.lowercased() {
		case "true", "yes", "1":
			true
		case "false", "no", "0":
			false
		default:
			nil
		}

		return .result(value: result)
	}
}
