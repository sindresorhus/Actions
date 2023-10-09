import AppIntents

struct GlobalVariableSetText: AppIntent {
	static let title: LocalizedStringResource = "Global Variable: Set Text"

	static let description = IntentDescription(
"""
Sets a global variable with the given text.

Tip: You can store a dictionary of string/boolean/number values by passing it in as a variable. To get the persisted dictionary back, pass the output of the “Global Variables: Get Text” action to the “Get Dictionary from Input” action.

Global variables persist across your shortcuts and devices, with a limit of 1000 variables and a total storage capacity of 1 MB. Avoid using this for large amounts of data. For large data, use iCloud Drive, Notes, or Data Jar.
""",
		categoryName: "Global Variable"
	)

	@Parameter(
		title: "Key",
		description: "Maximum 20 characters.",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var key: String

	@Parameter(title: "Value")
	var value: String

	static var parameterSummary: some ParameterSummary {
		Summary("Set global text variable \(\.$key) to \(\.$value)")
	}

	func perform() async throws -> some IntentResult {
		try setValue(key: key, value: value)
		return .result()
	}
}

struct GlobalVariableGetText: AppIntent {
	static let title: LocalizedStringResource = "Global Variable: Get Text"

	static let description = IntentDescription(
		"Returns the global variable with the given key if any.",
		categoryName: "Global Variable"
	)

	@Parameter(
		title: "Key",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		),
		optionsProvider: TextKeyOptionsProvider()
	)
	var key: String

	static var parameterSummary: some ParameterSummary {
		Summary("Get global text variable \(\.$key)")
	}

	// NOTE: We return an empty string as the action crashes if we return an optional string. (macOS 13.2)
	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		NSUbiquitousKeyValueStore.default.synchronize()

		let result = NSUbiquitousKeyValueStore.default.string(forKey: "\(keyPrefix)\(key)")

		return .result(value: result ?? "")
	}
}

struct GlobalVariableSetBoolean: AppIntent {
	static let title: LocalizedStringResource = "Global Variable: Set Boolean"

	static let description = IntentDescription(
"""
Sets a global variable with the given boolean.

You can also toggle a boolean.

Global variables persist across your shortcuts and devices, with a limit of 1000 variables and a total storage capacity of 1 MB. Avoid using this for large amounts of data. For large data, use iCloud Drive, Notes, or Data Jar.
""",
		categoryName: "Global Variable"
	)

	@Parameter(
		title: "Action",
		default: false,
		// TODO: macOS 14, use .init
		displayName: Bool.IntentDisplayName(true: "Toggle", false: "Set")
	)
	var shouldToggle: Bool

	@Parameter(
		title: "Key",
		description: "Maximum 20 characters.",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
		// NOTE: Having an options provider means the user cannot write into the parameter.
		// https://github.com/feedback-assistant/reports/issues/385
		// optionsProvider: BooleanKeyOptionsProvider()
	)
	var key: String

	@Parameter(title: "Value")
	var value: Bool

	static var parameterSummary: some ParameterSummary {
		When(\.$shouldToggle, .equalTo, true) {
			Summary("\(\.$shouldToggle) global boolean variable \(\.$key)")
		} otherwise: {
			Summary("\(\.$shouldToggle) global boolean variable \(\.$key) to \(\.$value)")
		}
	}

	func perform() async throws -> some IntentResult {
		if shouldToggle {
			let value = NSUbiquitousKeyValueStore.default.strictBool(forKey: "\(keyPrefix)\(key)") ?? false
			try setValue(key: key, value: !value)
		} else {
			try setValue(key: key, value: value)
		}

		return .result()
	}
}

struct GlobalVariableGetBoolean: AppIntent {
	static let title: LocalizedStringResource = "Global Variable: Get Boolean"

	static let description = IntentDescription(
		"Returns the global variable with the given key if any.",
		categoryName: "Global Variable"
	)

