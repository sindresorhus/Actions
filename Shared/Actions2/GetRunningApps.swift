#if canImport(AppKit)
import AppIntents
import AppKit

@available(iOS, unavailable)
struct GetRunningApps: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GetRunningAppsIntent"

	static let title: LocalizedStringResource = "Get Running Apps (macOS-only)"

	static let description = IntentDescription(
"""
Returns the currently running apps, including various metadata about them.

Use the built-in "Show Result" action to inspect the individual properties.
""",
	categoryName: "Device"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Get the currently running apps")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[RunningAppAppEntity]> {
		let result = NSWorkspace.shared.runningGUIApps.compactMap { RunningAppAppEntity($0) }
		return .result(value: result)
	}
}

struct RunningAppAppEntity: TransientAppEntity {
	static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Running App")

	@Property(title: "Name")
	var name: String

	@Property(title: "Bundle Identifier")
	var bundleIdentifier: String

	@Property(title: "Process Identifier")
	var processIdentifier: Int

	@Property(title: "URL")
	var url: URL

	@Property(title: "Is Active")
	var isActive: Bool

	@Property(title: "Is Hidden")
	var isHidden: Bool

	@Property(title: "Launch Date")
	var launchDate: Date

	var displayRepresentation: DisplayRepresentation {
		.init(
			title: name,
			subtitle: bundleIdentifier,
			image: nil // TODO
		)
	}
}

extension RunningAppAppEntity {
	init?(_ nsRunningApplication: NSRunningApplication) {
		guard
			let localizedName = app.localizedName,
			let bundleIdentifier = app.bundleIdentifier
		else {
			return nil
		}

		let iconSize = 128.0
		var inImage: INImage?
		if let representation = (app.icon?.representations.first { $0.size.width == iconSize }) {
			let image = NSImage(size: CGSize(width: iconSize, height: iconSize))
			image.addRepresentation(representation)
			inImage = image.toINImage
		}

		self.init()
		self.name = localizedName
		self.bundleIdentifier = bundleIdentifier
		self.processIdentifier = app.processIdentifier
		self.url = app.bundleURL
		self.isActive = app.isActive
		self.isHidden = app.isHidden
		self.launchDate = app.launchDate ?? .now
	}
}
#endif
