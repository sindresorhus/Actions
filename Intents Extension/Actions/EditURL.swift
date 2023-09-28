import AppIntents

struct EditURL: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "EditURLIntent"

	static let title: LocalizedStringResource = "Edit URL"

	static let description = IntentDescription(
"""
Lets you edit the components of the input URL.

For example, add a query item, change the path, or remove the fragment.
""",
		categoryName: "URL"
	)

	@Parameter(title: "URL")
	var url: URL

	@Parameter(title: "Action", default: .addQueryItem)
	var action: EditURLActionAppEnum

	@Parameter(
		title: "Name",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var queryItemName: String?

	@Parameter(
		title: "Value",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var queryItemValue: String?

	@Parameter(
		title: "Path Component",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var addPathComponentValue: String?

	@Parameter(
		title: "Query",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var appendToQueryValue: String?

	@Parameter(
		title: "Fragment",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var appendToFragmentValue: String?

	@Parameter(
		title: "Name",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var removeQueryItemsNamedValue: String?

	@Parameter(
		title: "Username",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var username: String?

	@Parameter(
		title: "Password",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var password: String?

	@Parameter(
		title: "Query",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var setQueryValue: String?

	@Parameter(
		title: "Fragment",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var setFragmentValue: String?

	@Parameter(
		title: "Path",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var setPathValue: String?

	@Parameter(
		title: "Scheme",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var setSchemeValue: String?

	@Parameter(
		title: "Host",
		inputOptions: String.IntentInputOptions(
			keyboardType: .URL,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var setHostValue: String?

	static var parameterSummary: some ParameterSummary {
		Switch(\.$action) {
			Case(.addQueryItem) {
				Summary("\(\.$action) \(\.$queryItemName) \(\.$queryItemValue) to \(\.$url)")
			}
			Case(.addPathComponent) {
				Summary("\(\.$action) \(\.$addPathComponentValue) of \(\.$url)")
			}
			Case(.appendToQuery) {
				Summary("\(\.$action) \(\.$appendToQueryValue) of \(\.$url)")
			}
			Case(.appendToFragment) {
				Summary("\(\.$action) \(\.$appendToFragmentValue) of \(\.$url)")
			}
			Case(.removeQueryItemsNamed) {
				Summary("\(\.$action) \(\.$removeQueryItemsNamedValue) from \(\.$url)")
			}
			Case(.setQuery) {
				Summary("\(\.$action) to \(\.$setQueryValue) for \(\.$url)")
			}
			Case(.setFragment) {
				Summary("\(\.$action) to \(\.$setFragmentValue) for \(\.$url)")
			}
			Case(.setPath) {
				Summary("\(\.$action) to \(\.$setPathValue) for \(\.$url)")
			}
			Case(.setScheme) {
				Summary("\(\.$action) to \(\.$setSchemeValue) for \(\.$url)")
			}
			Case(.setHost) {
				Summary("\(\.$action) to \(\.$setHostValue) for \(\.$url)")
			}
			Case(.setUsernameAndPassword) {
				Summary("\(\.$action) to \(\.$username) \(\.$password) for \(\.$url)")
			}
			DefaultCase {
				Summary("\(\.$action) of \(\.$url)")
			}
		}
	}

	func getURL() throws -> URL {
		guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			throw "“\(url)” is not a valid URL.".toError
		}

		switch action {
		case .addQueryItem:
			if
				let name = queryItemName?.nilIfEmptyOrWhitespace,
				let value = queryItemValue?.nilIfEmpty
			{
				urlComponents.queryItems = (urlComponents.queryItems ?? [])
					.appending(.init(name: name, value: value))
			}
		case .addPathComponent:
			if let pathComponent = addPathComponentValue?.nilIfEmptyOrWhitespace {
				return url.appendingPathComponent(pathComponent)
			}

			return url
		case .appendToQuery:
			if let queryPart = appendToQueryValue?.nilIfEmptyOrWhitespace {
				urlComponents.query = (urlComponents.query ?? "") + queryPart
			}
		case .appendToFragment:
			if let fragmentPart = appendToFragmentValue?.nilIfEmptyOrWhitespace {
				urlComponents.fragment = (urlComponents.fragment ?? "") + fragmentPart
			}
		case .removeQueryItemsNamed:
			if let name = removeQueryItemsNamedValue {
				urlComponents.queryItems = (urlComponents.queryItems ?? [])
					.filter { $0.name != name }
					.nilIfEmpty
			}
		case .removeLastPathComponent:
			return url.deletingLastPathComponent()
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
			if let query = setQueryValue?.nilIfEmptyOrWhitespace {
				urlComponents.query = query
			}
		case .setFragment:
			if let fragment = setFragmentValue?.nilIfEmptyOrWhitespace {
				urlComponents.fragment = fragment
			}
		case .setPath:
			if let path = setPathValue?.nilIfEmptyOrWhitespace {
				// Including the `/` prefix is required, but we handle it so the user does not have to care.
				urlComponents.path = path.trimmingCharacters(in: .whitespaces).ensurePrefix("/")
			}
		case .setScheme:
			if var scheme = setSchemeValue?.nilIfEmptyOrWhitespace {
				scheme = scheme
					// Setting it to "https:" is not valid, but we gracefully handle that for the user.
					.replacingSuffix("://", with: "")
					.replacingSuffix(":", with: "")

				guard URL.isValidScheme(scheme) else {
					throw "Invalid URL scheme.".toError
						// TOOD: Remove the `.report()` at some point.
						.report(userInfo: ["scheme": scheme, "originalScheme": setSchemeValue as Any])
				}

				// We use this to get some debug info as `.scheme` throws an exception on invalid input.
				SSApp.addBreadcrumb(
					"EditURL - setScheme",
					data: [
						"scheme": scheme,
						"originalScheme": setSchemeValue as Any
					]
				)

				urlComponents.scheme = scheme
			}
		case .setHost:
			if let host = setHostValue?.nilIfEmptyOrWhitespace {
				urlComponents.host = host
			}
		case .setUsernameAndPassword:
			if
				let username = username?.trimmingCharacters(in: .whitespaces).nilIfEmpty,
				let password = password?.nilIfEmpty
			{
				urlComponents.user = username
				urlComponents.password = password
			}
		}

		guard let url = urlComponents.url else {
			throw "The edited URL is invalid.".toError
		}

		return url
	}

	func perform() async throws -> some IntentResult & ReturnsValue<URL> {
		.result(value: try getURL())
	}
}

enum EditURLActionAppEnum: String, AppEnum {
	case addQueryItem
	case addPathComponent
	case appendToQuery
	case appendToFragment
	case removeQueryItemsNamed
	case removeLastPathComponent
	case removeQuery
	case removeFragment
	case removePath
	case removePort
	case removeUserAndPassword
	case setQuery
	case setFragment
	case setPath
	case setScheme
	case setHost
	case setUsernameAndPassword

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Edit URL Action"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.addQueryItem: "Add query item",
		.addPathComponent: "Add path component",
		.appendToQuery: "Append to query",
		.appendToFragment: "Append to fragment",
		.removeQueryItemsNamed: "Remove query items named",
		.removeLastPathComponent: "Remove last path component",
		.removeQuery: "Remove query",
		.removeFragment: "Remove fragment",
		.removePath: "Remove path",
		.removePort: "Remove port",
		.removeUserAndPassword: "Remove user and password",
		.setQuery: "Set query",
		.setFragment: "Set fragment",
		.setPath: "Set path",
		.setScheme: "Set scheme",
		.setHost: "Set host",
		.setUsernameAndPassword: "Set username and password"
	]
}
