import Foundation
import Speech
import Intents

@MainActor
final class TranscribeAudioIntentHandler: NSObject, TranscribeAudioIntentHandling {
	func provideLocaleOptionsCollection(for intent: TranscribeAudioIntent) async throws -> INObjectCollection<Locale_> {
		let items = Array(SFSpeechRecognizer.supportedLocales())
			.sorted(by: \.localizedName)
			.map {
				Locale_(
					identifier: $0.identifier,
					display: $0.localizedName,
					subtitle: $0.identifier,
					image: nil
				)
			}

		return .init(items: items)
	}

	func handle(intent: TranscribeAudioIntent) async -> TranscribeAudioIntentResponse {
		let response = TranscribeAudioIntentResponse(code: .success, userActivity: nil)

		guard let file = intent.file else {
			return response
		}

		var locale = Locale.autoupdatingCurrent
		if let localeIdentifier = intent.locale?.identifier {
			locale = Locale(identifier: localeIdentifier)
		}

		guard let recognizer = SFSpeechRecognizer(locale: locale) else {
			return .failure(failure: "Unsupported locale.")
		}

		if !recognizer.isAvailable {
			return .failure(failure: "Audio transcription is not supported on this device.")
		}

		recognizer.supportsOnDeviceRecognition = true

		do {
			let url = try file.writeToUniqueTemporaryFile()

			defer {
				try? FileManager.default.removeItem(at: url)
			}

			let request = SFSpeechURLRecognitionRequest(url: url)
			request.shouldReportPartialResults = false
			request.taskHint = .dictation
			request.requiresOnDeviceRecognition = intent.offline as? Bool ?? false

			response.result = try await recognizer.recognitionTask(with: request).bestTranscription.formattedString
		} catch {
			return .failure(failure: error.presentableMessage)
		}

		return response
	}
}
