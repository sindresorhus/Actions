import AppIntents
import UniformTypeIdentifiers

struct SetUniformTypeIdentifier: AppIntent {
	static let title: LocalizedStringResource = "Set Uniform Type Identifier"

	static let description = IntentDescription(
		"""
		Sets the Uniform Type Identifier (UTI) of the input file.

		This can be useful when the previous shortcut action returned some data without a specific type.
		""",
		categoryName: "File",
		resultValueName: "File with Updated Uniform Type Identifier"
	)

	@Parameter(title: "File", supportedTypeIdentifiers: ["public.item"])
	var file: IntentFile

	@Parameter(
		title: "Type Identifier",
		description: "For example, use “public.jpeg” to set it to be a JPEG image."
	)
	var typeIdentifier: String

	static var parameterSummary: some ParameterSummary {
		Summary("Set the Uniform Type Identifier of \(\.$file) to \(\.$typeIdentifier)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		guard let typeIdentifier = UTType(typeIdentifier) else {
			throw "Invalid type identifier.".toError
		}

		return .result(value: .init(data: file.data, filename: file.filename, type: typeIdentifier))
	}
}
