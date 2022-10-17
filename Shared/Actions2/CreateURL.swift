import AppIntents

private let inputOptions = String.IntentInputOptions(
	keyboardType: .URL,
	capitalizationType: .none,
	autocorrect: false,
	smartQuotes: false,
	smartDashes: false
)

struct CreateURL: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "CreateURLIntent"

	static let title: LocalizedStringResource = "Create URL"

	static let description = IntentDescription(
		"Creates a URL from components.",
		categoryName: "URL"
	)

	@Parameter(title: "Scheme", default: "https", inputOptions: inputOptions)
	var scheme: String

	@Parameter(title: "Host", inputOptions: inputOptions)
	var host: String?

	@Parameter(title: "Path", inputOptions: inputOptions)
	var path: String?

	@Parameter(title: "Query Items (every other item is key & value)", default: [], inputOptions: inputOptions)
	var queryItems: [String]

	@Parameter(title: "Fragment", inputOptions: inputOptions)
	var fragment: String?

	@Parameter(title: "User", inputOptions: inputOptions)
	var user: String?

	@Parameter(title: "Password", inputOptions: inputOptions)
	var password: String?

	@Parameter(title: "Custom Port", default: false)
	var useCustomPort: Bool

	@Parameter(title: "Port", controlStyle: .field)
	var port: Int?

	static var parameterSummary: some ParameterSummary {
		When(\.$useCustomPort, .equalTo, true) {
			Summary {
				\.$scheme
				\.$host
				\.$path
				\.$queryItems
				\.$fragment
				\.$user
				\.$password
				\.$useCustomPort
				\.$port
			}
		} otherwise: {
			Summary {
				\.$scheme
				\.$host
				\.$path
				\.$queryItems
				\.$fragment
				\.$user
				\.$password
				\.$useCustomPort
			}
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<URL> {
		var urlComponents = URLComponents()

		// Setting it to "https:" is not valid, but we gracefully handle that for the user.
		let scheme = scheme
			.nilIfEmptyOrWhitespace?
			.replacingSuffix("://", with: "")
			.replacingSuffix(":", with: "")
				?? "https"

		guard URL.isValidScheme(scheme) else {
			throw "Invalid URL scheme.".toError
		}

		urlComponents.scheme = scheme

		if let host = host?.nilIfEmptyOrWhitespace {
			urlComponents.host = host
		}

		// Including the `/` prefix is required, but we handle it in case the user forgets.
		if let path = path?.nilIfEmptyOrWhitespace {
			urlComponents.path = path.ensurePrefix("/")
		}

		if let queryItems = queryItems.nilIfEmpty {
			urlComponents.queryItems = queryItems
				.chunked(by: 2)
				.compactMap {
					guard let key = $0.first else {
						return nil
					}

					return URLQueryItem(name: key, value: $0.second)
				}
				.filter { !$0.name.isEmpty }
				.nilIfEmpty
		}

		if let fragment = fragment?.nilIfEmptyOrWhitespace {
			urlComponents.fragment = fragment
		}

		if let user = user?.nilIfEmptyOrWhitespace {
			urlComponents.user = user
		}

		if let password = password?.nilIfEmptyOrWhitespace {
			urlComponents.password = password
		}

		if
			useCustomPort == true,
			let port = port?.nilIfZero
		{
			urlComponents.port = port
		}

		guard let url = urlComponents.url else {
			throw "The created URL is invalid.".toError
		}

		return .result(value: url)
	}
}
