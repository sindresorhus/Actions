import SwiftUI

struct MainScreen: View {
	@EnvironmentObject private var appState: AppState
	@State private var writeTextData: WriteTextScreen.Data?
	@State private var isDocumentScannerPresented = false
	@State private var error: Error?

	var body: some View {
		VStack {
			WelcomeScreen()
		}
			.alert(error: $error)
			#if canImport(AppKit)
			.frame(width: 440)
			.windowLevel(.floating)
			.fixedSize()
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
			.onContinueIntent(HapticFeedbackIntent.self) { intent, _ in
				Device.hapticFeedback(intent.type.toNative)
				ShortcutsApp.open()
			}
			.onContinueIntent(ScanDocumentsIntent.self) { _, _ in
				UIView.setAnimationsEnabled(false)
				isDocumentScannerPresented = true
			}
			.documentScanner(isPresented: $isDocumentScannerPresented) {
				switch $0 {
				case .success(let images):
					UIPasteboard.general.images = images
				case .failure(let error):
					self.error = error
				}
			}
			.onChange(of: isDocumentScannerPresented) {
				if !$0 {
					UIView.setAnimationsEnabled(true)
					ShortcutsApp.open()
				}
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
