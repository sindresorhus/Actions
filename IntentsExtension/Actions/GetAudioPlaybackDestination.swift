import SwiftUI
import AVFAudio

@MainActor
final class GetAudioPlaybackDestinationIntentHandler: NSObject, GetAudioPlaybackDestinationIntentHandling {
	func handle(intent: GetAudioPlaybackDestinationIntent) async -> GetAudioPlaybackDestinationIntentResponse {
		let response = GetAudioPlaybackDestinationIntentResponse(code: .success, userActivity: nil)

		if let outputDevice = AVAudioSession.sharedInstance().currentRoute.outputs.first {
			response.result = outputDevice.portType == .builtInSpeaker
				? UIDevice.current.model
				: outputDevice.portName
		}

		return response
	}
}
