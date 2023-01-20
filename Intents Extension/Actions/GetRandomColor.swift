import AppIntents

struct GetRandomColor: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "RandomColorIntent"

	static let title: LocalizedStringResource = "Get Random Color"

	static let description = IntentDescription(
		"Returns a random color in Hex format.",
		categoryName: "Random"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<ColorAppEntity> {
		.result(value: .init(.randomAvoidingBlackAndWhite()))
	}
}

struct ColorAppEntity: TransientAppEntity {
	static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Color")

	@Property(title: "Hex")
	var hex: String

	@Property(title: "Hex Number")
	var hexNumber: Int

	var displayRepresentation: DisplayRepresentation {
		.init(
			title: "\(hex)",
			subtitle: "", // Required to show the `image`. (iOS 16.2)
			image: color.flatMap {
				XImage.color($0, size: CGSize(width: 1, height: 1), scale: 1)
					.toDisplayRepresentationImage()
			}
		)
	}

	var color: XColor?
}

extension ColorAppEntity {
	init(_ color: XColor) {
		self.color = color
		self.hex = color.hexString
		self.hexNumber = color.hex
	}
}
