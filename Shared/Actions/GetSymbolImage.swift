import AppIntents
import SwiftUI

struct SymbolImageIntent: AppIntent {
	static let title: LocalizedStringResource = "Get SF Symbol Image"

	static let description = IntentDescription(
		"""
		Returns a SF Symbols symbol as an image.

		For example, “checkmark.circle.fill”.

		Use the SF Symbols app to find the symbol you want.
		""",
		categoryName: "Image",
		resultValueName: "SF Symbol Image"
	)

	@Parameter(
		title: "Symbol Name",
		inputOptions: String.IntentInputOptions(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var symbolName: String

	@Parameter(title: "Size", default: 128, inclusiveRange: (8, 2000))
	var size: Int

	@Parameter(title: "Rendering", default: .monochrome)
	var rendering: SymbolImageRenderingAppEnum

	@Parameter(title: "Hex Color", default: "#ff69b4")
	var color: String?

	@Parameter(title: "Hex Color", default: ["#ff69b4"])
	var paletteColors: [String]

	@Parameter(title: "Weight", default: .regular)
	var weight: SymbolWeightAppEnum

	static var parameterSummary: some ParameterSummary {
		Switch(\.$rendering) {
			Case(.monochrome) {
				Summary("Get symbol \(\.$symbolName) of size \(\.$size) as \(\.$rendering) \(\.$color)") {
					\.$weight
				}
			}
			Case(.hierarchical) {
				Summary("Get symbol \(\.$symbolName) of size \(\.$size) as \(\.$rendering) \(\.$color)") {
					\.$weight
				}
			}
			Case(.palette) {
				Summary("Get symbol \(\.$symbolName) of size \(\.$size) as \(\.$rendering) \(\.$paletteColors)") {
					\.$weight
				}
			}
			DefaultCase {
				Summary("Get symbol \(\.$symbolName) of size \(\.$size) as \(\.$rendering)") {
					\.$weight
				}
			}
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		guard size <= 2000 else {
			throw "The maximum size is 2000.".toError
		}

		var configuration = XImage.SymbolConfiguration(pointSize: Double(size), weight: weight.toNative)

		switch rendering {
		case .monochrome:
			if
				let hexString = color,
				let color = Color.Resolved(hexString: hexString)?.toColor.toXColor
			{
				configuration = configuration.applying(XImage.SymbolConfiguration(paletteColors: [color]))
			}
		case .hierarchical:
			if
				let hexString = color,
				let color = Color.Resolved(hexString: hexString)?.toColor.toXColor
			{
				configuration = configuration.applying(XImage.SymbolConfiguration(hierarchicalColor: color))
			}
		case .palette:
			if let colors = (paletteColors.compactMap { Color.Resolved(hexString: $0)?.toColor.toXColor }).nilIfEmpty {
				configuration = configuration.applying(XImage.SymbolConfiguration(paletteColors: colors))
			}
		case .multicolor: // TODO: Does not work on macOS. (macOS 14.1) Check if it's fixed on macOS 15.
			configuration = configuration.applying(XImage.SymbolConfiguration.preferringMulticolor())
		}

		guard var image = XImage(systemName: symbolName) else {
			throw "No symbol with the given name or it requires a newer operating system version.".toError
		}

		image = image.withConfiguration(configuration)

		#if os(macOS)
		// See: https://developer.apple.com/forums/thread/663728
		image = image.normalizingImage()
		#endif

		// Note: `UUID().uuidString` works around a Shortcuts bug where the filename cannot be reused. (macOS 14.5)
		let result = try image.toIntentFile(filename: symbolName + UUID().uuidString)

		return .result(value: result)
	}
}

enum SymbolImageRenderingAppEnum: String, AppEnum {
	case monochrome
	case hierarchical
	case palette
	case multicolor

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Symbol Image Rendering"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.monochrome: "monochrome",
		.hierarchical: "hierarchical",
		.palette: "palette",
		.multicolor: "multicolor (iOS & visionOS-only)"
	]
}

enum SymbolWeightAppEnum: String, AppEnum {
	case ultraLight
	case thin
	case light
	case regular
	case medium
	case semibold
	case bold
	case heavy
	case black

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Symbol Weight"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.ultraLight: "Ultra Light",
		.thin: "Thin",
		.light: "Light",
		.regular: "Regular",
		.medium: "Medium",
		.semibold: "Semibold",
		.bold: "Bold",
		.heavy: "Heavy",
		.black: "Black"
	]
}

#if os(macOS)
private typealias Weight = NSFont.Weight
#else
private typealias Weight = UIImage.SymbolWeight
#endif

extension SymbolWeightAppEnum {
	fileprivate var toNative: Weight {
		switch self {
		case .ultraLight:
			.ultraLight
		case .thin:
			.thin
		case .light:
			.light
		case .regular:
			.regular
		case .medium:
			.medium
		case .semibold:
			.semibold
		case .bold:
			.bold
		case .heavy:
			.heavy
		case .black:
			.black
		}
	}
}
