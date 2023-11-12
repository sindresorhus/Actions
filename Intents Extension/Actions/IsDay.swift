import AppIntents

struct IsDay: AppIntent {
	static let title: LocalizedStringResource = "Is Day"

	static let description = IntentDescription(
		"""
		Check if the input date corresponds to a specific weekday, today, tomorrow, yesterday, or falls on a weekend.
		""",
		categoryName: "Date"
	)

	@Parameter(
		title: "Day",
		description: "The date to check. Write “today” to check today.",
		kind: .date
	)
	var day: Date

	@Parameter(title: "Type", default: .monday)
	var type: DayType_AppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Is \(\.$day) \(\.$type)?")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		let result: Bool = {
			let calendar = Calendar.current

			func isWeekday(_ weekday: Locale.Weekday) -> Bool {
				calendar.weekday(for: day) == weekday
			}

			switch type {
			case .monday:
				return isWeekday(.monday)
			case .tuesday:
				return isWeekday(.tuesday)
			case .wednesday:
				return isWeekday(.wednesday)
			case .thursday:
				return isWeekday(.thursday)
			case .friday:
				return isWeekday(.friday)
			case .saturday:
				return isWeekday(.saturday)
			case .sunday:
				return isWeekday(.sunday)
			case .today:
				return calendar.isDateInToday(day)
			case .tomorrow:
				return calendar.isDateInTomorrow(day)
			case .yesterday:
				return calendar.isDateInYesterday(day)
			case .weekend:
				return calendar.isDateInWeekend(day)
			case .weekday:
				return !calendar.isDateInWeekend(day)
			case .currentWeek:
				return calendar.isDate(day, equalTo: .now, toGranularity: .weekOfYear)
			case .currentMonth:
				return calendar.isDate(day, equalTo: .now, toGranularity: .month)
			case .currentYear:
				return calendar.isDate(day, equalTo: .now, toGranularity: .year)
			}
		}()

		return .result(value: result)
	}
}

enum DayType_AppEnum: String, AppEnum {
	case monday
	case tuesday
	case wednesday
	case thursday
	case friday
	case saturday
	case sunday
	case today
	case tomorrow
	case yesterday
	case weekend
	case weekday
	case currentWeek
	case currentMonth
	case currentYear

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Day Type"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.monday: "Monday",
		.tuesday: "Tuesday",
		.wednesday: "Wednesday",
		.thursday: "Thursday",
		.friday: "Friday",
		.saturday: "Saturday",
		.sunday: "Sunday",
		.today: "Today",
		.tomorrow: "Tomorrow",
		.yesterday: "Yesterday",
		.weekend: "Weekend",
		.weekday: "Weekday",
		.currentWeek: "In the current week",
		.currentMonth: "In the current month",
		.currentYear: "In the current year"
	]
}
