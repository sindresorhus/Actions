import AppIntents
import SwiftUI

@available(iOS, unavailable)
@available(visionOS, unavailable)
struct PlayAlertSound: AppIntent {
	static let title: LocalizedStringResource = "Play Alert Sound"

	static let description = IntentDescription(
		"Plays the user preferred alert sound.",
		categoryName: "Audio"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Play alert sound")
	}

	func perform() async throws -> some IntentResult {
		#if os(macOS)
		NSSound.beep()
		#endif

		return .result()
	}
}
