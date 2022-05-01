import Foundation

@MainActor
final class FormatNumberCompactIntentHandler: NSObject, FormatNumberCompactIntentHandling {
	func handle(intent: FormatNumberCompactIntent) async -> FormatNumberCompactIntentResponse {
		let response = FormatNumberCompactIntentResponse(code: .success, userActivity: nil)

		guard let number = intent.number as? Double else {
			return response
		}

		let abbreviatedUnit = intent.abbreviatedUnit as? Bool ?? false

		response.result = number.formatWithCompactStyle(abbreviatedUnit: abbreviatedUnit)

		return response
	}
}
