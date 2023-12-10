import AppIntents

struct GetBatteryStateIntent: AppIntent {
	static let title: LocalizedStringResource = "Get Battery State"

	static let description = IntentDescription(
		"Returns whether the device's battery is unplugged, charging, or full.",
		categoryName: "Device",
		resultValueName: "Battery State"
	)

	@Parameter(title: "State", default: .charging)
	var state: BatteryStateTypeAppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Is the battery \(\.$state)?")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		let result = switch state {
			case .unplugged:
				Device.batteryState == .unplugged
			case .charging:
				Device.batteryState == .charging
			case .full:
				Device.batteryState == .full
			}

		return .result(value: result)
	}
}

enum BatteryStateTypeAppEnum: String, AppEnum {
	case unplugged
	case charging
	case full

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Battery State Type"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.unplugged: "unplugged",
		.charging: "charging",
		.full: "full"
	]
}
