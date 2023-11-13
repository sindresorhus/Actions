import SwiftUI

/*
TODO:
- Use `Window` for the WriteTextScreen and other UI on macOS.

NOTES:
- GetUnsplashImage and GetTitleOfURL are temporarily moved into the app target to work around: https://github.com/sindresorhus/Actions/issues/119
*/

@main
struct AppMain: App {
	@StateObject private var appState = AppState.shared

	init() {
		initSentry()
		_ = SSApp.firstLaunchDate
	}

	var body: some Scene {
		WindowIfMacOS(Text(SSApp.name), id: "main") {
			MainScreen()
				.environmentObject(appState)
		}
			#if os(macOS)
			.windowStyle(.hiddenTitleBar)
			.windowResizability(.contentSize)
			.defaultPosition(.center)
			.commands {
				CommandGroup(replacing: .newItem) {}
				CommandGroup(replacing: .help) {
					Link("Website", destination: "https://github.com/sindresorhus/Actions")
					Divider()
					Link("Rate App", destination: "macappstore://apps.apple.com/app/id1545870783?action=write-review")
					// TODO: Doesn't work. (macOS 14.1)
//					ShareLink("Share App", item: "https://apps.apple.com/app/id1545870783")
					Link("More Apps by Me", destination: "macappstore://apps.apple.com/developer/id328077650")
					Divider()
					Button("Send Feedback…") {
						SSApp.openSendFeedbackPage()
					}
				}
			}
			#endif
		#if os(macOS)
		Settings {
			SettingsScreen()
		}
		#endif
	}
}
