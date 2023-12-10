import AppIntents
import LocalAuthentication
import SwiftUI

struct Authenticate2: AppIntent {
	static let title: LocalizedStringResource = "Authenticate (New)"

	static let description = IntentDescription(
		"""
		Authenticate the user using Face ID or Touch ID.

		Unlike the old authenticate action, this one directly returns a boolean for whether the authentication succeeded.

		On iOS, it needs to momentarily open the Actions app to be able to present the authentication prompt.
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
		description: "When it times out, it returns “false” as if the authentication failed. On iOS, the max timeout is 25 seconds, and it will always timeout after that even if this settings is not specified."
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
