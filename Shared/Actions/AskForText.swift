import SwiftUI
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

	@Parameter(
		title: "Type",
		description: "This helps iOS pick the optimal keyboard.",
		default: .text
	)
	var type: InputTypeAppEnum

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
			\.$type
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
			showCancelButton: showCancelButton,
			type: type
		)

		return .result()
	}
}

enum InputTypeAppEnum: String, AppEnum {
	case text
	case number
	case url
	case email
	case phoneNumber

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Input Type"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.text: "Text",
		.number: "Number",
		.url: "URL",
		.email: "Email",
		.phoneNumber: "Phone Number"
	]
}

#if canImport(UIKit)
extension InputTypeAppEnum {
	var toContentType: UITextContentType? {
		switch self {
		case .text:
			nil
		case .number:
			nil
		case .url:
			.URL
		case .email:
			.emailAddress
		case .phoneNumber:
			.telephoneNumber
		}
	}

	var toKeyboardType: UIKeyboardType? {
		switch self {
		case .text:
			nil
		case .number:
			.decimalPad
		case .url:
			.URL
		case .email:
			.emailAddress
		case .phoneNumber:
			.phonePad
		}
	}

	var shouldDisableAutocorrectionAndAutocapitalization: Bool {
		switch self {
		case .text:
			false
		case .number:
			true
		case .url:
			true
		case .email:
			true
		case .phoneNumber:
			true
		}
	}
}
#endif
