import AppIntents
import CoreBluetooth

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

		NOTE: The RSSI and signal strength are available for only one of the two AirPods. If it shows RSSI of 0, try the identifier of the other AirPods device.
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

		let services = try await peripheral.discoverServices().map(\.uuid)
		let knownServices = (services + CBCentralManager.commonServices).removingDuplicates()
		let connectedDevices = central.retrieveConnectedPeripherals(withServices: knownServices)

		let rssi: Double = try await {
			do {
				return try await peripheral.readRSSI().doubleValue
			} catch {
				// One of the two AirPods devices fail to retrieve RSSI for some reason.
				if (error as NSError).code == 13 /* kBluetoothHCIErrorHostRejectedLimitedResources */ {
					return 0
				}

				throw error
			}
		}()

		if
			!wasConnected,
			peripheral.state == .connected
		{
			try await central.cancelPeripheralConnection(peripheral)
		}

		let entity = BluetoothDevice_AppEntity(
			peripheral: peripheral,
			advertisementData: [:],
			rssi: Int(rssi),
			isConnected: connectedDevices.contains { $0.identifier == peripheral.identifier },
			services: services
		)

		return .result(value: entity)
	}
}
