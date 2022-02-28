import SwiftUI
import Intents

func icon(_ file: INFile) -> NSImage {
	if let url = file.fileURL {
		return NSWorkspace.shared.icon(forFile: url.path)
	} else {
		return NSWorkspace.shared.icon(for: file.contentType ?? .data)
	}
}

@MainActor
final class GetFileIconIntentHandler: NSObject, GetFileIconIntentHandling {
	func handle(intent: GetFileIconIntent) async -> GetFileIconIntentResponse {
		let response = GetFileIconIntentResponse(code: .success, userActivity: nil)

		response.result = intent.files?.compactMap { file in
			autoreleasepool {
				icon(file).toINFile()
			}
		}

		return response
	}
}
