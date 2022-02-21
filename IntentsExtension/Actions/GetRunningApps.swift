import SwiftUI
import Intents

@MainActor
final class GetRunningAppsIntentHandler: NSObject, GetRunningAppsIntentHandling {
	func handle(intent: GetRunningAppsIntent) async -> GetRunningAppsIntentResponse {
		let response = GetRunningAppsIntentResponse(code: .success, userActivity: nil)

		response.result = NSWorkspace.shared.runningGUIApps.compactMap { app -> RunningApp? in
			guard
				let localizedName = app.localizedName,
				let bundleIdentifier = app.bundleIdentifier
			else {
				return nil
			}

			let iconSize = 128.0
			var inImage: INImage?
			if let representation = (app.icon?.representations.first { $0.size.width == iconSize }) {
				let image = NSImage(size: CGSize(width: iconSize, height: iconSize))
				image.addRepresentation(representation)
				inImage = image.toINImage
			}

			let runningApp = RunningApp(
				identifier: bundleIdentifier,
				display: localizedName,
				subtitle: app.bundleURL?.path,
				image: inImage
			)
			runningApp.bundleIdentifier = bundleIdentifier
			runningApp.processIdentifier = app.processIdentifier as NSNumber
			runningApp.url = app.bundleURL
			runningApp.isActive = app.isActive as NSNumber
			runningApp.isHidden = app.isHidden as NSNumber
			runningApp.launchDate = Calendar.current.dateComponents(in: .current, from: app.launchDate ?? .now)
			return runningApp
		}

		return response
	}
}
