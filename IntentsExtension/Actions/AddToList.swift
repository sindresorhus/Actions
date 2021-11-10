import Foundation

@MainActor
final class AddToListIntentHandler: NSObject, AddToListIntentHandling {
	func handle(intent: AddToListIntent) async -> AddToListIntentResponse {
		let list = intent.list ?? []
		let response = AddToListIntentResponse(code: .success, userActivity: nil)

		guard let item = intent.item else {
			response.result = list
			return response
		}

		if intent.prepend?.boolValue == true {
			response.result = list.prepending(item)
		} else {
			response.result = list.appending(item)
		}

		return response
	}
}