	@Parameter(
		title: "Key",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		),
		optionsProvider: BooleanKeyOptionsProvider()
	)
	var key: String

	static var parameterSummary: some ParameterSummary {
		Summary("Get global boolean variable \(\.$key)")
	}

	// NOTE: We return an array as the action crashes if we return an optional Bool. (macOS 13.2)
	func perform() async throws -> some IntentResult & ReturnsValue<[Bool]> {
		NSUbiquitousKeyValueStore.default.synchronize()

		guard
			let result = NSUbiquitousKeyValueStore.default.strictBool(forKey: "\(keyPrefix)\(key)")
		else {
			return .result(value: [])
		}

		return .result(value: [result])
	}
}

struct GlobalVariableSetNumber: AppIntent {
	static let title: LocalizedStringResource = "Global Variable: Set Number"

	static let description = IntentDescription(
"""
Sets a global variable with the given number.

You can also increment or decrement a number.

Global variables persist across your shortcuts and devices, with a limit of 1000 variables and a total storage capacity of 1 MB. Avoid using this for large amounts of data. For large data, use iCloud Drive, Notes, or Data Jar.
""",
		categoryName: "Global Variable"
	)

	@Parameter(
		title: "Action",
		default: .set
	)
	var action: GlobalVariableSetNumberAction_AppEnum

	@Parameter(
		title: "Key",
		description: "Maximum 20 characters.",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var key: String

	@Parameter(title: "Value")
	var value: Double

	static var parameterSummary: some ParameterSummary {
		Switch(\.$action) {
			Case(.increment) {
				Summary("\(\.$action) global number variable \(\.$key) by \(\.$value)")
			}
			Case(.decrement) {
				Summary("\(\.$action) global number variable \(\.$key) by \(\.$value)")
			}
			DefaultCase {
				Summary("\(\.$action) global number variable \(\.$key) to \(\.$value)")
			}
		}
	}

	func perform() async throws -> some IntentResult {
		lazy var number = NSUbiquitousKeyValueStore.default.strictNumber(forKey: "\(keyPrefix)\(key)") ?? 0

		switch action {
		case .set:
			try setValue(key: key, value: value)
		case .increment:
			try setValue(key: key, value: number + value)
		case .decrement:
			try setValue(key: key, value: number - value)
		}

		return .result()
	}
}

enum GlobalVariableSetNumberAction_AppEnum: String, AppEnum {
	case set
	case increment
	case decrement

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Global Variable Set Number Action"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.set: "Set",
		.increment: "Increment",
		.decrement: "Decrement"
	]
}

struct GlobalVariableGetNumber: AppIntent {
	static let title: LocalizedStringResource = "Global Variable: Get Number"

	static let description = IntentDescription(
		"Returns the global variable with the given key if any.",
		categoryName: "Global Variable"
	)

	@Parameter(
		title: "Key",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		),
		optionsProvider: NumberKeyOptionsProvider()
	)
	var key: String

	static var parameterSummary: some ParameterSummary {
		Summary("Get global number variable \(\.$key)")
	}

	// NOTE: We return an array as the action crashes if we return an optional Double. (macOS 13.2)
	func perform() async throws -> some IntentResult & ReturnsValue<[Double]> {
		NSUbiquitousKeyValueStore.default.synchronize()

		guard
			let result = NSUbiquitousKeyValueStore.default.strictNumber(forKey: "\(keyPrefix)\(key)")
		else {
			return .result(value: [])
		}

		return .result(value: [result])
	}
}

struct GlobalVariableDelete: AppIntent {
	static let title: LocalizedStringResource = "Global Variable: Delete"

	static let description = IntentDescription(
		"Delete global variables.",
		categoryName: "Global Variable"
	)

	@Parameter(
		title: "Delete All?",
		default: false,
		displayName: Bool.IntentDisplayName(true: "Delete all", false: "Delete")
	)
	var deleteAll: Bool

