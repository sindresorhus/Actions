import SwiftUI

@MainActor
final class ApplyCaptureDateIntentHandler: NSObject, ApplyCaptureDateIntentHandling {
	func handle(intent: ApplyCaptureDateIntent) async -> ApplyCaptureDateIntentResponse {
		let images = intent.images ?? []
		let response = ApplyCaptureDateIntentResponse(code: .success, userActivity: nil)

		do {
			response.result = try images.map { file in
				guard let captureDate = CGImage.captureDate(ofImage: file.data) else {
					return file
				}

				return try file.modifyingFileAsURL { url in
					try url.setResourceValues {
						$0.creationDate = captureDate

						if intent.setModificationDate?.boolValue == true {
							$0.contentModificationDate = captureDate
						}
					}

					return url
				}
			}
		} catch {
			return .failure(failure: error.localizedDescription)
		}

		return response
	}
}
