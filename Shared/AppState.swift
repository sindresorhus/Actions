import SwiftUI

@MainActor
final class AppState: ObservableObject {
	static let shared = AppState()

	@Published var isDocumentScannerPresented = false
	@Published var writeTextData: WriteTextScreen.Data?
	@Published var chooseFromListData: ChooseFromListScreen.Data?
}
