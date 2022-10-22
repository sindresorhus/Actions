import AppIntents

struct SendFeedback: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "SendFeedbackIntent"

	static let title: LocalizedStringResource = "Send Feedback"

	static let description = IntentDescription(
		"Lets you send feedback, action ideas, bug reports, etc, directly to the developer of the Actions app. You can also email me at sindresorhus@gmail.com if you prefer that.",
		categoryName: "Meta"
	)

	@Parameter(title: "Message", inputOptions: String.IntentInputOptions(multiline: true))
	var message: String

	@Parameter(
		title: "Your Email",
		// TODO: Make it `.init(` at some point when the Swift compiler is better at extracting const literals.
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var email: String

	static var parameterSummary: some ParameterSummary {
		Summary("Send feedback to the developer of the Actions app") {
			\.$email
			\.$message
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		guard
			let email = email.trimmed.nilIfEmpty,
			email.contains("@")
		else {
			throw "Invalid email address.".toError
		}

		guard let message = message.nilIfEmptyOrWhitespace else {
			throw "Write a message.".toError
		}

		try await SSApp.sendFeedback(email: email, message: message)

		return .result(value: "Thanks for your feedback 🙌")
	}
}
