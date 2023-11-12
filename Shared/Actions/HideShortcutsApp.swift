import AppIntents
import SwiftUI

struct HideShortcutsAppIntent: AppIntent {
	static let title: LocalizedStringResource = "Hide Shortcuts App"

	static let description = IntentDescription(
		"""
		Hides the Shortcuts app.

		This is useful for making cross-platform shortcuts. If you just target iOS, use the built-in “Go to Home Screen” action instead.
		""",
		categoryName: "Utility",
		searchKeywords: [
			"go",
			"home",
			"screen"
		]
	)

	#if canImport(UIKit)
	static let openAppWhenRun = true
	#endif

	static var parameterSummary: some ParameterSummary {
		Summary("Hide the Shortcuts app")
	}

	func perform() async throws -> some IntentResult {
		#if os(macOS)
		NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.shortcuts").first?.hide()
		#else
		SSApp.moveToBackground()
		#endif

		return .result()
	}
}
