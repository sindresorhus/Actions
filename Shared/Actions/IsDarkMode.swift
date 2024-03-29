import AppIntents

struct IsDarkModeIntent: AppIntent {
    static let title: LocalizedStringResource = "Is Dark Mode On"

	static let description = IntentDescription(
		"""
		Returns whether dark mode is enabled on the device.

		NOTE: This always returns "“false” on visionOS.
		""",
		categoryName: "Device"
	)

	@MainActor // Tries to work around stale value.
	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		// Tries to work around stale value.
		try? await Task.sleep(for: .seconds(0.1))

		defer {
			Task {
				try? await Task.sleep(for: .seconds(0.1))

				// iOS does not update the trait collection of apps/extensions that are running in the background, which we are. iOS sometimes reuses the app/extension when running a shortcut a second time, which means it would show outdated values if the dark mode state changed in the meantime. We ensure it always gets a fresh instance by force-quitting the app. Force-quitting the extension made it hang, so it's also important that it's an in-app intent.
				exit(0)
			}
		}

		return .result(value: SSApp.isDarkMode)
    }
}
