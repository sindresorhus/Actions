import AppIntents

struct GetDeviceDetailsExtended: AppIntent {
	static let title: LocalizedStringResource = "Get Device Details (Extended)"

	static let description = IntentDescription(
		"""
		Get details about the device.

		This is an extension to the built-in “Get Device Details” action.

		You can access the individual values.

		Tip: Use the “Format Duration” action to format the “Uptime” and “Duration since boot” values.
		""",
		categoryName: "Device",
		searchKeywords: [
			"system",
			"info",
			"information",
			"uptime",
			"boot",
			"processor",
			"cpu",
			"memory",
			"hostname"
		],
		resultValueName: "Device Details"
	)

	@MainActor
	func perform() async throws -> some IntentResult & ReturnsValue<DeviceDetailsAppEntity> {
		.result(value: .init())
	}
}

struct DeviceDetailsAppEntity: TransientAppEntity {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Device Details"

	@Property(title: "Uptime (not including sleep)")
	var uptime: Measurement<UnitDuration>

	@Property(title: "Duration since boot")
	var durationSinceBoot: Measurement<UnitDuration>

	@Property(title: "Active processor count")
	var activeProcessorCount: Int

	@Property(title: "Physical memory (bytes)")
	var physicalMemory: Int

	@Property(title: "Hostname")
	var hostname: String

	var displayRepresentation: DisplayRepresentation {
		.init(
			title:
				"""
				Uptime: \(uptime.toDuration.formatted(.units(allowed: [.days, .hours, .minutes], width: .wide)))
				Duration since boot: \(durationSinceBoot.toDuration.formatted(.units(allowed: [.days, .hours, .minutes], width: .wide)))
				Active processor count: \(activeProcessorCount)
				Physical memory: \(physicalMemory.formatted(.byteCount(style: .memory)))
				Hostname: \(hostname)
				"""
		)
	}

	init() {
		self.uptime = Device.uptime.toMeasurement
		self.durationSinceBoot = Device.uptimeIncludingSleep.toMeasurement
		self.activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount
		self.physicalMemory = Int(ProcessInfo.processInfo.physicalMemory)
		self.hostname = ProcessInfo.processInfo.hostName
	}
}
