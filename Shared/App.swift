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
		SSApp.initSentry("https://12c8785fd2924c9a9c0f6bb1d91be79e@o844094.ingest.sentry.io/6041555")
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
