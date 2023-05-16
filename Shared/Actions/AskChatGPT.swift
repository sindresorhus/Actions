import AppIntents
import SimpleKeychain
import OpenAISwift

struct AskChatGPT: AppIntent {
	static let title: LocalizedStringResource = "Ask ChatGPT"

	static let description = IntentDescription(
"""
Send a prompt to ChatGPT and get a text reply.

It does not remember previous conversations.

IMPORTANT: You must add your open OpenAI API key in the app settings before using this action.

NOTE: Using the GPT-4 model requires access to the beta: https://openai.com/waitlist/gpt-4
NOTE: The GPT-4 model generally costs 14x more than GPT-3.5.

TIP: If you want a dictionary back, end your prompt with: “Return the result as a JSON object. Don't include any other text than the JSON object.” and then pass the result to the “Get Dictionary from Input” action. For more consistent result, also describe the shape of the JSON and include an example.
""",
		categoryName: "AI"
	)

	@Parameter(title: "Prompt")
	var prompt: String

	@Parameter(title: "Model", default: .gpt3_5)
	var model: Model_AppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Ask ChatGPT \(\.$prompt)") {
			\.$model
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		let keychain = SimpleKeychain(synchronizable: true)

		guard
			try keychain.hasItem(forKey: Constants.keychainKey_openAI),
			let token = try keychain.string(forKey: Constants.keychainKey_openAI).nilIfEmptyOrWhitespace
		else {
			throw "Please add your OpenAI API key in the settings of the main Actions app.".toError
		}

		let openAI = OpenAISwift(authToken: token)

		let response: OpenAI<MessageResult>
		do {
			response = try await openAI.sendChat(
				with: [
					.init(role: .system, content: "Keep it short."),
					.init(role: .user, content: prompt)
				],
				model: model == .gpt3_5 ? .chat(.chatgpt) : .other("gpt-4")
			)
		} catch OpenAIError.genericError(let error) {
			throw error.presentableMessage.toError
		} catch OpenAIError.decodingError(let error) {
			throw error.presentableMessage.toError
		} catch OpenAIError.chatError(let error) {
			var message = error.message

			if error.code == "model_not_found" {
				message += ". Make sure you have access to this model. GPT-4 requires special access."
			}

			throw error.message.toError
		}

		guard let reply = response.choices?.first?.message.content else {
			throw "Missing reply.".toError
		}

		return .result(value: reply)
	}
}

enum Model_AppEnum: String, AppEnum {
	case gpt3_5
	case gpt4

	static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Model")

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.gpt3_5: "GPT-3.5",
		.gpt4: "GPT-4 (Requires special access!)"
	]
}
