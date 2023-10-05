import AppIntents
import MapKit
import SwiftUI

// NOTE: This has to be an in-app intent as `ImageRenderer` just produces a black image when in an app extension.

struct GetMapImageOfLocation: AppIntent {
	static let title: LocalizedStringResource = "Get Map Image of Location"

	static let description = IntentDescription(
"""
Returns an image with the given location marked and centered on a map.

Known issue: On iOS, it only works the first time. There is some kind of iOS bug that makes it not work the second time it's run. There's unfortunately no workaround and we have to wait for Apple to fix this.
""",
		categoryName: "Location"
	)

	@Parameter(title: "Location")
	var location: CLPlacemark

	@Parameter(
		title: "Visible Radius",
		description: "How much area to show around the location.",
		defaultValue: 10,
		defaultUnit: .kilometers,
		supportsNegativeNumbers: false
	)
	var radius: Measurement<UnitLength>

	@Parameter(
		title: "Width",
		description: "The image width in pixels.",
		default: 1000,
		controlStyle: .field
	)
	var width: Int

	@Parameter(
		title: "Height",
		description: "The image height in pixels.",
		default: 1000,
		controlStyle: .field
	)
	var height: Int

	@Parameter(title: "Show Placemark", default: true)
	var showPlacemark: Bool

	@Parameter(title: "Map Type", default: .standard)
	var mapType: MapTypeAppEnum

	@Parameter(
		title: "Appearance",
		description: "On macOS, it always uses the system appearance (because of a macOS bug).",
		default: .system
	)
	var appearance: AppearanceAppEnum

	static var parameterSummary: some ParameterSummary {
		Summary("Get map image of \(\.$location) with \(\.$radius) radius") {
			\.$width
			\.$height
			\.$showPlacemark
			\.$mapType
			\.$appearance
		}
	}

	// Note: The action hangs if it's annotated with `@MainActor`.
	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		guard let coordinates = location.location?.coordinate else {
			throw "Failed to get coordinates from location.".toError
		}

		try coordinates.validate()

		var region = MKCoordinateRegion(center: coordinates, radius: radius)
		region.normalize() // Prevent exception on invalid input.

		let options = MKMapSnapshotter.Options()
		options.region = region
		options.size = .init(width: width, height: height)
		options.mapType = mapType.toNative

		if appearance != .system {
			options.useDarkMode = appearance == .dark
		}

		let snapshot = try await MKMapSnapshotter(options: options).start()

		let image = showPlacemark
			? try await drawPlacemark(on: snapshot.image, at: snapshot.point(for: coordinates))
			: snapshot.image

		let result = try image.toIntentFile()

		return .result(value: result)
	}

	@MainActor
	private func drawPlacemark(on image: XImage, at point: CGPoint) throws -> XImage {
		let canvas = Canvas { context, _ in
			let rect = context.clipBoundingRect

			context.draw(image.toSwiftUIImage, in: rect)

			let circleSize = CGSize(width: 30, height: 30)

			let circlePath = Circle().path(in: .init(
				x: point.x - (circleSize.width / 2),
				y: point.y - (circleSize.height / 2),
				width: circleSize.width,
				height: circleSize.height
			))

			context.fill(circlePath, with: .style(.red.gradient))
		}

		let renderer = ImageRenderer(content: canvas)
		renderer.proposedSize = .init(width: width.toDouble, height: height.toDouble)
		renderer.isOpaque = true

		guard let image = renderer.xImage else {
			throw "Failed to render placemark on map.".toError
		}

		return image
	}
}

enum MapTypeAppEnum: String, AppEnum {
	case standard
	case satellite
	case hybrid
	case satelliteFlyover
	case hybridFlyover
	case mutedStandard

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Map Type"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.standard: .init(
			title: "Standard",
			subtitle: "A street map that shows the position of all roads and some road names."
		),
		.satellite: .init(
			title: "Satellite",
			subtitle: "Satellite imagery of the area."
		),
		.hybrid: .init(
			title: "Hybrid",
			subtitle: "A satellite image of the area with road and road name information layered on top."
		),
		.satelliteFlyover: .init(
			title: "Satellite Flyover",
			subtitle: "A satellite image of the area with flyover data where available."
		),
		.hybridFlyover: .init(
			title: "Hybrid Flyover",
			subtitle: "A hybrid satellite image with flyover data where available."
		),
		.mutedStandard: .init(
			title: "Muted Standard",
			subtitle: "A street map where your data is emphasized over the underlying map details."
		)
	]
}


extension MapTypeAppEnum {
	var toNative: MKMapType {
		switch self {
		case .standard:
			.standard
		case .satellite:
			.satellite
		case .hybrid:
			.hybrid
		case .satelliteFlyover:
			.satelliteFlyover
		case .hybridFlyover:
			.hybridFlyover
		case .mutedStandard:
			.mutedStandard
		}
	}
}


enum AppearanceAppEnum: String, AppEnum {
	case system
	case light
	case dark

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Appearance"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.system: "System",
		.light: "Light",
		.dark: "Dark"
	]
}


extension MKMapSnapshotter.Options {
	/**
	It uses the system appearance if this is not set.
	*/
	var useDarkMode: Bool {
		get {
			assertionFailure("Not implemented")
			return false
		}
		set {
			#if os(macOS)
			appearance = .init(appearanceNamed: newValue ? .darkAqua : .aqua, bundle: .main)
			#else
			traitCollection = .init(userInterfaceStyle: newValue ? .dark : .light)
			#endif
		}
	}
}
