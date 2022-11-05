import AppIntents
import SwiftUI

@available(iOS, unavailable)
struct PlayAlertSound: AppIntent {
	static let title: LocalizedStringResource = "Play Alert Sound (macOS-only)"

	static let description = IntentDescription(
		"Plays the user preferred alert sound.",
		categoryName: "Audio"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Play alert sound")
	}

	func perform() async throws -> some IntentResult {
		#if canImport(AppKit)
		NSSound.beep()
		#endif

		return .result()
	}
}
