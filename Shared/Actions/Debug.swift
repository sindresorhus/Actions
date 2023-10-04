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

		#if os(iOS)
		debugInfo["audioOutputPorts"] = AVAudioSession.sharedInstance().currentRoute.outputs.map(\.portName)
		#endif

		return .result(value: "Debug Info:\n\n\(debugInfo.descriptionAsKeyValue())")
	}
}
