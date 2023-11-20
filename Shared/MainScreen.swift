import SwiftUI

struct MainScreen: View {
	@Environment(\.scenePhase) private var scenePhase
	@Environment(\.requestReview) private var requestReview
	@EnvironmentObject private var appState: AppState
	@AppStorage("hasRequestedReview") private var hasRequestedReview = false
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
				.overlay {
					if let message = appState.fullscreenMessage {
						// We use this instead of `.fullScreenCover` as there's no way to turn off its animation.
						Color.legacyBackground
							.ignoresSafeArea()
							.overlay {
								VStack(spacing: 32) {
									ProgressView()
									Text(message)
								}
							}
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
					if scenePhase != .active {
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
					if
						!appState.isFullscreenOverlayPresented,
						appState.fullscreenMessage == nil
					{
						ToolbarItemGroup(placement: .topBarTrailing) {
							Button("Settings", systemImage: "gear") {
								isSettingsPresented = true
							}
							.keyboardShortcut(",")
						}
					}
					#endif
				}
				.task {
					requestReviewIfNeeded()
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

	private func requestReviewIfNeeded() {
		let sevenDays = 7.0 * 24.0 * 60.0 * 60.0

		guard
			!SSApp.isFirstLaunch,
			hasRequestedReview,
			SSApp.firstLaunchDate < Date.now.addingTimeInterval(-sevenDays)
		else {
			return
		}

		requestReview()
		hasRequestedReview = true
	}
}

#Preview {
	MainScreen()
}
