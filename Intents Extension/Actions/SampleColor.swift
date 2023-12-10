import AppIntents
import SwiftUI

@available(iOS, unavailable)
struct SampleColorIntent: AppIntent {
	static let title: LocalizedStringResource = "Sample Color from Screen (macOS-only)"

	static let description = IntentDescription(
		"Lets you pick a color from the screen.",
		categoryName: "Utility",
		resultValueName: "Sampled Color"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<ColorAppEntity?> {
		#if os(macOS)
		guard let color = await NSColorSampler().sample() else {
			return .result(value: nil)
		}

		return .result(value: .init(color.toColor.resolve(in: .init())))
		#else
		.result(value: nil)
		#endif
	}
}
