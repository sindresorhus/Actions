import SwiftUI

@MainActor
final class AppState: ObservableObject {
	static let shared = AppState()

	@Published var userActivity: NSUserActivity?
}

@main
struct ActionsApp: App {
	#if canImport(AppKit)
	@NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	#endif

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

#if canImport(AppKit)
@MainActor
private final class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

	// `.onContinueUserActivity` does not seem to work on macOS 12.0.1.
	func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
		AppState.shared.userActivity = userActivity
		return true
	}
}
#endif