	@Parameter(
		title: "Variables",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		),
		optionsProvider: KeyOptionsProvider()
	)
	var keys: [String]

	static var parameterSummary: some ParameterSummary {
		When(\.$deleteAll, .equalTo, true) {
			Summary("\(\.$deleteAll) variables")
		} otherwise: {
			Summary("\(\.$deleteAll) \(\.$keys)")
		}
	}

	func perform() async throws -> some IntentResult {
		let finalKeys = deleteAll
			? NSUbiquitousKeyValueStore.default.allOwnKeys
			: keys.map { "\(keyPrefix)\($0)" }

		for key in finalKeys {
			NSUbiquitousKeyValueStore.default.removeObject(forKey: key)
		}

		return .result()
	}
}

struct GlobalVariableGetAll: AppIntent {
	static let title: LocalizedStringResource = "Global Variable: Get All"

	static let description = IntentDescription(
"""
Returns all the global variables as a dictionary.

Tip: Use the built-in “Get Dictionary Value” action to access all keys.
""",
		categoryName: "Global Variable"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Get all global variables")
	}

	// TODO: Open a FB about this if not available in macOS 14.
	// NOTE: We have to return a file as dictionary is not yet a valid return type.
	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		let keyValueTuples: [(String, Any)] = NSUbiquitousKeyValueStore.default.allOwnKeys.compactMap { key in
			guard let value = NSUbiquitousKeyValueStore.default.object(forKey: key) else {
				return nil
			}

			return (key.withoutKeyPrefix, value)
		}

		let file = try Dictionary(uniqueKeysWithValues: keyValueTuples)
			.toIntentFile(filename: "global-variables")

		return .result(value: file)
	}
}

private struct KeyOptionsProvider: DynamicOptionsProvider {
	func results() async throws -> [String] {
		NSUbiquitousKeyValueStore.default.allOwnKeys
			.map(\.withoutKeyPrefix)
	}
}

private struct TextKeyOptionsProvider: DynamicOptionsProvider {
	func results() async throws -> [String] {
		NSUbiquitousKeyValueStore.default.allOwnKeys
			.filter { NSUbiquitousKeyValueStore.default.object(forKey: $0) is String }
			.map(\.withoutKeyPrefix)
	}
}

private struct BooleanKeyOptionsProvider: DynamicOptionsProvider {
	func results() async throws -> [String] {
		NSUbiquitousKeyValueStore.default.allOwnKeys
			.filter { NSUbiquitousKeyValueStore.default.strictBool(forKey: $0) != nil }
			.map(\.withoutKeyPrefix)
	}
}

private struct NumberKeyOptionsProvider: DynamicOptionsProvider {
	func results() async throws -> [String] {
		NSUbiquitousKeyValueStore.default.allOwnKeys
			.filter { NSUbiquitousKeyValueStore.default.strictNumber(forKey: $0) != nil }
			.map(\.withoutKeyPrefix)
	}
}

private let keyPrefix = "GV_"

private func setValue(key: String, value: some Any) throws {
	try validateKey(key)
	NSUbiquitousKeyValueStore.default.synchronize()
	NSUbiquitousKeyValueStore.default.set(value, forKey: "\(keyPrefix)\(key)")
	NSUbiquitousKeyValueStore.default.synchronize()
}

private func validateKey(_ key: String) throws {
	// The maximum is 64 bytes, which means 32 ASCII characters, but it may contain Unicode too, so we play it safe.
	if key.count > 20 {
		throw "The key must be 20 characters or less.".toError
	}
}

extension NSUbiquitousKeyValueStore {
	fileprivate var allOwnKeys: [String] {
		dictionaryRepresentation.keys
			.filter { $0.hasPrefix(keyPrefix) }
	}
}

extension String {
	fileprivate var withoutKeyPrefix: Self {
		trimmingPrefix(keyPrefix).toString
	}
}
