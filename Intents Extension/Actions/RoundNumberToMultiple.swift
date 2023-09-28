import AppIntents

struct RoundNumberToMultiple: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "RoundNumberToMultipleIntent"

	static let title: LocalizedStringResource = "Round Number to Multiple"

	static let description = IntentDescription(
"""
Rounds the input number to the nearest multiple of the second number.

For example, if the number represents minutes and you want to round it to the nearest half-hour, you could use 30 as the multiple.
""",
		categoryName: "Number"
	)

	@Parameter(title: "Number")
	var number: Double

	@Parameter(title: "Multiple")
	var multiple: Int

	@Parameter(title: "Mode", default: .normal)
	var mode: NumberRoundingModeAppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Round \(\.$number) to the nearest multiple of \(\.$multiple)") {
			\.$mode
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Int> {
		guard number.isFinite else {
			throw "Cannot handle infinite number".toError
		}

		let result = number.roundedToMultiple(
			of: multiple,
			roundingRule: .init(mode)
		)

		guard !result.isNaN else {
			throw "The resulting number was NaN, which is not valid.".toError
				.report(
					userInfo: [
						"inputNumber": number,
						"inputMultiple": multiple,
						"mode": mode.rawValue
					]
				)
		}

		return .result(value: Int(result))
	}
}

enum NumberRoundingModeAppEnum: String, AppEnum {
	case normal
	case alwaysRoundUp
	case alwaysRoundDown

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Number Rounding Mode"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.normal: "Normal",
		.alwaysRoundUp: "Always Round Up",
		.alwaysRoundDown: "Always Round Down"
	]
}

extension FloatingPointRoundingRule {
	fileprivate init(_ mode: NumberRoundingModeAppEnum) {
		switch mode {
		case .normal:
			self = .toNearestOrAwayFromZero
		case .alwaysRoundUp:
			self = .up
		case .alwaysRoundDown:
			self = .down
		}
	}
}
