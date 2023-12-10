import AppIntents
import JavaScriptCore

struct TransformTextWithJavaScriptIntent: AppIntent {
	static let title: LocalizedStringResource = "Transform Text with JavaScript"

	static let description = IntentDescription(
		"""
		Transforms the input text with the given JavaScript code.

		The input text is available in a global variable named “$text”.

		The code is excuted with JavaScriptCore (same as used in Safari), not JXA.
		""",
		categoryName: "Text",
		resultValueName: "Transformed Text"
	)

	@Parameter(
		title: "Text",
		inputOptions: String.IntentInputOptions(multiline: true)
	)
	var text: String

	@Parameter(
		title: "JavaScript Code",
		description: "You are expected to return a string. The code must be synchronous.",
		default: "return $text.toLowerCase();",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			multiline: true,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var javaScriptCode: String

	static var parameterSummary: some ParameterSummary {
		Summary("Transform \(\.$text) with \(\.$javaScriptCode)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		guard let jsContext = JSContext() else {
			throw "Failed to initialize JavaScript engine.".toError
		}

		jsContext.setObject(text as NSString, forKeyedSubscript: "$text" as NSString)

		let script = "(() => {\n\(javaScriptCode)\n})()"

		guard let result = jsContext.evaluateScript(script)?.toString() else {
			throw "Failed to evaluate JavaScript code.".toError
		}

		if let exception = jsContext.exception?.toString() {
			throw exception.toError
		}

		return .result(value: result)
	}
}
