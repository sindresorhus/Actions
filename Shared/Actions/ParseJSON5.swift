import SwiftUI

@MainActor
final class ParseJSON5IntentHandler: NSObject, ParseJSON5IntentHandling {
	func handle(intent: ParseJSON5Intent) async -> ParseJSON5IntentResponse {
		let response = ParseJSON5IntentResponse(code: .success, userActivity: nil)

		guard let file = intent.file else {
			return response
		}

		do {
			let json = try JSONSerialization.jsonObject(with: file.data, options: .json5Allowed)

			// TODO: Without this check, the Shortcuts app crashes on top-level array. (macOS 12.2)
			guard json is NSDictionary else {
				return .failure(failure: "The JSON has to be an object. The Shortcuts app cannot currently handle a top-level array.")
			}

			let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
			response.result = data.toINFile(contentType: .json, filename: file.filenameWithoutExtension)
		} catch {
			return .failure(failure: error.presentableMessage)
		}

		return response
	}
}
