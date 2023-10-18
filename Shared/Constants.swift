import SwiftUI
import AppIntents

enum Constants {
	static let appGroupID = "group.com.sindresorhus.Actions"
	static let sharedDefaults = UserDefaults(suiteName: appGroupID)!
	static let defaultsKey_sendCrashReports = "sendCrashReports"
}

func initSentry() {
	guard Constants.sharedDefaults.bool(forKey: Constants.defaultsKey_sendCrashReports) else {
		return
	}

	SSApp.initSentry("https://12c8785fd2924c9a9c0f6bb1d91be79e@o844094.ingest.sentry.io/6041555")
}

/*
Intent categories:
- List
- Dictionary
- Text
- Image
- Audio
- Video
- Device
- Web
- Random
= Number
- Color
- File
- Date
- URL
- Music
- Formatting
- Parse / Generate
- Math
- Location
- Meta
- Global Variable
- Miscellaneous
*/

struct ColorAppEntity: TransientAppEntity {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Color"

	// TODO: Support opacity in the Hex string.
	@Property(title: "Hex")
	var hex: String

	@Property(title: "Hex Number")
	var hexNumber: Int

	// TODO: When targeting macOS 14, add color components properties too (red, green, etc).

	var displayRepresentation: DisplayRepresentation {
		.init(
			title: "\(hex)",
			subtitle: "", // Required to show the `image`. (iOS 16.2)
			image: color.flatMap {
				XImage.color($0, size: CGSize(width: 1, height: 1), scale: 1)
					.toDisplayRepresentationImage()
			}
		)
	}

	// TODO: Use `Color.Resolved` when targeting macOS 14.
	var color: XColor?
}

extension ColorAppEntity {
	init(_ color: XColor) {
		self.color = color
		self.hex = color.hexString
		self.hexNumber = color.hex
	}
}
