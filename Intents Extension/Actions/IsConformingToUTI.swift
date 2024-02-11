import AppIntents
import UniformTypeIdentifiers

struct IsConformingToUTIIntent: AppIntent {
	static let title: LocalizedStringResource = "Is Conforming to Uniform Type Identifier"

	static let description = IntentDescription(
		"""
		Returns whether the given Uniform Type Identifier (UTI) conforms to another one.

		For example, it would return true if the first parameter is “public.jpeg” (JPEG image) and the second parameter is “public.image”.

		This could be useful in combination with the “Get Uniform Type Identifier” action to check if a file conforms to a certain UTI. For example, to check if a file is an image.
		""",
		categoryName: "Miscellaneous",
		searchKeywords: [
			"uti",
			"uttype",
			"conformance",
			"check",
			"image"
		]
	)

	@Parameter(
		title: "UTI",
		description: "For example: “public.jpeg”",
		inputOptions: .init(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var utiString: String

	@Parameter(
		title: "Parent UTI",
		description: "For example: “public.image”",
		inputOptions: .init(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var parentUTIString: String

	static var parameterSummary: some ParameterSummary {
		Summary("Does \(\.$utiString) conform to \(\.$parentUTIString)?")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
		guard let uti = UTType(utiString) else {
			throw "The first UTI is invalid.".toError
		}

		guard let parentUTI = UTType(parentUTIString) else {
			throw "The second UTI is invalid.".toError
		}

		return .result(value: uti.conforms(to: parentUTI))
	}
}
