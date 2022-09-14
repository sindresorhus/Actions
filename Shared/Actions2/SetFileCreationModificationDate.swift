import AppIntents

struct SetFileCreationModificationDate: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "SetFileCreationModificationDateIntent"

	static let title: LocalizedStringResource = "Set Creation and Modification Date of File"

	static let description = IntentDescription(
		"Sets the creation and modification date of a file to a new value.",
		categoryName: "File"
	)

	@Parameter(title: "File", supportedTypeIdentifiers: ["public.item"])
	var file: IntentFile

	@Parameter(title: "Type", default: .both)
	var type: SetFileDateTypeAppEnum

	@Parameter(title: "Date and Time")
	var date: Date

	static var parameterSummary: some ParameterSummary {
		Summary("Set \(\.$type) of \(\.$file) to \(\.$date)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		let result = try file.modifyingFileAsURL { url in
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

			return url
		}

		return .result(value: result)
	}
}

enum SetFileDateTypeAppEnum: String, AppEnum {
	case creationDate
	case modificationDate
	case both

	static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Set File Date Type")

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.creationDate: "Creation Date",
		.modificationDate: "Modification Date",
		.both: "Creation and Modification Date"
	]
}
