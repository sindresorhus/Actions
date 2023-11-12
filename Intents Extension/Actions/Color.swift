import AppIntents
import SwiftUI

struct ColorIntent: AppIntent {
	static let title: LocalizedStringResource = "Color"

	static let description = IntentDescription(
		"""
		Create a color type.

		This color type can be used as input for the following actions:
		- Get Average Color

		This color type is the return value of the following actions:
		- Get Random Color
		- Get Dominant Colors of Image
		- Get Average Color of Image

		For example, you could get the two most dominant colors of an image using the “Get Dominant Colors of Image” action and then pass the result into the “Get Average Color” action to get the average of those.
		""",
		categoryName: "Color",
		searchKeywords: [
			"colour",
			"hex",
			"rgb",
			"rgba"
		]
	)

	@Parameter(
		title: "Color (hex format)",
		description:
			"""
			Example: #ff69b4
			Example: #80ff69b4 (with 50% opacity)
			""",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var color: String

	@Parameter(
		title: "Set Opacity",
		default: false
	)
	var shouldSetOpacity: Bool

	@Parameter(
		title: "Opacity",
		description: "Overrides any opacity in the Hex code.",
		default: 1,
		controlStyle: .slider,
		inclusiveRange: (0, 1)
	)
	var opacity: Double

	static var parameterSummary: some ParameterSummary {
		When(\.$shouldSetOpacity, .equalTo, true) {
			Summary("\(\.$color)") {
				\.$shouldSetOpacity
				\.$opacity
			}
		} otherwise: {
			Summary("\(\.$color)") {
				\.$shouldSetOpacity
			}
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<ColorAppEntity> {
		guard let color = Color.Resolved(hexString: color, opacity: shouldSetOpacity ? opacity : nil) else {
			throw "Invalid Hex color.".toError
		}

		return .result(value: .init(color))
	}
}
