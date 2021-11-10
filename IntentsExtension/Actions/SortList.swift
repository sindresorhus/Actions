import Foundation

extension SortType {
	fileprivate init(_ intentSortType: SortType_) {
		switch intentSortType {
		case .unknown, .natural:
			self = .natural
		case .localized:
			self = .localized
		case .localizedCaseInsensitive:
			self = .localizedCaseInsensitive
		}
	}
}

@MainActor
final class SortListIntentHandler: NSObject, SortListIntentHandling {
	func resolveSortType(for intent: SortListIntent) async -> SortType_ResolutionResult {
		.success(with: intent.sortType == .unknown ? .natural : intent.sortType)
	}

	func handle(intent: SortListIntent) async -> SortListIntentResponse {
		let response = SortListIntentResponse(code: .success, userActivity: nil)
		response.result = intent.list?.sorted(
			type: SortType(intent.sortType),
			order: (intent.ascending as? Bool ?? true) ? .forward : .reverse
		)
		return response
	}
}
