import AppIntents
import LocalAuthentication

struct Authenticate: AppIntent {
	static let title: LocalizedStringResource = "Authenticate"

	static let description = IntentDescription(
"""
Authenticate the user using Face ID or Touch ID.

IMPORTANT: The result is copied to the clipboard as the text “true” or “false”. Add the “Wait to Return” and “Get Clipboard” actions after this one. Use the “If” action to decide what to do with the result.
""",
		categoryName: "Device",
		searchKeywords: [
			"face id",
			"touch id",
			"faceid",
			"touchid",
			"biometry",
			"password",
			"passcode"
		]
	)

	static let openAppWhenRun = true

	@Parameter(
		title: "Open When Finished",
		description: "If provided, opens the URL instead of the Shortcuts app when finished."
	)
	var openURL: URL?

	@MainActor
	func perform() async throws -> some IntentResult {
		AppState.shared.isFullscreenOverlayPresented = true

		defer {
			Task {
				try? await Task.sleep(seconds: 2)
				AppState.shared.isFullscreenOverlayPresented = false
			}
		}

		do {
			let context = LAContext()
			try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticate the shortcut")
			XPasteboard.general.string = "true"
		} catch {
			XPasteboard.general.string = "false"
		}

		if let openURL {
			try await openURL.openAsyncOrOpenShortcutsApp()
		} else {
			ShortcutsApp.open()
		}

		return .result()
	}
}
