import AppIntents

struct SetFileCreationModificationDateIntent: AppIntent {
	static let title: LocalizedStringResource = "Set Creation and Modification Date of File"

	static let description = IntentDescription(
		"""
		Sets the creation and modification date of a file or folder to a new value.

		To be able to select a folder, use the built-in “Folder” action.

		Note: Setting the modification date of a file/folder in iCloud may not work as iCloud changes the modification date when it syncs.
		""",
		categoryName: "File",
		resultValueName: "File with Updated Creation and Modification Date"
	)

	@Parameter(title: "File", supportedTypeIdentifiers: ["public.item"])
	var file: IntentFile

	@Parameter(title: "Type", default: .both)
	var type: SetFileDateTypeAppEnum

	@Parameter(title: "Date and Time")
	var date: Date

	@Parameter(
		title: "Modify Original",
		description: "When enabled, applies the changes to the original file (for example, in iCloud) instead of just the copy used in the shortcut. NOTE: It only works if you select a file directly in the parameter. It cannot come from a variable.",
		default: false
	)
	var modifyOriginal: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("Set \(\.$type) of \(\.$file) to \(\.$date)") {
			\.$modifyOriginal
		}
	}

	private func modify(_ url: URL) throws {
		try url.setResourceValues {
			switch type {
			case .creationDate:
				$0.creationDate = date
			case .modificationDate:
				$0.contentModificationDate = date
			case .both:
				$0.creationDate = date
				$0.contentModificationDate = date
			}
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		let result = try {
			if
				modifyOriginal,
				let url = file.fileURL
			{
				try url.accessSecurityScopedResource {
					try modify($0)
				}

				return file
			}

			return try file.modifyingFileAsURL {
				try modify($0)
				return $0
			}
		}()

		return .result(value: result)
	}
}

enum SetFileDateTypeAppEnum: String, AppEnum {
	case creationDate
	case modificationDate
	case both

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Set File Date Type"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.creationDate: "Creation Date",
		.modificationDate: "Modification Date",
		.both: "Creation and Modification Date"
	]
}
