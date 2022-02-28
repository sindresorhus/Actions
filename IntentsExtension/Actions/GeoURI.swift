import SwiftUI

@MainActor
final class GeoURIIntentHandler: NSObject, GeoURIIntentHandling {
	func handle(intent: GeoURIIntent) async -> GeoURIIntentResponse {
		let response = GeoURIIntentResponse(code: .success, userActivity: nil)
		let includeAccuracy = intent.includeAccuracy as? Bool ?? true
		response.result = intent.location?.location?.geoURI(includeAccuracy: includeAccuracy)
		return response
	}
}
