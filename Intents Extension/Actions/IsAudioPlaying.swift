import AppIntents
import AVFAudio

@available(macOS, unavailable)
struct IsAudioPlaying: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "IsAudioPlayingIntent"

	static let title: LocalizedStringResource = "Is Audio Playing (iOS-only)"

	static let description = IntentDescription(
"""
Returns whether there is audio currently playing on the device.

Note: It will return “false” if audio is playing through AirPlay. There is unfortunately no way to detect this.

Important: The action simply returns the value that iOS provides, so if there are any false-positives, there is unfortunately no much we can do about it. I recommend trying to restart your device, which sometimes fixues such issues.
""",
		categoryName: "Device"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		// Try to work around problems with this action. No idea if this actually works.
		defer {
			Task {
				try? await Task.sleep(for: .seconds(0.1))
				exit(0)
			}
		}

		return .result(value: AVAudioSession.sharedInstance().isOtherAudioPlaying)
	}
}
