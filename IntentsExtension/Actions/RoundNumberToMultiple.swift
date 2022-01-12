import Foundation

extension FloatingPointRoundingRule {
	fileprivate init(_ mode: NumberRoundingMode) {
		switch mode {
		case .unknown, .normal:
			self = .toNearestOrAwayFromZero
		case .alwaysRoundUp:
			self = .up
		case .alwaysRoundDown:
			self = .down
		}
	}
}

@MainActor
final class RoundNumberToMultipleIntentHandler: NSObject, RoundNumberToMultipleIntentHandling {
	func handle(intent: RoundNumberToMultipleIntent) async -> RoundNumberToMultipleIntentResponse {
		guard
			let number = intent.number as? Double,
			let multiple = intent.multiple as? Int
		else {
			return .init(code: .success, userActivity: nil)
		}

		let response = RoundNumberToMultipleIntentResponse(code: .success, userActivity: nil)

		response.result = number.roundedToMultiple(
			of: multiple,
			roundingRule: .init(intent.mode)
		) as NSNumber

		return response
	}
}
