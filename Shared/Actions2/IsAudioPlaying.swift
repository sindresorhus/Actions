import AppIntents
import AVFAudio

@available(macOS, unavailable)
struct IsAudioPlaying: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "IsAudioPlayingIntent"

	static let title: LocalizedStringResource = "Is Audio Playing (iOS-only)"

	static let description = IntentDescription(
		"Returns whether there is audio currently playing on the device.",
		categoryName: "Device"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: AVAudioSession.sharedInstance().isOtherAudioPlaying)
	}
}
