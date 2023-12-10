import AppIntents
import AVFAudio
import SwiftUI

@available(macOS, unavailable)
struct GetAudioPlaybackDestinationIntent: AppIntent {
	static let title: LocalizedStringResource = "Get Audio Playback Destination (iOS-only) (Does not detect AirPlay devices)"

	static let description = IntentDescription(
		"""
		Returns the audio playback destination of the device.

		Can be useful in combination with the built-in “Set Playback Destination” action.

		Known limitation: It will not be able to detect when the output is an AirPlay device because of a iOS bug.
		""",
		categoryName: "Device",
		searchKeywords: [
			"output"
		],
		resultValueName: "Audio Playback Destination"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Get audio playback destination")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String?> {
		#if canImport(UIKit)
		guard let outputDevice = AVAudioSession.sharedInstance().currentRoute.outputs.first else {
			return .result(value: nil)
		}

		let result = await outputDevice.portType == .builtInSpeaker
			? UIDevice.current.model
			: outputDevice.portName

		return .result(value: result)
		#else
		.result(value: nil)
		#endif
	}
}
