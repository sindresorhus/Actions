import AppIntents
import SwiftUI

@available(macOS, unavailable)
struct ScanDocuments: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "ScanDocumentsIntent"

	static let title: LocalizedStringResource = "Scan Documents (iOS-only)"

	static let description = IntentDescription(
"""
Scans one or more documents using the iOS document scanner.

IMPORTANT: The resulting images are copied to the clipboard. Add the “Wait to Return” and “Get Clipboard” actions after this one.

NOTE: In contrast to the built-in “Scan Document” action, this one makes it possible to use the scanned document in the shortcut.
""",
		categoryName: "Utility"
	)

	static let openAppWhenRun = true

	static var parameterSummary: some ParameterSummary {
		Summary("Scan documents")
	}

	@MainActor
	func perform() async throws -> some IntentResult {
		// This tries to fix the document scanner sometimes not opening.
		try? await Task.sleep(for: .seconds(0.5))

		// TODO: Is there really no better way of handling this?
		withoutAnimation {
			AppState.shared.isDocumentScannerPresented = true
		}

		return .result()
	}
}
