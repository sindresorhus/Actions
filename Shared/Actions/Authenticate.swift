import AppIntents
import LocalAuthentication
import SwiftUI

struct Authenticate: AppIntent {
	static let title: LocalizedStringResource = "Authenticate"

	static let description = IntentDescription(
"""
Authenticate the user using Face ID or Touch ID.

IMPORTANT: The result is copied to the clipboard as the text “true” or “false”. Add the “Wait to Return” and “Get Clipboard” actions after this one. Use the “If” action to decide what to do with the result.

Q: Why can't it return the value directly?
A: The system authentication feature can only be triggered from an app, so the action has to send you to the Actions app, which shows it, and then sends you back to the shortcut.
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

	// TODO: Try again when targeting iOS 17.
	// AppIntents cannot handle this conditional. (Xcode 14.1)
//	#if canImport(UIKit)
	static let openAppWhenRun = true
//	#endif

	@Parameter(
		title: "Open When Finished",
		description: "If provided, opens the URL instead of the Shortcuts app when finished."
	)
	var openURL: URL?

	@Parameter(
		title: "Timeout (seconds)",
		description: "When it times out, it returns “false” as if the authentication failed."
	)
	var timeout: Double?

	@MainActor
	func perform() async throws -> some IntentResult {
		AppState.shared.isFullscreenOverlayPresented = true

		#if canImport(UIKit)
		defer {
			Task {
				try? await Task.sleep(for: .seconds(2))
				AppState.shared.isFullscreenOverlayPresented = false
			}
		}
		#endif

		do {
			let context = LAContext()

			if let timeout {
				delay(.seconds(timeout)) {
					context.invalidate()
				}
			}

			try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticate the shortcut")
			XPasteboard.general.stringForCurrentHostOnly = "true"
		} catch {
			XPasteboard.general.stringForCurrentHostOnly = "false"
		}

		if let openURL {
			try await openURL.openAsyncOrOpenShortcutsApp()
		} else {
			// This makes the “Wait to Return” action work.
			#if os(macOS)
			NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.shortcuts").first?.hide()
			#endif

			ShortcutsApp.open()

			// TODO: This can be removed when we disable the `static let openAppWhenRun = true` for macOS again.
			#if os(macOS)
			SSApp.quit()
			#endif
		}

		return .result()
	}
}
