#if canImport(UIKit)
import AppIntents

// NOTE: It has to be in the main app so it is able to present the permission prompt.

@available(macOS, unavailable)
@available(visionOS, unavailable)
struct GetElevation: AppIntent {
	static let title: LocalizedStringResource = "Get Elevation"

	static let description = IntentDescription(
		"""
		Returns the current elevation of the device, the absolute altitude above sea level.

		NOTE: Does not work on visionOS.
		""",
		categoryName: "Device",
		searchKeywords: [
			"altitude",
			"height",
			"barometer",
			"barometric",
			"pressure",
			"measure"
		],
		resultValueName: "Elevation"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Measurement<UnitLength>> {
		let result = try await Device.absoluteAltimeterUpdates().first()?.altitude ?? 0
		return .result(value: .init(value: result, unit: .meters))
	}
}
#endif
