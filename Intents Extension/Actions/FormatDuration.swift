import AppIntents
import ExceptionCatcher

struct FormatDuration: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "FormatDurationIntent"

	static let title: LocalizedStringResource = "Format Duration"

	static let description = IntentDescription(
"""
Formats the input duration to a human-friendly representation.

For example, “9h 41m 30s” or “9:31:30”.

Styles:
- Positional: 9:31:30
- Abbreviated: 9h 41m 30s
- Brief: 9hr 41min 30sec
- Short: 9 hr, 41 min, 30 sec
- Full: 9 hours, 41 minutes, 30 seconds
- Spell Out: nine hours, forty-one minutes, thirty seconds
""",
		categoryName: "Formatting"
	)

	@Parameter(title: "Duration", description: "In seconds.", controlStyle: .field)
	var duration: Double

	@Parameter(title: "Unit Style", default: .full)
	var unitStyle: FormatDurationUnitStyleAppEnum

	@Parameter(title: "Show Seconds", default: true)
	var showSeconds: Bool

	@Parameter(title: "Show Minutes", default: true)
	var showMinutes: Bool

	@Parameter(title: "Show Hours", default: true)
	var showHours: Bool

	@Parameter(title: "Show Days", default: true)
	var showDays: Bool

	@Parameter(title: "Show Months", default: false)
	var showMonths: Bool

	@Parameter(title: "Show Years", default: false)
	var showYears: Bool

	@Parameter(title: "Maximum Unit Count", default: 6, inclusiveRange: (1, 6))
	var maximumUnitCount: Int

	static var parameterSummary: some ParameterSummary {
		Summary("Format \(\.$duration)") {
			\.$unitStyle
			\.$showSeconds
			\.$showMinutes
			\.$showHours
			\.$showDays
			\.$showMonths
			\.$showYears
			\.$maximumUnitCount
		}
	}

	@MainActor
	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		var allowedUnits = NSCalendar.Unit()

		if showSeconds {
			allowedUnits.insert(.second)
		}

		if showMinutes {
			allowedUnits.insert(.minute)
		}

		if showHours {
			allowedUnits.insert(.hour)
		}

		if showDays {
			allowedUnits.insert(.day)
		}

		if showMonths {
			allowedUnits.insert(.month)
		}

		if showYears {
			allowedUnits.insert(.year)
		}

		// TODO: Use the modern formatting API.

		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = unitStyle.toNative
		formatter.allowedUnits = allowedUnits
		formatter.maximumUnitCount = maximumUnitCount

		let result = try ExceptionCatcher.catch {
			formatter.string(from: duration)
		}

		return .result(value: result ?? "") // TODO: Should be `String?`, but that's not supported. (iOS 16.0)
	}
}

enum FormatDurationUnitStyleAppEnum: String, AppEnum {
	case positional
	case abbreviated
	case brief
	case short
	case full
	case spellOut

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Format Duration Unit Style"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.positional: .init(title: "Positional", subtitle: "9:31:30"),
		.abbreviated: .init(title: "Abbreviated", subtitle: "9h 41m 30s"),
		.brief: .init(title: "Brief", subtitle: "9hr 41min 30sec"),
		.short: .init(title: "Short", subtitle: "9 hr, 41 min, 30 sec"),
		.full: .init(title: "Full", subtitle: "9 hours, 41 minutes, 30 seconds"),
		.spellOut: .init(title: "Spell Out", subtitle: "nine hours, forty-one minutes, thirty seconds")
	]
}

extension FormatDurationUnitStyleAppEnum {
	fileprivate var toNative: DateComponentsFormatter.UnitsStyle {
		switch self {
		case .positional:
			.positional
		case .abbreviated:
			.abbreviated
		case .brief:
			.brief
		case .short:
			.short
		case .full:
			.full
		case .spellOut:
			.spellOut
		}
	}
}
