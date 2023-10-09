import AppIntents
import AVFAudio

struct DebugIntent: AppIntent {
	static let title: LocalizedStringResource = "Debug (Internal)"

	static let description = IntentDescription(
		"This is meant for debugging problems with actions.",
		categoryName: "Z_Internal"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		var debugInfo = [String: Any]()

		#if canImport(UIKit)
		debugInfo["audioOutputPorts"] = AVAudioSession.sharedInstance().currentRoute.outputs.map(\.portName)
		debugInfo["isAudioPlaying"] = AVAudioSession.sharedInstance().isOtherAudioPlaying
		debugInfo["isAudioPlaying2"] = AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint
		#endif

		return .result(value: "Debug Info:\n\n\(debugInfo.descriptionAsKeyValue())")
	}
}
