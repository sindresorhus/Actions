import AppIntents
import LinkPresentation

struct GetTitleOfURLIntent: AppIntent {
	static let title: LocalizedStringResource = "Get Title of URL"

	static let description = IntentDescription(
		"Returns the title of the given website, or nothing if it failed to get the title.",
		categoryName: "URL",
		resultValueName: "Title of URL"
	)

	@Parameter(title: "URL")
	var url: URL

	static var parameterSummary: some ParameterSummary {
		Summary("Get the title of \(\.$url)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String?> {
		let metadataProvider = LPMetadataProvider()
		metadataProvider.shouldFetchSubresources = false

		let result: String? = await {
			do {
				return try await metadataProvider.startFetchingMetadata(for: url).title ?? url.host
			} catch {
				// TODO: When I support a logging action, log the error here then.
				print(error)
				return nil // Shortcuts doesn't have any error handling capabilities, so better to just return empty result on failure.
			}
		}()

		return .result(value: result)
	}
}
