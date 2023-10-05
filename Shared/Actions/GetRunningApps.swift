#if os(macOS)
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
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Running App"

	@Property(title: "Name")
	var name: String

	@Property(title: "Bundle Identifier")
	var bundleIdentifier: String

	@Property(title: "Process Identifier")
	var processIdentifier: Int

	@Property(title: "URL")
	var url: URL?

	// TODO: This is not shown. (macOS 13.0)
	@Property(title: "Icon")
	var icon: IntentFile?

	@Property(title: "Icon (128px)")
	var iconSmall: IntentFile?

	@Property(title: "Is Active")
	var isActive: Bool

	@Property(title: "Is Hidden")
	var isHidden: Bool

	@Property(title: "Launch Date")
	var launchDate: Date

	var displayRepresentation: DisplayRepresentation {
		.init(
			title: "\(name)",
			subtitle: "\(bundleIdentifier)",
			image: iconSmall.flatMap { .init(data: $0.data) }
		)
	}
}

extension RunningAppAppEntity {
	init?(_ app: NSRunningApplication) {
		guard
			let localizedName = app.localizedName,
			let bundleIdentifier = app.bundleIdentifier
		else {
			return nil
		}

		func getIcon(size: Double) throws -> IntentFile? {
			guard let representation = (app.icon?.representations.first { $0.size.width == size }) else {
				return nil
			}

			let image = NSImage(size: .init(width: size, height: size))
			image.addRepresentation(representation)
			return try image.toIntentFile()
		}

		self.init()
		self.name = localizedName
		self.bundleIdentifier = bundleIdentifier
		self.processIdentifier = Int(app.processIdentifier)
		self.url = app.bundleURL
		self.icon = try? getIcon(size: 1024)
		self.iconSmall = try? getIcon(size: 128)
		self.isActive = app.isActive
		self.isHidden = app.isHidden
		self.launchDate = app.launchDate ?? .now
	}
}
#endif
