import Foundation

extension URLQueryItem_ {
	fileprivate convenience init(_ urlQueryItem: URLQueryItem) {
		self.init(
			identifier: urlQueryItem.description,
			display: urlQueryItem.name,
			subtitle: urlQueryItem.value,
			image: nil
		)

		self.value = urlQueryItem.value
		self.nameAndValue = "\(urlQueryItem.name)\n\(urlQueryItem.value ?? "")"
	}
}

@MainActor
final class GetQueryItemsFromURLIntentHandler: NSObject, GetQueryItemsFromURLIntentHandling {
	func handle(intent: GetQueryItemsFromURLIntent) async -> GetQueryItemsFromURLIntentResponse {
		let response = GetQueryItemsFromURLIntentResponse(code: .success, userActivity: nil)
		response.result = intent.url?.queryItems.map { URLQueryItem_($0) }
		return response
	}
}
