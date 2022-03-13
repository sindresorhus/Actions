import Foundation

@MainActor
final class MergeDictionariesIntentHandler: NSObject, MergeDictionariesIntentHandling {
	func handle(intent: MergeDictionariesIntent) async -> MergeDictionariesIntentResponse {
		let response = MergeDictionariesIntentResponse(code: .success, userActivity: nil)

		guard let mainDictionaryFile = intent.dictionary1 else {
			return response
		}

		do {
			// Note to self: We manually define each dictionary parameter in the Intents definition as using "Supports multiple values" on a single parameter does not show multiple inputs in the UI. (macOS 12.2)

			let dictionary1 = try mainDictionaryFile.data.jsonToDictionary()
			let dictionary2 = try intent.dictionary2?.data.jsonToDictionary() ?? [:]
			let dictionary3 = try intent.dictionary3?.data.jsonToDictionary() ?? [:]
			let dictionary4 = try intent.dictionary4?.data.jsonToDictionary() ?? [:]
			let dictionary5 = try intent.dictionary5?.data.jsonToDictionary() ?? [:]
			let dictionary6 = try intent.dictionary6?.data.jsonToDictionary() ?? [:]
			let dictionary7 = try intent.dictionary7?.data.jsonToDictionary() ?? [:]
			let dictionary8 = try intent.dictionary8?.data.jsonToDictionary() ?? [:]
			let dictionary9 = try intent.dictionary9?.data.jsonToDictionary() ?? [:]
			let dictionary10 = try intent.dictionary10?.data.jsonToDictionary() ?? [:]

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

			response.result = try finalDictionary.toINFile(filename: mainDictionaryFile.filename)
		} catch {
			return .failure(failure: error.presentableMessage)
		}

		return response
	}
}
