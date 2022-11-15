import AppIntents

struct MergeDictionaries: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "MergeDictionariesIntent"

	static let title: LocalizedStringResource = "Merge Dictionaries"

	static let description = IntentDescription(
"""
Merges two or more dictionaries into one dictionary.

Supports up to 10 dictionaries.

It does shallow merging.

Tap and hold a dictionary parameter to select a variable to a dictionary. Don't quick tap it.

In Shortcuts, dictionaries are just JSON, so you can use this to merge JSON (file or text) too.
""",
		categoryName: "Dictionary"
	)

	@Parameter(title: "Dictionary 1", supportedTypeIdentifiers: ["public.item"])
	var dictionary1: IntentFile

	@Parameter(title: "Dictionary 2", supportedTypeIdentifiers: ["public.item"])
	var dictionary2: IntentFile?

	@Parameter(title: "Dictionary 3", supportedTypeIdentifiers: ["public.item"])
	var dictionary3: IntentFile?

	@Parameter(title: "Dictionary 4", supportedTypeIdentifiers: ["public.item"])
	var dictionary4: IntentFile?

	@Parameter(title: "Dictionary 5", supportedTypeIdentifiers: ["public.item"])
	var dictionary5: IntentFile?

	@Parameter(title: "Dictionary 6", supportedTypeIdentifiers: ["public.item"])
	var dictionary6: IntentFile?

	@Parameter(title: "Dictionary 7", supportedTypeIdentifiers: ["public.item"])
	var dictionary7: IntentFile?

	@Parameter(title: "Dictionary 8", supportedTypeIdentifiers: ["public.item"])
	var dictionary8: IntentFile?

	@Parameter(title: "Dictionary 9", supportedTypeIdentifiers: ["public.item"])
	var dictionary9: IntentFile?

	@Parameter(title: "Dictionary 10", supportedTypeIdentifiers: ["public.item"])
	var dictionary10: IntentFile?

	static var parameterSummary: some ParameterSummary {
		Summary("Merge into \(\.$dictionary1) from \(\.$dictionary2) \(\.$dictionary3) \(\.$dictionary4) \(\.$dictionary5) \(\.$dictionary6) \(\.$dictionary7) \(\.$dictionary8) \(\.$dictionary9) \(\.$dictionary10)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		// Note to self: We manually define each dictionary parameter in the Intents definition as using "Supports multiple values" on a single parameter does not show multiple inputs in the UI. (macOS 12.2)

		// Note: This is not in the intents extension as when it's there `dictionary1.data` always empty for some weird reason. (macOS 13.0)

		let filename = dictionary1.filename

		let dictionary1 = try dictionary1.data.jsonToDictionary()
		let dictionary2 = try dictionary2?.data.jsonToDictionary() ?? [:]
		let dictionary3 = try dictionary3?.data.jsonToDictionary() ?? [:]
		let dictionary4 = try dictionary4?.data.jsonToDictionary() ?? [:]
		let dictionary5 = try dictionary5?.data.jsonToDictionary() ?? [:]
		let dictionary6 = try dictionary6?.data.jsonToDictionary() ?? [:]
		let dictionary7 = try dictionary7?.data.jsonToDictionary() ?? [:]
		let dictionary8 = try dictionary8?.data.jsonToDictionary() ?? [:]
		let dictionary9 = try dictionary9?.data.jsonToDictionary() ?? [:]
		let dictionary10 = try dictionary10?.data.jsonToDictionary() ?? [:]

		let finalDictionary = dictionary1
			+ dictionary2
			+ dictionary3
			+ dictionary4
			+ dictionary5
			+ dictionary6
			+ dictionary7
			+ dictionary8
			+ dictionary9
			+ dictionary10

		let result = try finalDictionary.toIntentFile(filename: filename)

		return .result(value: result)
	}
}
