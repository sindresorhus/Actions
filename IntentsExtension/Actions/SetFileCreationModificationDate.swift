import Foundation

@MainActor
final class SetFileCreationModificationDateIntentHandler: NSObject, SetFileCreationModificationDateIntentHandling {
	func resolveDate(for intent: SetFileCreationModificationDateIntent) async -> SetFileCreationModificationDateDateResolutionResult {
		guard
			let dateComponents = intent.date,
			dateComponents.isValidDate
		else {
			return .unsupported(forReason: .invalid)
		}

		return .success(with: dateComponents)
	}

	func handle(intent: SetFileCreationModificationDateIntent) async -> SetFileCreationModificationDateIntentResponse {
		guard let file = intent.file else {
			return .init(code: .success, userActivity: nil)
		}

		guard let date = intent.date?.date else {
			return .init(code: .failure, userActivity: nil)
		}

		let response = SetFileCreationModificationDateIntentResponse(code: .success, userActivity: nil)

		do {
			response.result = try file.modifyingFileAsURL { url in
				try url.setResourceValues {
					switch intent.type {
					case .unknown:
						break
					case .creationDate:
						$0.creationDate = date
					case .modificationDate:
						$0.contentModificationDate = date
					case .both:
						$0.creationDate = date
						$0.contentModificationDate = date
					}
				}

				return url
			}
		} catch {
			return .failure(failure: error.presentableMessage)
		}

		return response
	}
}
