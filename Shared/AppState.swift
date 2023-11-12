import SwiftUI
import CoreBluetooth
import CoreLocation

@MainActor
final class AppState: ObservableObject {
	static let shared = AppState()

	@Published var isDocumentScannerPresented = false
	@Published var writeTextData: WriteTextScreen.Data?
	@Published var chooseFromListData: ChooseFromListScreen.Data?
	@Published var askForTextData: AskForTextScreen.Data?
	@Published var isFullscreenOverlayPresented = false
	@Published var fullscreenMessage: String?

	private init() {
		// TODO: Check if it shows a prompt when we move the action back to being in an extension.
		// We have to request the permission in the app as it no longer (with iOS 16.1) a prompt when running the action. The prompt actually shows when we switch back to the app. So it seems it's shown in the incorrect scene.
		#if canImport(UIKit)
		askForBluetoothAccessIfNeeded()
		CLLocationManager().requestWhenInUseAuthorization()
		#endif
	}

	private func askForBluetoothAccessIfNeeded() {
		guard CBCentralManager.authorization == .notDetermined else {
			return
		}

		Task {
			try? await Bluetooth.isOn()
		}
	}
}
