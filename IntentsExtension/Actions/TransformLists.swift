import Foundation
import Intents

@MainActor
final class TransformListsIntentHandler: NSObject, TransformListsIntentHandling {
	func handle(intent: TransformListsIntent) async -> TransformListsIntentResponse {
		let response = TransformListsIntentResponse(code: .success, userActivity: nil)

		let list1: [INFile]
		let list2: [INFile]
		switch intent.type {
		case .subtraction:
			list1 = intent.subtractionList1 ?? []
			list2 = intent.subtractionList2 ?? []
		case .intersection:
			list1 = intent.intersectionList1 ?? []
			list2 = intent.intersectionList2 ?? []
		case .symmetricDifference:
			list1 = intent.symmetricDifferenceList1 ?? []
			list2 = intent.symmetricDifferenceList2 ?? []
		case .unknown:
			return .init(code: .failure, userActivity: nil)
		}

		let set1 = Set(list1.map(\.data))
		let set2 = Set(list2.map(\.data))

		let set3: Set<Data>
		switch intent.type {
		case .subtraction:
			set3 = set1.subtracting(set2)
		case .intersection:
			set3 = set1.intersection(set2)
		case .symmetricDifference:
			set3 = set1.symmetricDifference(set2)
		case .unknown:
			return .init(code: .failure, userActivity: nil)
		}

		let inputFiles = list1 + list2
		response.result = set3.map { data in
			inputFiles.first { $0.data == data }
		}
			.compact()

		return response
	}
}
