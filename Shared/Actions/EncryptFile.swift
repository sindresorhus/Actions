import AppIntents
import CryptoKit
import UniformTypeIdentifiers

struct EncryptFile: AppIntent {
	static let title: LocalizedStringResource = "Encrypt File"

	static let description = IntentDescription(
		"""
		Encrypts/decrypts a file/data securely using the given key.

		It uses an AES-256-GCM cipher.

		IMPORTANT: Don't store the key in the shortcut if you intend to share the shortcut. Instead, read it from a local file.

		See the “Encrypt Text” action to encrypt text.
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
		resultValueName: "Encrypted/Decrypted File"
	)

	@Parameter(
		title: "Action",
		default: true,
		displayName: .init(true: "Encrypt", false: "Decrypt")
	)
	var shouldEncrypt: Bool

	@Parameter(
		title: "File",
		supportedTypeIdentifiers: ["public.data"]
	)
	var file: IntentFile

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

	@Parameter(
		title: "Decrypted Type",
		description: "The type of the decrypted file in Uniform Type Identifier format. For example, “public.png” for PNG image or “public.zip-archive” for ZIP archive.",
		default: "public.data"
	)
	var decryptedType: String

	static var parameterSummary: some ParameterSummary {
		When(\.$shouldEncrypt, .equalTo, true) {
			Summary("\(\.$shouldEncrypt) \(\.$file) using key \(\.$key)")
		} otherwise: {
			Summary("\(\.$shouldEncrypt) \(\.$file) using key \(\.$key) as type \(\.$decryptedType)")
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		let key = try createEncryptionKey(key)

		if shouldEncrypt {
			let result = try AES.GCM
				.seal(file.data, using: key)
				.combined!
				.toIntentFile(contentType: .data, filename: "Encrypted Data")

			return .result(value: result)
		}

		guard let type = UTType(decryptedType) else {
			throw "Invalid or unknown Uniform Type Identifier.".toError
		}

		let sealedBox = try AES.GCM.SealedBox(combined: file.data)

		let result = try AES.GCM
			.open(sealedBox, using: key)
			.toIntentFile(contentType: type, filename: "Decrypted Data")

		return .result(value: result)
	}
}

func createEncryptionKey(_ key: String) throws -> SymmetricKey {
	guard key.isASCII else {
		throw "Key must only contain ASCII characters (English letters and numbers).".toError
	}

	guard key.count == 32 else {
		throw "Key must be exactly 32 characters, got \(key.count).".toError
	}

	return SymmetricKey(data: key.toData)
}
