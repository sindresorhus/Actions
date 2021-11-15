import Foundation

@MainActor
final class IsBluetoothOnIntentHandler: NSObject, IsBluetoothOnIntentHandling {
	func handle(intent: IsBluetoothOnIntent) async -> IsBluetoothOnIntentResponse {
		let response = IsBluetoothOnIntentResponse(code: .success, userActivity: nil)

		do {
			response.result = try await Bluetooth.isOn() as NSNumber
		} catch {
			return .failure(failure: error.presentableMessage)
		}

		return response
	}
}
