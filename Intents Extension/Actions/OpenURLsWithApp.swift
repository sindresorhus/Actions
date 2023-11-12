#if os(macOS)
import AppIntents
import AppKit

@available(iOS, unavailable)
struct OpenURLsWithApp: AppIntent {
	static let title: LocalizedStringResource = "Open URLs with App"

	static let description = IntentDescription(
		"""
		Opens URLs in a specific app.

		This only works for apps that declare they can open URLs. Click the app parameter to see those apps.

		Tip: Check out the action that comes with my Velja app if you need to open URLs with an app that does not declare support for URLs.
		""",
		categoryName: "URL"
	)

	@Parameter(title: "URL")
	var urls: [URL]

	@Parameter(title: "App")
	var app: App_AppEntity

	@Parameter(title: "Open in background", default: false)
	var openInBackground: Bool

	@Parameter(title: "Hide other apps", default: false)
	var hideOtherApps: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("Open \(\.$urls) with \(\.$app)") {
			\.$openInBackground
			\.$hideOtherApps
		}
	}

	func perform() async throws -> some IntentResult {
		guard let urls = urls.removingDuplicates().nilIfEmpty else {
			return .result()
		}

		let configuration = NSWorkspace.OpenConfiguration()
		configuration.activates = !openInBackground
		configuration.hidesOthers = hideOtherApps

		_ = try await NSWorkspace.shared.open(urls, withApplicationAt: app.url, configuration: configuration)

		return .result()
	}
}

struct App_AppEntity: AppEntity {
	struct App_AppEntityQuery: EntityQuery {
		private func allEntities() -> [App_AppEntity] {
			NSWorkspace.shared.urlsForApplications(toOpen: "http:")
				.map(App_AppEntity.init)
		}

		func entities(for identifiers: [App_AppEntity.ID]) async throws -> [App_AppEntity] {
			allEntities().filter { identifiers.contains($0.id) }
		}

		func suggestedEntities() async throws -> [App_AppEntity] {
			allEntities()
		}
	}

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "App"

	static let defaultQuery = App_AppEntityQuery()

	private let name: String
	private let icon: DisplayRepresentation.Image?

	let id: String
	let url: URL

	init(_ url: URL) {
		self.id = url.absoluteString
		self.url = url
		self.name = NSWorkspace.shared.appName(for: url)

		self.icon = NSWorkspace.shared
			.icon(forFile: url.path())
			.resized(to: .init(width: 32, height: 32))
			.toDisplayRepresentationImage()
	}

	var displayRepresentation: DisplayRepresentation {
		.init(
			title: "\(name)",
			subtitle: "", // The `""` is required as the image only works when subtitle is defined. (macOS 13.1)
			image: icon
		)
	}
}
#endif
