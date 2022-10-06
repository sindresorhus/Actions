import AppIntents
import SwiftUI

@available(macOS, unavailable)
struct ScanDocuments: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "ScanDocumentsIntent"

	static let title: LocalizedStringResource = "Scan Documents (iOS-only)"

	static let description = IntentDescription(
"""
Scans one or more documents using the iOS document scanner.

The resulting images are copied to the clipboard. Add the “Wait to Return” and “Get Clipboard” actions after this one.
""",
		categoryName: "Utility"
	)

	static let openAppWhenRun = true

	static var parameterSummary: some ParameterSummary {
		Summary("Scan documents")
	}

	@MainActor
	func perform() async throws -> some IntentResult {
		#if canImport(UIKit)
		UIView.setAnimationsEnabled(false)
		#endif

		// TODO: Is there really no better way of handling this?
		AppState.shared.isDocumentScannerPresented = true

		return .result()
	}
}
