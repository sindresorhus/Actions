import AppIntents
import SwiftUI

struct WriteText: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "WriteTextIntent"

	static let title: LocalizedStringResource = "Write or Edit Text"

	static let description = IntentDescription(
"""
Opens a text editor where you can write or edit text.

The result is copied to the clipboard. Add the “Wait to Return” and “Get Clipboard” actions after this one.
""",
		categoryName: "Utility"
	)

	static let openAppWhenRun = true

	@Parameter(title: "Text")
	var text: String?

	@Parameter(
		title: "Edit",
		default: false,
		displayName: .init(true: "Edit", false: "Write")
	)
	var shouldEdit: Bool

	@Parameter(
		title: "Editor Title",
		inputOptions: .init(capitalizationType: .words)
	)
	var editorTitle: String?

	static var parameterSummary: some ParameterSummary {
		// TODO: Booleans labels don't show. (iOS 16.0)
//		When(\.$shouldEdit, .equalTo, true) {
//			Summary("\(\.$shouldEdit) \(\.$text)") {
//				\.$editorTitle
//			}
//		} otherwise: {
//			Summary("\(\.$shouldEdit) text") {
//				\.$editorTitle
//			}
//		}
		When(\.$shouldEdit, .equalTo, true) {
			Summary("Edit \(\.$text)") {
				\.$shouldEdit
				\.$editorTitle
			}
		} otherwise: {
			Summary("Write text") {
				\.$shouldEdit
				\.$editorTitle
			}
		}
	}

	@MainActor
	func perform() async throws -> some IntentResult {
		AppState.shared.writeTextData = .init(
			title: editorTitle,
			text: shouldEdit ? (text?.nilIfEmptyOrWhitespace ?? "") : ""
		)

		return .result()
	}
}
