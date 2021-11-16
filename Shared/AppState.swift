import SwiftUI

@MainActor
final class AppState: ObservableObject {
	static let shared = AppState()

	@Published var userActivity: NSUserActivity?
}
