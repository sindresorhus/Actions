import AppIntents

struct AskForText: AppIntent {
	static let title: LocalizedStringResource = "Ask for Text with Timeout"

	static let description = IntentDescription(
"""
Displays a dialog prompting the user to enter some text.

If you provide a timeout, the action will cancel after the given timeout as long as the user has not started writing anything.

IMPORTANT: The result is copied to the clipboard. Add the “Wait to Return” and “Get Clipboard” actions after this one.
""",
		categoryName: "Utility"
	)

	static let openAppWhenRun = true

	@Parameter(title: "Prompt")
	var prompt: String

	@Parameter(title: "Message")
	var message: String?

	@Parameter(
		title: "Default Answer",
		description: "Prefill the text field. This can be a good way to let the user edit some existing text.",
		default: ""
	)
	var defaultAnswer: String

	@Parameter(
		title: "Timeout",
		defaultUnit: .seconds,
		supportsNegativeNumbers: false
	)
	var timeout: Measurement<UnitDuration>?

	@Parameter(
		title: "Return Value on Timeout",
		description: "The text to return if the action times out.",
		default: ""
	)
	var timeoutReturnValue: String

	@Parameter(title: "Show Cancel Button", default: true)
	var showCancelButton: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("Ask for text with \(\.$prompt)") {
			\.$message
			\.$defaultAnswer
			\.$timeout
			\.$timeoutReturnValue
			\.$showCancelButton
		}
	}

	@MainActor
	func perform() async throws -> some IntentResult {
		AppState.shared.isFullscreenOverlayPresented = true

		AppState.shared.askForTextData = .init(
			text: defaultAnswer,
			title: prompt,
			message: message,
			timeout: timeout?.converted(to: .seconds).value.nilIfZero,
			timeoutReturnValue: timeoutReturnValue,
			showCancelButton: showCancelButton
		)

		return .result()
	}
}

// TODO: Remove me when it's support it natively.
extension UnitDuration: @unchecked Sendable {}
