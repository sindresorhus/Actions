import Foundation

@MainActor
final class RemoveFromListIntentHandler: NSObject, RemoveFromListIntentHandling {
	func resolveIndex(for intent: RemoveFromListIntent) async -> RemoveFromListIndexResolutionResult {
		guard let index = intent.index as? Int else {
			return .needsValue()
		}

		let list = intent.list ?? []

		// Account for 1-based indexing.
		guard list.indices.contains(index - 1) else {
			return .unsupported(forReason: .invalid)
		}

		return .success(with: index)
	}

	func resolveRangeLowerBound(for intent: RemoveFromListIntent) async -> RemoveFromListRangeLowerBoundResolutionResult {
		guard let lowerBound = intent.rangeLowerBound as? Int else {
			return .needsValue()
		}

		let list = intent.list ?? []

		// Account for 1-based indexing.
		guard list.indices.contains(lowerBound - 1) else {
			return .unsupported(forReason: .invalid)
		}

		return .success(with: lowerBound)
	}

	func resolveRangeUpperBound(for intent: RemoveFromListIntent) async -> RemoveFromListRangeUpperBoundResolutionResult {
		guard let upperBound = intent.rangeUpperBound as? Int else {
			return .needsValue()
		}

		let list = intent.list ?? []

		// Account for 1-based indexing.
		guard list.indices.contains(upperBound - 1) else {
			return .unsupported(forReason: .invalid)
		}

		return .success(with: upperBound)
	}

	func handle(intent: RemoveFromListIntent) async -> RemoveFromListIntentResponse {
		let response = RemoveFromListIntentResponse(code: .success, userActivity: nil)

		guard
			let list = intent.list,
			!list.isEmpty
		else {
			response.result = []
			return response
		}

		// TODO: We do not support removing multiple indices for `.index` as there is a bug in Shortcuts on macOS 12.0.1 where it does not correctly allow multiple values in the UI.

		switch intent.action {
		case .unknown:
			return .init(code: .failure, userActivity: nil)
		case .firstItem:
			response.result = Array(list.dropFirst())
		case .lastItem:
			response.result = Array(list.dropLast())
		case .index:
			guard let index = intent.index as? Int else {
				return .init(code: .failure, userActivity: nil)
			}

			// Account for 1-based indexing.
			response.result = list.removing(atIndices: [index - 1])
		case .range:
			guard
				let lowerBound = intent.rangeLowerBound as? Int,
				let upperBound = intent.rangeUpperBound as? Int
			else {
				return .init(code: .failure, userActivity: nil)
			}

			// Account for 1-based indexing.
			let range = ClosedRange.fromGraceful(lowerBound - 1, upperBound - 1)
			response.result = list.removingSubrange(range)
		case .randomItems:
			let count = intent.randomItemCount as? Int ?? 0

			guard count >= 0 else { // swiftlint:disable:this empty_count
				return .failure(failure: "The count must be 0 or higher")
			}

			let indices = list.uniqueRandomIndices(maxCount: count)
			response.result = list.removing(atIndices: indices)
		}

		return response
	}
}
