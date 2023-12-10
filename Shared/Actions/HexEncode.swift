import AppIntents

struct HexEncode: AppIntent {
	static let title: LocalizedStringResource = "Hex Encode"

	static let description = IntentDescription(
		"""
		Encodes or decodes text or files using Hex encoding.

		Example: Hi → 4869

		Note: Use Base64 encoding whenever possible as it's more space efficient.
		""",
		categoryName: "Parse / Generate",
		searchKeywords: [
			"base16",
			"hexadecimal",
			"binary"
		],
		resultValueName: "Hex Encoded Data"
	)

	@Parameter(
		title: "Input",
		description: "Accepts a file or text. Tap the parameter to select a file. Tap and hold to select a variable to some text.",
		supportedTypeIdentifiers: ["public.data"]
	)
	var input: IntentFile

	@Parameter(title: "Action", default: .encode)
	var action: HexEncodeActionAppEnum

	@Parameter(
		title: "Uniform Type Identifier",
		description: "For example, if the Hex string represents a PNG image, use “public.png”.",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var decodeContentType: String?

	static var parameterSummary: some ParameterSummary {
		// This fails on Xcode 15.
//		When(\.$action, .equalTo, .encode) {
//			Summary("\(\.$action) \(\.$input) to Hex")
//		} otherwise: {
//			Summary("\(\.$action) \(\.$input) from Hex to \(\.$decodeContentType)")
//		}
		Switch(\.$action) {
			Case(.encode) {
				Summary("\(\.$action) \(\.$input) to Hex")
			}
			DefaultCase {
				Summary("\(\.$action) \(\.$input) from Hex to \(\.$decodeContentType)")
			}
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		let result = try {
			switch action {
			case .encode:
				return input.data
					.hexEncodedString()
					.toIntentFile(filename: input.filenameWithoutExtension)
			case .decode:
				guard let string = input.data.toString else {
					throw "The input must be text or a plain text file.".toError
				}

				return string
					.hexDecodedData()
					.toIntentFile(contentType: decodeContentType.flatMap { .init($0) } ?? .data)
			}
		}()

		return .result(value: result)
	}
}

// TODO: Would be nice if this could be `private`, but that does not currently work in Swift 5.7. It could then also have a shorter name.
enum HexEncodeActionAppEnum: String, AppEnum {
	case encode
	case decode

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Hex Encode Action"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.encode: "Encode",
		.decode: "Decode"
	]
}
