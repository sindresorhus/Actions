import AppIntents

struct GetActionsVersion: AppIntent {
	static let title: LocalizedStringResource = "Get Actions App Version"

	static let description = IntentDescription(
		"""
		Returns the current version of the Actions app.

		The build number is an increasing integer and can be used to do version checks.
		""",
		categoryName: "Meta",
		resultValueName: "Actions App Version"
	)

	static var parameterSummary: some ParameterSummary {
		Summary("Get the version of the Actions app")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<ActionsVersionAppEntity> {
		.result(value: .init())
	}
}

struct ActionsVersionAppEntity: TransientAppEntity {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Actions App Version"

	@Property(title: "Version")
	var version: String

	@Property(title: "Build")
	var build: Int

	var displayRepresentation: DisplayRepresentation {
		.init(
			title: "\(version)",
			subtitle: "\(build)"
		)
	}

	init() {
		self.version = SSApp.version
		self.build = SSApp.build
	}
}
