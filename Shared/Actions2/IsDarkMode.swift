import AppIntents

struct IsDarkMode: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "IsDarkModeIntent"

    static let title: LocalizedStringResource = "Is Dark Mode On"

	static let description = IntentDescription(
		"Returns whether dark mode is enabled on the device.",
		categoryName: "Device"
	)

    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		.result(value: SSApp.isDarkMode)
    }
}
