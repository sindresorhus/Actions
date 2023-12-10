import AppIntents

struct GenerateRandomData: AppIntent {
	static let title: LocalizedStringResource = "Generate Random Data"

	static let description = IntentDescription(
		"""
		Generates cryptographically secure random data as Hex, Base64, or binary.

		Example use-cases: Generating keys, secrets, nonces, OTP, passwords, PINs, secure tokens, etc.
		""",
		categoryName: "Random",
		resultValueName: "Random Data"
	)

	@Parameter(
		title: "Size",
		description: "The size in bytes.",
		controlStyle: .field,
		inclusiveRange: (0, 99_999_999)
	)
	var size: Int

	@Parameter(title: "Type", default: .hex)
	var outputType: GenerateRandomDataOutputTypeAppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Generate \(\.$size) bytes of random data as \(\.$outputType)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		guard size >= 0 else {
			throw "The size cannot be negative.".toError
		}

		let result = {
			let filename = "Random Data \(UUID().uuidString)" // TODO: We use UUID here as there's a bug in iOS where if you run the same workflow multiple times, it will not be able to display the output. Some filename overlap. (iOS 16.0.3) Check if this is fixed in iOS 16.1.
			let data = Data.random(length: size)

			switch outputType {
			case .hex:
				return data
					.hexEncodedString()
					.toIntentFile(filename: filename)
			case .base64:
				return data
					.base64EncodedString()
					.toIntentFile(filename: filename)
			case .binary:
				return data
					.toIntentFile(contentType: .data, filename: filename)
			}
		}()

		return .result(value: result)
	}
}

enum GenerateRandomDataOutputTypeAppEnum: String, AppEnum {
	case hex
	case base64
	case binary

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Random Data Output Type"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.hex: "Hex",
		.base64: "Base64",
		.binary: "Binary"
	]
}
