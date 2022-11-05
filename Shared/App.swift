import SwiftUI

/*
TODO:
- Use `Window` for the WriteTextScreen and other UI on macOS.
*/

@main
struct AppMain: App {
	@XApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	@StateObject private var appState = AppState.shared

	init() {
		initSentry()
	}

	var body: some Scene {
		WindowGroup {
			MainScreen()
				.environmentObject(appState)
		}
			#if canImport(AppKit)
			.windowStyle(.hiddenTitleBar)
			.windowResizability(.contentSize)
			.defaultPosition(.center)
			.commands {
				CommandGroup(replacing: .newItem) {}
				CommandGroup(replacing: .help) {
					Link("Website", destination: "https://github.com/sindresorhus/Actions")
					Divider()
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
	#endif
}
