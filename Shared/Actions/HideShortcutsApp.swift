import AppIntents
import SwiftUI

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

	// AppIntents cannot handle this conditional. (Xcode 14.1)
//	#if canImport(UIKit)
	static let openAppWhenRun = true
//	#endif

	static var parameterSummary: some ParameterSummary {
		Summary("Hide the Shortcuts app")
	}

	func perform() async throws -> some IntentResult {
		#if os(macOS)
		NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.shortcuts").first?.hide()
		#else
		SSApp.moveToBackground()
		#endif

		// TODO: This can be removed when we disable the `static let openAppWhenRun = true` for macOS again.
		#if os(macOS)
		SSApp.quit()
		#endif

		return .result()
	}
}
