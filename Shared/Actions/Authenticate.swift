import AppIntents
import LocalAuthentication
import SwiftUI

struct Authenticate2: AppIntent {
	static let title: LocalizedStringResource = "Authenticate"

	static let description = IntentDescription(
		"""
		Authenticate the user using Face ID or Touch ID.

		Unlike the old authenticate action, this one directly returns a boolean for whether the authentication succeeded.

		On iOS & visionOS, it needs to momentarily open the Actions app to be able to present the authentication prompt. Afterwards, it goes back to the Shortcuts app. If you were running the shortcut in the background, there is unfortunately no way to go back to the previous app you were in, other than opening the app again from the shortcut.
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
		],
		resultValueName: "Is Authenticated"
	)

	#if canImport(UIKit)
	static let openAppWhenRun = true
	#endif

	@Parameter(
		title: "Open When Finished",
		description: "If provided, opens the URL instead of the Shortcuts app when finished."
	)
	var openURL: URL?

	@Parameter(
		title: "Timeout (seconds)",
		description: "When it times out, it returns “false” as if the authentication failed. On iOS & visionOS, the max timeout is 25 seconds, and it will always timeout after that even if this settings is not specified."
	)
	var timeout: Double?

	@MainActor
	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		// Work around issue with it not showing. (iOS 17.1)
		try await Task.sleep(for: .seconds(0.1))

		#if canImport(UIKit)
		AppState.shared.isFullscreenOverlayPresented = true

		defer {
			Task {
				try? await Task.sleep(for: .seconds(2))
				AppState.shared.isFullscreenOverlayPresented = false
			}
		}

		if timeout == nil {
			timeout = 25
		}
		#endif

		let result: Bool = await {
			do {
				let context = LAContext()

				if let timeout {
					delay(.seconds(timeout)) {
						context.invalidate()
					}
				}

				try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticate the shortcut")
				return true
			} catch {
				return false
			}
		}()

		if let openURL {
			try await openURL.openAsyncOrOpenShortcutsApp()
		} else {
			#if canImport(UIKit)
			ShortcutsApp.open()
			#endif
		}

		return .result(value: result)
	}
}

struct Authenticate: AppIntent {
	static let title: LocalizedStringResource = "Authenticate (Legacy)"

	static let description = IntentDescription(
		"""
		Authenticate the user using Face ID or Touch ID.

		IMPORTANT: Use the “Authenticate” action instead.

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

	static let openAppWhenRun = true

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
		// Work around issue with it not showing. (iOS 17.1)
		try await Task.sleep(for: .seconds(0.1))

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

			#if os(macOS)
			SSApp.quit()
			#endif
		}

		return .result()
	}
}
