import SwiftUI

@main
struct AppMain: App {
	@XApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	@StateObject private var appState = AppState.shared

	var body: some Scene {
		WindowGroup {
			MainScreen()
				.environmentObject(appState)
		}
			#if canImport(AppKit)
			.windowStyle(.hiddenTitleBar)
			.commands {
				CommandGroup(replacing: .newItem) {}
				CommandGroup(replacing: .help) {
					Link("Website", destination: "https://github.com/sindresorhus/Actions")
					Link("Rate on the App Store", destination: "macappstore://apps.apple.com/app/id1545870783?action=write-review")
					Link("More Apps by Me", destination: "macappstore://apps.apple.com/developer/id328077650")
					Divider()
					Button("Send Feedback…") {
						SSApp.openSendFeedbackPage()
					}
				}
			}
			#endif
	}
}

@MainActor
final class AppDelegate: NSObject, XApplicationDelegate {
	#if canImport(AppKit)
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

	// `.onContinueUserActivity` does not seem to work on macOS 12.0.1.
	func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
		AppState.shared.userActivity = userActivity
		return true
	}
	#endif
}
