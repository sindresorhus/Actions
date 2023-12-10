import AppIntents

struct GetBluetoothDevice: AppIntent {
	static let title: LocalizedStringResource = "Get Bluetooth Device"

	static let description = IntentDescription(
		"""
		Returns the Bluetooth device with the given identifier if it's in range and discoverable.

		This can be useful to check if a certain Bluetooth device is connected or in range and perform a specific action based on that.

		Use the “Get Bluetooth Devices” to discover devices and their identifiers.

		NOTE: You need to allow the Bluetooth permission in the main app before using this action.

		NOTE: You need to have been connected to the device at least once before.

		NOTE: The `transmitPowerLevel` property is not provided for this action.
		""",
		categoryName: "Bluetooth",
		searchKeywords: [
			"ble",
			"peripheral"
		],
		resultValueName: "Bluetooth Device"
	)

	@Parameter(
		title: "Device Identifier",
		description: "The UUID of the Bluetooth device."
	)
	var deviceIdentifier: String

	@Parameter(
		title: "Timeout (seconds)",
		description: "The duration to wait before giving up connecting to the device.",
		default: 2,
		inclusiveRange: (0, 9999)
	)
	var timeout: Double

	static var parameterSummary: some ParameterSummary {
		Summary("Get Bluetooth Device with Identifier \(\.$deviceIdentifier)") {
			\.$timeout
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<BluetoothDevice_AppEntity?> {
		guard let uuid = UUID(uuidString: deviceIdentifier) else {
			throw "Invalid device identifier. It must be a valid UUID.".toError
		}

		let central = try await getBluetoothCentral()

		guard let peripheral = central.retrievePeripherals(withIdentifiers: [uuid]).first else {
			return .result(value: nil)
		}

		let wasConnected = peripheral.state == .connected

		do {
			try await withTimeout(.seconds(timeout)) {
				_ = try await central.connect(peripheral)
			}
		} catch is TimeoutError {
			return .result(value: nil)
		}

		let rssi = try await peripheral.readRSSI().doubleValue

		if
			!wasConnected,
			peripheral.state == .connected
		{
			try await central.cancelPeripheralConnection(peripheral)
		}

		let entity = BluetoothDevice_AppEntity(
			peripheral: peripheral,
			advertisementData: [:],
			rssi: rssi
		)

		return .result(value: entity)
	}
}
