import AppIntents
import CryptoKit

struct EncryptText: AppIntent {
	static let title: LocalizedStringResource = "Encrypt Text"

	static let description = IntentDescription(
		"""
		Encrypts/decrypts text securely using the given key.

		The encrypted text is returned as Base64-encoded text.

		It uses an AES-256-GCM cipher.

		IMPORTANT: Don't store the key in the shortcut if you intend to share the shortcut. Instead, read it from a local file.

		See the “Encrypt File” action to encrypt things like files and images.
		""",
		categoryName: "Miscellaneous",
		searchKeywords: [
			"encrypt",
			"decrypt",
			"encryption",
			"decryption",
			"aes",
			"security",
			"secret"
		],
		resultValueName: "Encrypted/Decrypted Text"
	)

	@Parameter(
		title: "Action",
		default: true,
		displayName: .init(true: "Encrypt", false: "Decrypt")
	)
	var shouldEncrypt: Bool

	@Parameter(
		title: "Text",
		inputOptions: .init(
			capitalizationType: .none,
			multiline: true,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var text: String

	@Parameter(
		title: "Key",
		description: "The key must be 32 characters. Only ASCII characters (English letters and numbers).",
		inputOptions: .init(
			keyboardType: .asciiCapable,
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var key: String

	static var parameterSummary: some ParameterSummary {
		Summary("\(\.$shouldEncrypt) \(\.$text) using key \(\.$key)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		let key = try createEncryptionKey(key)

		if shouldEncrypt {
			let result = try AES.GCM
				.seal(text.toData, using: key)
				.combined!
				.base64EncodedString()

			return .result(value: result)
		}

		guard let data = Data(base64Encoded: text) else {
			throw "The text to be decrypted must be Base64-encoded.".toError
		}

		let sealedBox = try AES.GCM.SealedBox(combined: data)

		let result = try AES.GCM
			.open(sealedBox, using: key)
			.toString

		guard let result else {
			throw "The decrypted data is not text.".toError
		}

		return .result(value: result)
	}
}
