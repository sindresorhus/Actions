import AppIntents
import CoreImage

struct ScanQRCodesInImage: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "ScanQRCodesInImageIntent"

	static let title: LocalizedStringResource = "Scan QR Codes in Image"

	static let description = IntentDescription(
"""
Returns the messages of the QR codes in the input image.

By default, it only returns the message for the first QR code.

The messages are sorted by the physical size of their QR code in ascending order (largest first).
""",
		categoryName: "Image"
	)

	@Parameter(title: "Image", supportedTypeIdentifiers: ["public.image"])
	var image: IntentFile

	@Parameter(title: "Scan Multiple", default: false)
	var multiple: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("Scan QR codes in \(\.$image)") {
			\.$multiple
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[String]> {
		let messages = try CIImage.from(image.data).readMessageForQRCodes()
		let result = multiple ? messages : Array(messages.prefix(1))
		return .result(value: result)
	}
}
