import Foundation

@MainActor
final class CreateURLIntentHandler: NSObject, CreateURLIntentHandling {
	func handle(intent: CreateURLIntent) async -> CreateURLIntentResponse {
		var urlComponents = URLComponents()

		// Setting it to "https:" is not valid, but we gracefully handle that for the user.
		let scheme = intent.scheme?
			.nilIfEmptyOrWhitespace?
			.replacingSuffix("://", with: "")
			.replacingSuffix(":", with: "")
				?? "https"

		guard URL.isValidScheme(scheme) else {
			return .failure(failure: "Invalid URL scheme.")
		}

		urlComponents.scheme = scheme

		if let host = intent.host?.nilIfEmptyOrWhitespace {
			urlComponents.host = host
		}

		// Including the `/` prefix is required, but we handle it in case the user forgets.
		if let path = intent.path?.nilIfEmptyOrWhitespace {
			urlComponents.path = path.ensurePrefix("/")
		}

		if let queryItems = intent.queryItems?.nilIfEmpty {
			urlComponents.queryItems = queryItems.chunked(by: 2).compactMap {
				guard let key = $0.first else {
					return nil
				}

				return URLQueryItem(name: key, value: $0.second)
			}
		}

		if let fragment = intent.fragment?.nilIfEmptyOrWhitespace {
			urlComponents.fragment = fragment
		}

		if let user = intent.user?.nilIfEmptyOrWhitespace {
			urlComponents.user = user
		}

		if let password = intent.password?.nilIfEmptyOrWhitespace {
			urlComponents.password = password
		}

		if
			intent.useCustomPort?.boolValue == true,
			let port = (intent.port as? Int)?.nilIfZero
		{
			urlComponents.port = port
		}

		guard let url = urlComponents.url else {
			return .failure(failure: "The created URL is invalid.")
		}

		let response = CreateURLIntentResponse(code: .success, userActivity: nil)
		response.result = url
		return response
	}
}
