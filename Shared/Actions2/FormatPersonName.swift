import AppIntents

struct FormatPersonName: AppIntent {
	static let title: LocalizedStringResource = "Format Person Name"

	static let description = IntentDescription(
		"Formats the name of a person.",
		categoryName: "Formatting"
	)

	@Parameter(title: "Given Name", inputOptions: .init(autocorrect: false))
	var givenName: String

	@Parameter(title: "Middle Name", inputOptions: .init(autocorrect: false))
	var middleName: String?

	@Parameter(title: "Family Name", inputOptions: .init(autocorrect: false))
	var familyName: String?

	@Parameter(title: "Name Prefix", inputOptions: .init(autocorrect: false))
	var namePrefix: String?

	@Parameter(title: "Nickname", inputOptions: .init(autocorrect: false))
	var nickname: String?

	@Parameter(title: "Style", default: .medium)
	var style: FormatPersonNameStyleAppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Format \(\.$givenName) \(\.$middleName) \(\.$familyName)") {
			\.$namePrefix
			\.$nickname
			\.$style
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		let result = PersonNameComponents(
			namePrefix: namePrefix,
			givenName: givenName,
			familyName: familyName,
			nickname: nickname
		)
			.formatted(.name(style: style.toNative))

		return .result(value: result)
	}
}

enum FormatPersonNameStyleAppEnum: String, AppEnum {
	case short
	case medium
	case long
	case abbreviated

	static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Person Name Components Format Style")

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.short: .init(title: "Short", subtitle: "Jenny"),
		.medium: .init(title: "Medium", subtitle: "Jane Doe"),
		.long: .init(title: "Long", subtitle: "Ms. Jane Doe"),
		.abbreviated: .init(title: "Abbreviated", subtitle: "JD"),
	]
}

extension FormatPersonNameStyleAppEnum {
	fileprivate var toNative: PersonNameComponents.FormatStyle.Style {
		switch self {
		case .short:
			return .short
		case .medium:
			return .medium
		case .long:
			return .long
		case .abbreviated:
			return .abbreviated
		}
	}
}

// Doesn't work for some reason.
//extension PersonNameComponents.FormatStyle.Style: CaseIterable {
//	public static var allCases: [Self] = [
//		.short,
//		.medium,
//		.long,
//		.abbreviated
//	]
//}
//
//extension PersonNameComponents.FormatStyle.Style: AppEnum {
//	public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Person Name Components Format Style")
//
//	public static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
//		.short: .init(title: "Short", subtitle: "Jenny"),
//		.medium: .init(title: "Medium", subtitle: "Jane Doe"),
//		.long: .init(title: "Long", subtitle: "Ms. Jane Doe"),
//		.abbreviated: .init(title: "Abbreviated", subtitle: "JD"),
//	]
//}
