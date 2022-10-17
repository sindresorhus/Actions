import AppIntents

struct ParseJSON5: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "ParseJSON5Intent"

	static let title: LocalizedStringResource = "Parse JSON5"

	static let description = IntentDescription(
"""
Parses JSON5 into a dictionary.

JSON5 is a more human-friendly version of JSON. It can handle comments, single-quotes, and more.

The built-in "Get Dictionary from Input" action does not support JSON5.
""",
		categoryName: "Parse / Generate"
	)

	@Parameter(
		title: "JSON5",
		description: "Accepts a file or text. Tap the parameter to select a file. Tap and hold to select a variable to some text.",
		supportedTypeIdentifiers: ["public.data"]
	)
	var file: IntentFile

	static var parameterSummary: some ParameterSummary {
		Summary("Parse \(\.$file) into a dictionary")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		let json = try JSONSerialization.jsonObject(with: file.data, options: .json5Allowed)

		// TODO: Without this check, the Shortcuts app crashes on top-level array. (macOS 12.2)
		guard json is NSDictionary else {
			throw "The JSON has to be an object. The Shortcuts app cannot currently handle a top-level array.".toError
		}

		let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
		let result = data.toIntentFile(contentType: .json, filename: file.filenameWithoutExtension)

		return .result(value: result)
	}
}
