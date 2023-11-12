import AppIntents
import SwiftUI

struct WriteTextIntent: AppIntent {
	static let title: LocalizedStringResource = "Write or Edit Text"

	static let description = IntentDescription(
		"""
		Opens a text editor where you can write or edit text.

		IMPORTANT: The result is copied to the clipboard. Add the “Wait to Return” and “Get Clipboard” actions after this one.
		""",
		categoryName: "Utility"
	)

	static let openAppWhenRun = true

	@Parameter(
		title: "Text",
		inputOptions: .init(keyboardType: .default)
	)
	var text: String?

	@Parameter(
		title: "Edit",
		default: false,
		displayName: Bool.IntentDisplayName(true: "Edit", false: "Write")
	)
	var shouldEdit: Bool

	@Parameter(
		title: "Editor Title",
		inputOptions: String.IntentInputOptions(
			keyboardType: .default,
			capitalizationType: .words
		)
	)
	var editorTitle: String?

	static var parameterSummary: some ParameterSummary {
		When(\.$shouldEdit, .equalTo, true) {
			Summary("\(\.$shouldEdit) \(\.$text)") {
				\.$editorTitle
			}
		} otherwise: {
			Summary("\(\.$shouldEdit) text") {
				\.$editorTitle
			}
		}
	}

	@MainActor
	func perform() async throws -> some IntentResult {
		// Work around issue with it not showing. (iOS 17.1)
		try await Task.sleep(for: .seconds(0.1))

		AppState.shared.writeTextData = .init(
			title: editorTitle,
			text: shouldEdit ? (text?.nilIfEmptyOrWhitespace ?? "") : ""
		)

		return .result()
	}
}
