import Foundation

@MainActor
final class FormatDateDifferenceIntentHandler: NSObject, FormatDateDifferenceIntentHandling {
	func handle(intent: FormatDateDifferenceIntent) async -> FormatDateDifferenceIntentResponse {
		guard
			let firstDate = intent.firstDate?.date,
			let secondDate = intent.secondDate?.date
		else {
			return .init(code: .failure, userActivity: nil)
		}

		let formatter = RelativeDateTimeFormatter()

		let response = FormatDateDifferenceIntentResponse(code: .success, userActivity: nil)
		response.result = formatter.localizedString(for: firstDate, relativeTo: secondDate)
		return response
	}
}
