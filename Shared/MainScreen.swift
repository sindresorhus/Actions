import SwiftUI

struct MainScreen: View {
	@EnvironmentObject private var appState: AppState
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
			#endif
			.fullScreenCoverOrSheetIfMacOS(item: $appState.writeTextData) {
				WriteTextScreen(data: $0)
			}
			.fullScreenCoverOrSheetIfMacOS(item: $appState.chooseFromListData) {
				ChooseFromListScreen(data: $0)
			}
			#if canImport(UIKit)
			.documentScanner(isPresented: $appState.isDocumentScannerPresented) {
				switch $0 {
				case .success(let images):
					UIPasteboard.general.images = images
				case .failure(let error):
					self.error = error
				}
			}
			.onChange(of: appState.isDocumentScannerPresented) {
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
}

struct MainScreen_Previews: PreviewProvider {
	static var previews: some View {
		MainScreen()
	}
}
