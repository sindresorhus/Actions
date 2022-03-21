import SwiftUI

struct MainScreen: View {
	@EnvironmentObject private var appState: AppState
	@State private var writeTextData: WriteTextScreen.Data?
	@State private var chooseFromListData: ChooseFromListScreen.Data?
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

				if let intent = someIntent as? ChooseFromListExtendedIntent {
					handleChooseFromListExtendedIntent(intent)
				}
			}
			#endif
			.fullScreenCoverOrSheetIfMacOS(item: $writeTextData) {
				WriteTextScreen(data: $0)
			}
			.fullScreenCoverOrSheetIfMacOS(item: $chooseFromListData) {
				ChooseFromListScreen(data: $0)
			}
			.onContinueIntent(WriteTextIntent.self) { intent, _ in
				handleWriteTextIntent(intent)
			}
			.onContinueIntent(ChooseFromListExtendedIntent.self) { intent, _ in
				#if canImport(UIKit)
				UIView.setAnimationsEnabled(false)
				#endif

				handleChooseFromListExtendedIntent(intent)
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
				#if DEBUG
				// For testing the “Write or Edit Text” action.
//				writeTextData = .init(
//					title: "Test",
//					text: ""
//				)

				// For testing the “Choose from List Extended” action.
//				chooseFromListData = .init(
//					list: [
//						"Foo",
//						"Bar"
//					],
//					title: "Test",
//					selectMultiple: false,
//					selectAllInitially: false,
//					allowCustomItems: false,
//					timeoutReturnValue: .nothing
//				)
				#endif
			}
	}

	private func handleWriteTextIntent(_ intent: WriteTextIntent) {
		writeTextData = .init(
			title: intent.editorTitle,
			text: intent.text?.nilIfEmptyOrWhitespace ?? ""
		)
	}

	private func handleChooseFromListExtendedIntent(_ intent: ChooseFromListExtendedIntent) {
		chooseFromListData = .init(
			list: intent.list ?? [],
			title: intent.prompt?.nilIfEmptyOrWhitespace,
			selectMultiple: intent.selectMultiple as? Bool ?? false,
			selectAllInitially: intent.selectAllInitially as? Bool ?? false,
			allowCustomItems: intent.allowCustomItems as? Bool ?? false,
			timeout: (intent.useTimeout as? Bool) == true ? (intent.timeout as? TimeInterval) : nil,
			timeoutReturnValue: intent.timeoutReturnValue
		)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		MainScreen()
	}
}
