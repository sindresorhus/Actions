import Foundation
import ExceptionCatcher

@MainActor
final class FormatDurationIntentHandler: NSObject, FormatDurationIntentHandling {
	func handle(intent: FormatDurationIntent) async -> FormatDurationIntentResponse {
		let response = FormatDurationIntentResponse(code: .success, userActivity: nil)

		guard let duration = intent.duration as? TimeInterval else {
			return response
		}

		let showSeconds = intent.showSeconds as? Bool ?? true
		let showMinutes = intent.showMinutes as? Bool ?? true
		let showHours = intent.showHours as? Bool ?? true
		let showDays = intent.showDays as? Bool ?? true
		let showMonths = intent.showMonths as? Bool ?? true
		let showYears = intent.showYears as? Bool ?? true

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

		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = intent.unitStyle.toNative
		formatter.allowedUnits = allowedUnits
		formatter.maximumUnitCount = intent.maximumUnitCount as? Int ?? 6

		do {
			try ExceptionCatcher.catch {
				response.result = formatter.string(from: duration)
			}
		} catch {
			return .failure(failure: error.presentableMessage)
		}

		return response
	}
}

extension FormatDurationUnitStyle {
	fileprivate var toNative: DateComponentsFormatter.UnitsStyle {
		switch self {
		case .unknown:
			return .full
		case .positional:
			return .positional
		case .abbreviated:
			return .abbreviated
		case .brief:
			return .brief
		case .short:
			return .short
		case .full:
			return .full
		case .spellOut:
			return .spellOut
		}
	}
}
