import Foundation
import AVFAudio

@MainActor
final class IsAudioPlayingIntentHandler: NSObject, IsAudioPlayingIntentHandling {
	func handle(intent: IsAudioPlayingIntent) async -> IsAudioPlayingIntentResponse {
		let response = IsAudioPlayingIntentResponse(code: .success, userActivity: nil)
		response.result = AVAudioSession.sharedInstance().isOtherAudioPlaying as NSNumber
		return response
	}
}
