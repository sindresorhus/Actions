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
- Bluetooth
- Meta
- Global Variable
- Miscellaneous
*/

struct ColorAppEntity: TransientAppEntity {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Color"

	@Property(title: "Hex")
	var hex: String

	@Property(title: "Hex Number")
	var hexNumber: Int

	@Property(title: "Red (sRGB extended)")
	var red: Double

	@Property(title: "Green (sRGB extended)")
	var green: Double

	@Property(title: "Blue (sRGB extended)")
	var blue: Double

	@Property(title: "Opacity")
	var opacity: Double

	var displayRepresentation: DisplayRepresentation {
		.init(
			title: "\(hex)",
			subtitle: "", // Required to show the `image`. (iOS 16.2)
			image: XImage.color(toColor.toColor, size: CGSize(width: 1, height: 1), scale: 1)
				.toDisplayRepresentationImage()
		)
	}
}

extension ColorAppEntity {
	init(_ color: Color.Resolved) {
		self.hex = color.hexString
		self.hexNumber = color.hex
		self.red = color.red.toDouble
		self.green = color.green.toDouble
		self.blue = color.blue.toDouble
		self.opacity = color.opacity.toDouble
	}

	var toColor: Color.Resolved {
		.init(
			red: red.toFloat,
			green: green.toFloat,
			blue: blue.toFloat,
			opacity: opacity.toFloat
		)
	}
}
