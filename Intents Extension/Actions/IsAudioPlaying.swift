import AppIntents
import AVFAudio

// https://github.com/feedback-assistant/reports/issues/438

@available(macOS, unavailable)
struct IsAudioPlayingIntent: AppIntent {
	static let title: LocalizedStringResource = "Is Audio Playing (iOS-only)"

	static let description = IntentDescription(
		"""
		Returns whether there is audio currently playing on the device.

		Important: The action simply returns the value that iOS provides, so if there are any false-positives, there is unfortunately not much we can do about it. I recommend trying to restart your device, which sometimes fixes such issues.

		Known issues
		- It incorrectly returns “true” if the microphone is active.
		- It incorrectly returns “true” if you have the “Accessibility › Sound Recognition” system setting enabled.
		- It returns “false” if audio is playing through AirPlay. There is unfortunately no way to detect this.
		- It returns “true” for a while after you end a call, even though no audio is playing.
		""",
		categoryName: "Device"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: AVAudioSession.sharedInstance().isOtherAudioPlaying)
	}
}
