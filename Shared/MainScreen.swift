import SwiftUI

struct MainScreen: View {
	@Environment(\.scenePhase) private var scenePhase
	@EnvironmentObject private var appState: AppState
	@State private var error: Error?
	@State private var isSettingsPresented = false

	var body: some View {
		NavigationStack {
			VStack {
				WelcomeScreen()
			}
				.alert(error: $error)
				#if os(macOS)
				.frame(width: 440)
				.fixedSize()
				.windowLevel(.floating)
				.windowCenterOnAppear()
				#endif
				.fullScreenCoverOrSheetIfMacOS(item: $appState.writeTextData) {
					WriteTextScreen(data: $0)
				}
				.fullScreenCoverOrSheetIfMacOS(item: $appState.chooseFromListData) {
					ChooseFromListScreen(data: $0)
				}
				.alert2(
					title: \.title,
					message: { $0.message?.nilIfEmptyOrWhitespace },
					presenting: $appState.askForTextData
				) { data in
					AskForTextScreen(data: data)
				}
				.overlay {
					if appState.isFullscreenOverlayPresented {
						// We use this instead of `.fullScreenCover` as there's no way to turn off its animation.
						Color.legacyBackground
							.ignoresSafeArea()
					}
				}
				#if canImport(UIKit)
				.documentScanner(isPresented: $appState.isDocumentScannerPresented) {
					switch $0 {
					case .success(let images):
						UIPasteboard.general.images = images
						ShortcutsApp.open()
					case .failure(let error):
						self.error = error
					}
				}
				.onChange(of: scenePhase) {
					if $0 != .active {
						appState.isFullscreenOverlayPresented = false
					}
				}
				#endif
				.task {
					debug()
				}
				.sheet(isPresented: $isSettingsPresented) {
					SettingsScreen()
				}
				.toolbar {
					#if canImport(UIKit)
					ToolbarItemGroup(placement: .topBarTrailing) {
						Button("Settings", systemImage: "gear") {
							isSettingsPresented = true
						}
							.keyboardShortcut(",")
					}
					#endif
				}
		}
	}

	private func debug() {
		#if DEBUG
		// For testing the “Write or Edit Text” action.
//		appState.writeTextData = .init(
//			title: "Test",
//			text: ""
//		)
//
		// For testing the “Choose from List Extended” action.
//		appState.chooseFromListData = .init(
//			list: [
//				"Foo",
//				"Bar"
//			],
//			title: "Test",
//			selectMultiple: false,
//			selectAllInitially: false,
//			allowCustomItems: false,
//			timeoutReturnValue: .nothing
//		)
//
//		appState.askForTextData = .init(
//			text: "X",
//			title: "X",
//			timeoutReturnValue: "X"
//		)
		#endif
	}
}

#Preview {
	MainScreen()
}
