import AppIntents

struct Boolean: AppIntent {
	static let title: LocalizedStringResource = "Boolean"

	static let description = IntentDescription(
		"""
		Passes the specified boolean value to the next action.

		Similar to the built-in “Number” and “Text” actions.

		This can be useful if you want to create a variable that is initially set to a boolean.
		""",
		categoryName: "Parse / Generate"
	)

	@Parameter(
		title: "Boolean",
		displayName: Bool.IntentDisplayName(true: "true", false: "false")
	)
	var boolean: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("\(\.$boolean)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: boolean)
	}
}
