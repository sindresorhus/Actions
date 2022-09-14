import AppIntents

struct HideShortcutsApp: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "HideShortcutsAppIntent"

	static let title: LocalizedStringResource = "Hide Shortcuts App"

	static let description = IntentDescription(
"""
Hides the Shortcuts app.

This is useful for making cross-platform shortcuts. If you just target iOS, use the built-in “Go to Home Screen” action instead.
""",
	categoryName: "Utility"
	)

	static let openAppWhenRun = true

	static var parameterSummary: some ParameterSummary {
		Summary("Hide the Shortcuts app")
	}

	func perform() async throws -> some IntentResult {
		SSApp.moveToBackground()
		return .result()
	}
}
