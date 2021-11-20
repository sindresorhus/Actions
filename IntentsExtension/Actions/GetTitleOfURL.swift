import Foundation
import LinkPresentation

@MainActor
final class GetTitleOfURLIntentHandler: NSObject, GetTitleOfURLIntentHandling {
	func handle(intent: GetTitleOfURLIntent) async -> GetTitleOfURLIntentResponse {
		guard let url = intent.url else {
			return .init(code: .success, userActivity: nil)
		}

		let response = GetTitleOfURLIntentResponse(code: .success, userActivity: nil)

		let metadataProvider = LPMetadataProvider()
		metadataProvider.shouldFetchSubresources = false

		do {
			response.result = try await metadataProvider.startFetchingMetadata(for: url).title ?? url.host
		} catch {
			return .failure(failure: error.localizedDescription)
		}

		return response
	}
}
