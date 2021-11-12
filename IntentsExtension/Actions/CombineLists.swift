import Foundation

@MainActor
final class CombineListsIntentHandler: NSObject, CombineListsIntentHandling {
	func handle(intent: CombineListsIntent) async -> CombineListsIntentResponse {
		let response = CombineListsIntentResponse(code: .success, userActivity: nil)

		response.result = [
			intent.list1,
			intent.list2,
			intent.list3,
			intent.list4,
			intent.list5,
			intent.list6,
			intent.list7,
			intent.list8,
			intent.list9,
			intent.list10
		]
			.compact()
			.flatten()

		return response
	}
}
