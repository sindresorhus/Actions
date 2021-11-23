import SwiftUI

struct MainScreen: View {
	@State private var writeTextData: WriteTextScreen.Data?
	@EnvironmentObject private var appState: AppState

	var body: some View {
		VStack {
			WelcomeScreen()
		}
			#if canImport(AppKit)
			.frame(width: 440)
			.windowLevel(.floating)
			.onChange(of: appState.userActivity) {
				guard let someIntent = $0?.interaction?.intent else {
					return // swiftlint:disable:this implicit_return
				}

				if let intent = someIntent as? WriteTextIntent {
					handleWriteTextIntent(intent)
				}
			}
			#endif
			.fullScreenCoverOrSheetIfMacOS(item: $writeTextData) {
				WriteTextScreen(data: $0)
			}
			.onContinueIntent(WriteTextIntent.self) { intent, _ in
				handleWriteTextIntent(intent)
			}
			#if canImport(UIKit)
			.onContinueIntent(HideShortcutsAppIntent.self) { _, _ in
				SSApp.moveToBackground()
			}
			#endif
			.task {
				// For testing the “Write or Edit Text” action.
//				#if DEBUG
//				writeTextData = .init(
//					title: "Test",
//					text: ""
//				)
//				#endif
			}
	}

	private func handleWriteTextIntent(_ intent: WriteTextIntent) {
		writeTextData = .init(
			title: intent.editorTitle,
			text: intent.text?.nilIfEmptyOrWhitespace ?? ""
		)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		MainScreen()
	}
}
