import AppIntents
import SwiftUI

@available(iOS, unavailable)
struct FlashScreen: AppIntent {
	static let title: LocalizedStringResource = "Flash Screen (macOS-only)"

	static let description = IntentDescription(
		"Flashes the screen momentarily.",
		categoryName: "Device"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Flash screen")
	}

	func perform() async throws -> some IntentResult {
		#if canImport(AppKit)
		await SystemSound.flashScreen()
		#endif

		return .result()
	}
}
