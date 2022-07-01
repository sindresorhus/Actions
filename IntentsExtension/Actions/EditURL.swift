import Foundation

@MainActor
final class EditURLIntentHandler: NSObject, EditURLIntentHandling {
	func handle(intent: EditURLIntent) async -> EditURLIntentResponse {
		guard let url = intent.url else {
			return .init(code: .success, userActivity: nil)
		}

		guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			return .failure(failure: "“\(url)” is not a valid URL.")
		}

		let response = EditURLIntentResponse(code: .success, userActivity: nil)

		switch intent.action {
		case .unknown:
			return .init(code: .failure, userActivity: nil)
		case .addQueryItem:
			if
				let name = intent.queryItemName?.nilIfEmptyOrWhitespace,
				let value = intent.queryItemValue?.nilIfEmpty
			{
				urlComponents.queryItems = (urlComponents.queryItems ?? [])
					.appending(.init(name: name, value: value))
			}
		case .addPathComponent:
			if let pathComponent = intent.addPathComponentValue?.nilIfEmptyOrWhitespace {
				response.result = url.appendingPathComponent(pathComponent)
			}

			return response
		case .appendToQuery:
			if let queryPart = intent.appendToQueryValue?.nilIfEmptyOrWhitespace {
				urlComponents.query = (urlComponents.query ?? "") + queryPart
			}
		case .appendToFragment:
			if let fragmentPart = intent.appendToFragmentValue?.nilIfEmptyOrWhitespace {
				urlComponents.fragment = (urlComponents.fragment ?? "") + fragmentPart
			}
		case .removeQueryItemsNamed:
			if let name = intent.removeQueryItemsNamedValue {
				urlComponents.queryItems = (urlComponents.queryItems ?? [])
					.filter { $0.name != name }
					.nilIfEmpty
			}
		case .removeLastPathComponent:
			response.result = url.deletingLastPathComponent()
			return response
		case .removeQuery:
			urlComponents.query = nil
		case .removeFragment:
			urlComponents.fragment = nil
		case .removePath:
			urlComponents.path = ""
		case .removePort:
			urlComponents.port = nil
		case .removeUserAndPassword:
			urlComponents.user = nil
			urlComponents.password = nil
		case .setQuery:
			if let query = intent.setQueryValue?.nilIfEmptyOrWhitespace {
				urlComponents.query = query
			}
		case .setFragment:
			if let fragment = intent.setFragmentValue?.nilIfEmptyOrWhitespace {
				urlComponents.fragment = fragment
			}
		case .setPath:
			if let path = intent.setPathValue?.nilIfEmptyOrWhitespace {
				// Including the `/` prefix is required, but we handle it so the user does not have to care.
				urlComponents.path = path.trimmingCharacters(in: .whitespaces).ensurePrefix("/")
			}
		case .setScheme:
			if var scheme = intent.setSchemeValue?.nilIfEmptyOrWhitespace {
				scheme = scheme
					// Setting it to "https:" is not valid, but we gracefully handle that for the user.
					.replacingSuffix("://", with: "")
					.replacingSuffix(":", with: "")

				guard URL.isValidScheme(scheme) else {
					return .failure(failure: "Invalid URL scheme.")
				}

				urlComponents.scheme = scheme
			}
		case .setHost:
			if let host = intent.setHostValue?.nilIfEmptyOrWhitespace {
				urlComponents.host = host
			}
		case .setUsernameAndPassword:
			if
				let username = intent.username?.trimmingCharacters(in: .whitespaces).nilIfEmpty,
				let password = intent.password?.nilIfEmpty
			{
				urlComponents.user = username
				urlComponents.password = password
			}
		}

		guard let url = urlComponents.url else {
			return .failure(failure: "The edited URL is invalid.")
		}

		response.result = url

		return response
	}
}
