import AppIntents
import SwiftUI

@available(iOS, unavailable)
struct SampleColor: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "SampleColorIntent"

	static let title: LocalizedStringResource = "Sample Color from Screen (macOS-only)"

	static let description = IntentDescription(
		"Lets you pick a color from the screen. Returns the color in Hex format.",
		categoryName: "Utility"
	)

	// TODO: Is an optional ok as a return value? Test what happens if it's actually `nil`.
	func perform() async throws -> some IntentResult & ReturnsValue<ColorAppEntity?> {
		#if os(macOS)
		guard let color = await NSColorSampler().sample() else {
			return .result(value: nil)
		}

		return .result(value: .init(color))
		#else
		.result(value: nil)
		#endif
	}
}
