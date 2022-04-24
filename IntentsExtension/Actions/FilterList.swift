import Foundation

@MainActor
final class FilterListIntentHandler: NSObject, FilterListIntentHandling {
	func handle(intent: FilterListIntent) async -> FilterListIntentResponse {
		let response = FilterListIntentResponse(code: .success, userActivity: nil)

		guard var list = intent.list else {
			return response
		}

		// We just pass the list through if there is no condition.
		guard var matchText = intent.matchText?.nilIfEmptyOrWhitespace else {
			response.result = list
			return response
		}

		let shouldKeep = intent.shouldKeep?.boolValue ?? true
		let caseSensitive = intent.caseSensitive?.boolValue ?? false

		if !caseSensitive {
			matchText = matchText.lowercased()
		}

		func isMatch(_ item: String) throws -> Bool {
			let item = caseSensitive ? item : item.lowercased()

			switch intent.condition {
			case .unknown:
				return false
			case .contains:
				return item.contains(matchText)
			case .beginsWith:
				return item.hasPrefix(matchText)
			case .endsWith:
				return item.hasSuffix(matchText)
			case .regex:
				return try NSRegularExpression(pattern: matchText).matches(item)
			case .is:
				return item == matchText
			}
		}

		do {
			list = try list.filter { shouldKeep ? try isMatch($0) : try !isMatch($0) }
		} catch {
			return .failure(failure: error.presentableMessage)
		}

		if
			intent.shouldLimit?.boolValue == true,
			let limit = intent.limit as? Int
		{
			list = Array(list.prefix(limit))
		}

		response.result = list

		return response
	}
}
