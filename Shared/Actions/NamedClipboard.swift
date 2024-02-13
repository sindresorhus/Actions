#if os(macOS)
import AppIntents
import SwiftUI
import UniformTypeIdentifiers

// NOTE: It has to be in the main app so that it's possible to get/set data larger than 30 MB.

@available(iOS, unavailable)
@available(visionOS, unavailable)
struct NamedClipboardGetTextIntent: AppIntent {
	static let title: LocalizedStringResource = "Named Clipboard: Get Text"

	static let description = IntentDescription(
		"""
		Returns one or more text items from a named clipboard.

		A named clipboard is a semi-private clipboard only accessible if you know the name. It can be useful to share data between shortcuts without cluttering the main clipboard.

		See the “Set Text from Named Clipboard” action to set items.
		See the “Get Data from Named Clipboard” action to get other things like images.
		""",
		categoryName: "Named Clipboard",
		resultValueName: "Text from Named Clipboard"
	)

	@Parameter(
		title: "Name",
		inputOptions: .init(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var name: String

	static var parameterSummary: some ParameterSummary {
		Summary("Get text items from clipboard named \(\.$name)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[String]> {
		let pasteboard = NSPasteboard(name: .init(name))
		return .result(value: pasteboard.strings ?? [])
	}
}

@available(iOS, unavailable)
@available(visionOS, unavailable)
struct NamedClipboardGetDataIntent: AppIntent {
	static let title: LocalizedStringResource = "Named Clipboard: Get Data"

	static let description = IntentDescription(
		"""
		Returns one or more items from a named clipboard.

		A named clipboard is a semi-private clipboard only accessible if you know the name. It can be useful to share data between shortcuts without cluttering the main clipboard.

		See the “Set Data from Named Clipboard” action to set items.
		See the “Get Text from Named Clipboard” action to get text.
		""",
		categoryName: "Named Clipboard",
		resultValueName: "Data from Named Clipboard"
	)

	@Parameter(
		title: "Name",
		inputOptions: .init(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var name: String

	@Parameter(
		title: "Type",
		description: "The type of data in Uniform Type Identifier format you want to get from the clipboard. For example, “public.png” for PNG image or “public.zip-archive” for ZIP archive.",
		default: "public.data"
	)
	var type: String

	static var parameterSummary: some ParameterSummary {
		Summary("Get \(\.$type) items from clipboard named \(\.$name)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<[IntentFile]> {
		guard let uttype = UTType(type) else {
			throw "Invalid or unknown Uniform Type Identifier.".toError
		}

		let pasteboard = NSPasteboard(name: .init(name))

		let result: [IntentFile] = pasteboard.pasteboardItems?.compactMap {
			guard let availableType = $0.availableType(from: [.init(type)]) else {
				return nil
			}

			return $0
				.data(forType: availableType)?
				.toIntentFile(
					contentType: UTType(availableType.rawValue) ?? uttype,
					filename: UUID().uuidString
				)
		} ?? []

		return .result(value: result)
	}
}

@available(iOS, unavailable)
@available(visionOS, unavailable)
struct NamedClipboardSetTextIntent: AppIntent {
	static let title: LocalizedStringResource = "Named Clipboard: Set Text"

	static let description = IntentDescription(
		"""
		Sets one or more text items on a named clipboard.

		A named clipboard is a semi-private clipboard only accessible if you know the name. It can be useful to share data between shortcuts without cluttering the main clipboard.

		See the “Get Text from Named Clipboard” action to get items.
		See the “Set Data from Named Clipboard” action to set other things like images.
		""",
		categoryName: "Named Clipboard"
	)

	@Parameter(
		title: "Name",
		inputOptions: .init(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var name: String

	@Parameter(
		title: "Text Items",
		inputOptions: .init(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var items: [String]

	static var parameterSummary: some ParameterSummary {
		Summary("Set clipboard named \(\.$name) to \(\.$items)")
	}

	func perform() async throws -> some IntentResult {
		let pasteboard = NSPasteboard(name: .init(name))
		pasteboard.strings = items
		return .result()
	}
}

@available(iOS, unavailable)
@available(visionOS, unavailable)
struct NamedClipboardSetDataIntent: AppIntent {
	static let title: LocalizedStringResource = "Named Clipboard: Set Data"

	static let description = IntentDescription(
		"""
		Sets one or more items on a named clipboard.

		A named clipboard is a semi-private clipboard only accessible if you know the name. It can be useful to share data between shortcuts without cluttering the main clipboard.

		See the “Get Data from Named Clipboard” action to get items.
		See the “Set Text from Named Clipboard” action to set text.
		""",
		categoryName: "Named Clipboard"
	)

	@Parameter(
		title: "Name",
		inputOptions: .init(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var name: String

	@Parameter(
		title: "Items",
		supportedTypeIdentifiers: ["public.data"]
	)
	var items: [IntentFile]

	static var parameterSummary: some ParameterSummary {
		Summary("Set clipboard named \(\.$name) to \(\.$items)")
	}

	func perform() async throws -> some IntentResult {
		let pasteboard = NSPasteboard(name: .init(name))

		let objects = items.map {
			let item = NSPasteboardItem()
			item.setData($0.data, forType: .init(($0.type ?? .data).identifier))
			return item
		}

		pasteboard.prepareForNewContents()
		pasteboard.writeObjects(objects)

		return .result()
	}
}

@available(iOS, unavailable)
@available(visionOS, unavailable)
struct NamedClipboardClearIntent: AppIntent {
	static let title: LocalizedStringResource = "Named Clipboard: Clear"

	static let description = IntentDescription(
		"""
		Clears a named clipboard.

		A named clipboard is a semi-private clipboard only accessible if you know the name. It can be useful to share data between shortcuts without cluttering the main clipboard.
		""",
		categoryName: "Named Clipboard"
	)

	@Parameter(
		title: "Name",
		inputOptions: .init(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var name: String

	static var parameterSummary: some ParameterSummary {
		Summary("Clear clipboard named \(\.$name)")
	}

	func perform() async throws -> some IntentResult {
		let pasteboard = NSPasteboard(name: .init(name))
		pasteboard.clearContents()
		return .result()
	}
}
#endif
