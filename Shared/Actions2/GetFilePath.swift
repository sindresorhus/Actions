import AppIntents

struct GetFilePath: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GetFilePathIntent"

	static let title: LocalizedStringResource = "Get File Path"

	static let description = IntentDescription(
		"Returns the path or URL to the input file.",
		categoryName: "File"
	)

	@Parameter(title: "File", supportedTypeIdentifiers: ["public.data"])
	var file: IntentFile

	@Parameter(title: "Type", default: .path)
	var type: FilePathTypeAppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Get the \(\.$type) to \(\.$file)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		guard let fileURL = file.fileURL else {
			throw NSError.appError("The given file does not have a path.")
		}

		let result = {
			switch type {
			case .path:
				return fileURL.path
			case .url:
				return fileURL.absoluteString
			case .tildePath:
				return fileURL.tildePath
			}
		}()

		return .result(value: result)
	}
}

enum FilePathTypeAppEnum: String, AppEnum {
	case path
	case url
	case tildePath

	static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "File Path Type")

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.path: "Path",
		.url: "URL",
		.tildePath: .init(
			title: "Tilde Path",
			subtitle: "macOS-only"
		)
	]
}
