import AppIntents

struct OverwriteFile: AppIntent {
	static let title: LocalizedStringResource = "Overwrite File"

	static let description = IntentDescription(
"""
Overwrites the given destination file with the given source file.

Returns the new destination file.
""",
		categoryName: "File"
	)

	@Parameter(
		title: "Source",
		description: "Accepts a file, image, or text. Tap the parameter to select a file. Tap and hold to select a variable to an image or text.",
		supportedTypeIdentifiers: ["public.data"]
	)
	var source: IntentFile

	@Parameter(
		title: "Destination",
		description: "Must be a real file.",
		supportedTypeIdentifiers: ["public.data"]
	)
	var destination: IntentFile

	static var parameterSummary: some ParameterSummary {
		Summary("Overwrite \(\.$destination) with \(\.$source)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		guard let destinationURL = destination.fileURL else {
			throw "Failed to get the URL for the destination file.".toError
		}

		let newDestination = try destinationURL.accessSecurityScopedResource {
			try source.data.write(to: $0)

			var file = IntentFile(
				fileURL: $0,
				filename: destination.filename,
				type: destination.type
			)

			file.removedOnCompletion = false

			return file
		}

		return .result(value: newDestination)
	}
}
