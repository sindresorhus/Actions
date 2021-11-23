import SwiftUI

@MainActor
final class HideShortcutsAppIntentHandler: NSObject, HideShortcutsAppIntentHandling {
	func handle(intent: HideShortcutsAppIntent) async -> HideShortcutsAppIntentResponse {
		#if canImport(AppKit)
		NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.shortcuts").first?.hide()
		return .init(code: .success, userActivity: nil)
		#elseif canImport(UIKit)
		return .init(code: .continueInApp, userActivity: nil)
		#endif
	}
}
