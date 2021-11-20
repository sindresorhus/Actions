import Foundation

@MainActor
final class GetBatteryStateIntentHandler: NSObject, GetBatteryStateIntentHandling {
	func handle(intent: GetBatteryStateIntent) async -> GetBatteryStateIntentResponse {
		let response = GetBatteryStateIntentResponse(code: .success, userActivity: nil)

		func isMatch() -> Bool {
			switch intent.state {
			case .unknown:
				return false
			case .unplugged:
				return Device.batteryState == .unplugged
			case .charging:
				return Device.batteryState == .charging
			case .full:
				return Device.batteryState == .full
			}
		}

		response.result = isMatch() as NSNumber

		return response
	}
}
