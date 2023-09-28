import AppIntents

struct GetFilePath: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "GetFilePathIntent"

	static let title: LocalizedStringResource = "Get File Path"

	static let description = IntentDescription(
"""
Returns the path or URL of the input files.

Folder paths always end with a slash.
""",
		categoryName: "File"
	)

	@Parameter(title: "File", supportedTypeIdentifiers: ["public.item"])
	var file: [IntentFile]

	@Parameter(title: "Type", default: .path)
	var type: FilePathTypeAppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Get the \(\.$type) to \(\.$file)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[String]> {
		.result(value: try file.map(getResult))
	}

	private func getResult(_ file: IntentFile) throws -> String {
		guard let fileURL = file.fileURL else {
			throw "The given file does not have a path.".toError
		}

		var result = switch type {
			case .path:
				fileURL.path
			case .url:
				fileURL.absoluteString
			case .tildePath:
				fileURL.tildePath
			}

		if file.type == .folder {
			result = result.ensureSuffix("/")
		}

		return result
	}
}

enum FilePathTypeAppEnum: String, AppEnum {
	case path
	case url
	case tildePath

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "File Path Type"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.path: "Path",
		.url: "URL",
		.tildePath: .init(
			title: "Tilde Path",
			subtitle: "macOS-only"
		)
	]
}
