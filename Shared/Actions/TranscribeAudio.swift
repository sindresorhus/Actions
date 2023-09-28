import AppIntents
import Speech

struct TranscribeAudio: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "TranscribeAudioIntent"

	static let title: LocalizedStringResource = "Transcribe Audio"

	static let description = IntentDescription(
"""
Converts the speech in the input audio file to text.

Note: On iOS, the transcription only works if the audio takes less than 30 seconds to process. This usually means about 1 minute of transcription. This is because third-party actions only get 30 seconds to execute.

Tip: Check out my app Aiko on the App Store. It has higher quality transcription, unlimited duration, and supports 100 languages.

See the built-in "Dictate Text" action if you need to transcribe in real-time.

Important: If you have permission issues even after granting access, try removing the action from your shortcut, force quit Shortcuts and Actions, and then add the action again.
""",
		categoryName: "Audio"
	)

	@Parameter(title: "Audio File", supportedTypeIdentifiers: ["public.audio"])
	var file: IntentFile

	@Parameter(title: "Custom Locale (Many of the locales do not work because of a macOS/iOS bug)")
	var locale: SFLocaleAppEntity

	@Parameter(title: "Perform Offline (Buggy, don't use)", default: false)
	var offline: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("Transcribe \(\.$file)") {
			\.$locale
			\.$offline
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		guard await SFSpeechRecognizer.requestAuthorization() == .authorized else {
			let recoverySuggestion = OS.current == .macOS
				? "You can grant access in “System Settings › Privacy & Security › Speech Recognition”."
				: "You can grant access in “Settings › \(SSApp.name)”."

			throw "No access to speech recognition. \(recoverySuggestion)".toError
		}

		guard let recognizer = SFSpeechRecognizer(locale: .init(identifier: locale.id)) else {
			throw "Unsupported locale.".toError
		}

		if !recognizer.isAvailable {
			throw "Audio transcription is not supported on this device.".toError
		}

		recognizer.supportsOnDeviceRecognition = true

		let url = try file.writeToUniqueTemporaryFile()

		defer {
			try? FileManager.default.removeItem(at: url)
		}

		let request = SFSpeechURLRecognitionRequest(url: url)
		request.shouldReportPartialResults = false
		request.taskHint = .dictation
		request.requiresOnDeviceRecognition = offline

		let result = try await {
			do {
				return try await recognizer.recognitionTask(with: request).bestTranscription.formattedString
			} catch {
				let nsError = error as NSError

				// "No speech detected" error
				if nsError.domain == "kAFAssistantErrorDomain", nsError.code == 1110 {
					return ""
				}

				throw error
			}
		}()

		return .result(value: result)
	}
}

struct SFLocaleAppEntity: AppEntity {
	struct SFLocaleAppEntityQuery: EntityQuery {
		private func allEntities() -> [SFLocaleAppEntity] {
			Array(SFSpeechRecognizer.supportedLocales())
				.sorted(by: \.localizedName)
				.map(SFLocaleAppEntity.init)
		}

		func entities(for identifiers: [SFLocaleAppEntity.ID]) async throws -> [SFLocaleAppEntity] {
			allEntities().filter { identifiers.contains($0.id) }
		}

		func suggestedEntities() async throws -> [SFLocaleAppEntity] {
			allEntities()
		}
	}

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Locale"

	static let defaultQuery = SFLocaleAppEntityQuery()

	private let localizedName: String

	let id: String

	init(_ locale: Locale) {
		self.id = locale.identifier
		self.localizedName = locale.localizedName
	}

	var displayRepresentation: DisplayRepresentation {
		.init(title: "\(localizedName)")
	}
}
