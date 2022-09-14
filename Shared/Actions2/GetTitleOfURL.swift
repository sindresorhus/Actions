import AppIntents
import LinkPresentation

struct GetTitleOfURL: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GetTitleOfURLIntent"

	static let title: LocalizedStringResource = "Get Title of URL"

	static let description = IntentDescription(
		"Returns the title of the given website.",
		categoryName: "URL"
	)

	@Parameter(title: "URL")
	var url: URL

	static var parameterSummary: some ParameterSummary {
		Summary("Get the title of \(\.$url)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		let metadataProvider = LPMetadataProvider()
		metadataProvider.shouldFetchSubresources = false

		let result = try await metadataProvider.startFetchingMetadata(for: url).title ?? url.host ?? ""

		return .result(value: result)
	}
}
