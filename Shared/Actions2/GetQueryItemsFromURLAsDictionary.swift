import AppIntents

struct GetQueryItemsFromURLAsDictionary: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GetQueryItemsFromURLAsDictionaryIntent"

	static let title: LocalizedStringResource = "Get Query Items from URL as Dictionary"

	static let description = IntentDescription(
"""
Returns all query items from the input URL as a dictionary.

This makes it convenient to get specific items.

Limitation: URLs support having multiple query items with the same name, but dictionaries cannot have duplicate keys.

Tip: You could, for example, use this action together with the built-in “Get Dictionary Value” action.
""",
		categoryName: "URL"
	)

	@Parameter(title: "URL")
	var url: URL

	static var parameterSummary: some ParameterSummary {
		Summary("Get query items from \(\.$url) as a dictionary")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		.result(value: try url.queryDictionary.toIntentFile())
	}
}
