import SwiftUI
import Intents
import IntentsUI
import Sentry


func setUpSentry() {
	#if !DEBUG
	SentrySDK.start {
		$0.dsn = "https://12c8785fd2924c9a9c0f6bb1d91be79e@o844094.ingest.sentry.io/6041555"
		$0.enableSwizzling = false
	}
	#endif
}


extension Color_ {
	convenience init(_ xColor: XColor) {
		#if canImport(AppKit)
		let sRGBColor = xColor.usingColorSpace(.sRGB)!
		#elseif canImport(UIKit)
		let sRGBColor = xColor
		#endif

		let thumbnail = XImage.color(xColor, size: CGSize(width: 1, height: 1), scale: 1)

		self.init(
			identifier: "color",
			display: sRGBColor.hexString,
			subtitle: "",
			image: thumbnail.toINImage
		)

		hex = sRGBColor.hexString
		hexNumber = sRGBColor.hex as NSNumber
	}
}
