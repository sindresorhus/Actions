import AppIntents

struct GetQueryItemsFromURL: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GetQueryItemsFromURLIntent"

	static let title: LocalizedStringResource = "Get Query Items from URL"

	static let description = IntentDescription(
"""
Returns all query items from the input URL.

The name and value of the query item can be accessed individually.
""",
		categoryName: "URL"
	)

	@Parameter(title: "URL")
	var url: URL

	static var parameterSummary: some ParameterSummary {
		Summary("Get query items from \(\.$url)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[URLQueryItemAppEntity]> {
		.result(value: url.queryItems.map { .init($0) })
	}
}

struct URLQueryItemAppEntity: TransientAppEntity {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "URL Query Item"

	@Property(title: "Name")
	var name: String

	@Property(title: "Value")
	var value: String?

	@Property(title: "Name and Value")
	var nameAndValue: String

	var displayRepresentation: DisplayRepresentation {
		.init(
			title: "\(name)",
			subtitle: value.flatMap { "\($0)" }
		)
	}
}

extension URLQueryItemAppEntity {
	fileprivate init(_ urlQueryItem: URLQueryItem) {
		self.init()
		self.name = urlQueryItem.name
		self.value = urlQueryItem.value
		self.nameAndValue = "\(urlQueryItem.name)\n\(urlQueryItem.value ?? "")"
	}
}
