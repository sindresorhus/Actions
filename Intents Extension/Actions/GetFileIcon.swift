import AppIntents
import SwiftUI

@available(iOS, unavailable)
struct GetFileIcon: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GetFileIconIntent"

	static let title: LocalizedStringResource = "Get File Icon (macOS-only)"

	static let description = IntentDescription(
		"Returns the icon for the input files or directories.",
		categoryName: "File"
	)

	@Parameter(title: "Files", supportedTypeIdentifiers: ["public.item"])
	var files: [IntentFile]

	static var parameterSummary: some ParameterSummary {
		Summary("Get the icon of \(\.$files)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		#if os(macOS)
		func icon(_ file: IntentFile) -> XImage {
			if let url = file.fileURL {
				return NSWorkspace.shared.icon(forFile: url.path)
			}

			return NSWorkspace.shared.icon(for: file.type ?? .data)
		}

		let result = try files.compactMap { file in
			try autoreleasepool {
				try icon(file).toIntentFile()
			}
		}

		return .result(value: result)
		#else
		.result(value: [])
		#endif
	}
}
