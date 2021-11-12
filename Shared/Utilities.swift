import SwiftUI
import Combine
import StoreKit
import GameplayKit
import UniformTypeIdentifiers
import Intents

#if canImport(AppKit)
typealias XColor = NSColor
typealias XFont = NSFont
typealias XImage = NSImage
#elseif canImport(UIKit)
typealias XColor = UIColor
typealias XFont = UIFont
typealias XImage = UIImage
#endif


enum SSApp {
	static let id = Bundle.main.bundleIdentifier!
	static let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
	static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	static let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
	static let versionWithBuild = "\(version) (\(build))"
	static let url = Bundle.main.bundleURL

	#if canImport(AppKit)
	@MainActor
	static func quit() {
		NSApp.terminate(nil)
	}
	#endif

	static let isFirstLaunch: Bool = {
		let key = "SS_hasLaunched"

		if UserDefaults.standard.bool(forKey: key) {
			return false
		} else {
			UserDefaults.standard.set(true, forKey: key)
			return true
		}
	}()

	static func openSendFeedbackPage() {
		let metadata =
			"""
			\(SSApp.name) \(SSApp.versionWithBuild) - \(SSApp.id)
			macOS \(Device.osVersion)
			\(Device.modelIdentifier)
			"""

		let query: [String: String] = [
			"product": SSApp.name,
			"metadata": metadata
		]

		URL("https://sindresorhus.com/feedback/").addingDictionaryAsQuery(query).open()
	}
}


extension Data {
	var isNullTerminated: Bool { last == 0x0 }

	var withoutNullTerminator: Self {
		guard isNullTerminated else {
			return self
		}

		return dropLast()
	}

	/**
	Convert a null-terminated string data to a string.

	- Note: It gracefully handles if the string is not null-terminated.
	*/
	var stringFromNullTerminatedStringData: String? {
		String(data: withoutNullTerminator, encoding: .utf8)
	}
}


enum Device {
	#if canImport(AppKit)
	private static func ioPlatformExpertDevice(key: String) -> CFTypeRef? {
		let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
		defer {
			IOObjectRelease(service)
		}

		return IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue()
	}
	#endif

	/**
	The current version of the operating system.

	```
	// macOS
	Device.osVersion
	//=> "10.14.2"

	// iOS
	Device.osVersion
	//=> "13.5.1"
	```
	*/
	static let osVersion: String = {
		#if canImport(AppKit)
		let os = ProcessInfo.processInfo.operatingSystemVersion
		return "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
		#elseif canImport(UIKit)
		return UIDevice.current.systemVersion
		#endif
	}()

	/**
	```
	Device.modelIdentifier
	//=> "MacBookPro11,3"

	Device.modelIdentifier
	//=> "iPhone12,8"
	```
	*/
	static let modelIdentifier: String = {
		#if canImport(AppKit)
		guard
			let data = ioPlatformExpertDevice(key: "model") as? Data,
			let modelIdentifier = data.stringFromNullTerminatedStringData
		else {
			// This will most likely never happen.
			// So better to have a fallback than making it an optional.
			return "<Unknown model>"
		}

		return modelIdentifier
		#elseif targetEnvironment(simulator)
		return "Simulator"
		#elseif canImport(UIKit)
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)

		return machineMirror.children.reduce(into: "") { identifier, element in
			guard
				let value = element.value as? Int8,
				value != 0
			else {
				return
			}

			identifier += String(UnicodeScalar(UInt8(value)))
		}
		#endif
	}()
}


private func escapeQuery(_ query: String) -> String {
	// From RFC 3986
	let generalDelimiters = ":#[]@"
	let subDelimiters = "!$&'()*+,;="

	var allowedCharacters = CharacterSet.urlQueryAllowed
	allowedCharacters.remove(charactersIn: generalDelimiters + subDelimiters)
	return query.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? query
}


extension Dictionary where Key: ExpressibleByStringLiteral, Value: ExpressibleByStringLiteral {
	var asQueryItems: [URLQueryItem] {
		map {
			URLQueryItem(
				name: escapeQuery($0 as! String),
				value: escapeQuery($1 as! String)
			)
		}
	}

	var asQueryString: String {
		var components = URLComponents()
		components.queryItems = asQueryItems
		return components.query!
	}
}


extension URLComponents {
	mutating func addDictionaryAsQuery(_ dict: [String: String]) {
		percentEncodedQuery = dict.asQueryString
	}
}


extension URL {
	func addingDictionaryAsQuery(_ dict: [String: String]) -> Self {
		var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
		components.addDictionaryAsQuery(dict)
		return components.url ?? self
	}
}


extension StringProtocol {
	/**
	Makes it easier to deal with optional sub-strings.
	*/
	var string: String { String(self) }
}


// swiftlint:disable:next no_cgfloat
extension CGFloat {
	/**
	Get a Double from a CGFloat. This makes it easier to work with optionals.
	*/
	var double: Double { Double(self) }
}

extension Int {
	/**
	Get a Double from an Int. This makes it easier to work with optionals.
	*/
	var double: Double { Double(self) }
}


private struct RespectDisabledViewModifier: ViewModifier {
	@Environment(\.isEnabled) private var isEnabled

	func body(content: Content) -> some View {
		content.opacity(isEnabled ? 1 : 0.5)
	}
}

extension Text {
	/**
	Make some text respect the current view environment being disabled.

	Useful for `Text` label to a control.
	*/
	func respectDisabled() -> some View {
		modifier(RespectDisabledViewModifier())
	}
}


extension URL {
	/**
	Convenience for opening URLs.
	*/
	func open() {
		#if canImport(AppKit)
		NSWorkspace.shared.open(self)
		#elseif canImport(UIKit) && !APP_EXTENSION
		Task { @MainActor in
			UIApplication.shared.open(self)
		}
		#endif
	}
}


extension String {
	/*
	```
	"https://sindresorhus.com".openUrl()
	```
	*/
	func openUrl() {
		URL(string: self)?.open()
	}
}


extension URL: ExpressibleByStringLiteral {
	/**
	Example:

	```
	let url: URL = "https://sindresorhus.com"
	```
	*/
	public init(stringLiteral value: StaticString) {
		self.init(string: "\(value)")!
	}
}


extension URL {
	/**
	Example:

	```
	URL("https://sindresorhus.com")
	```
	*/
	init(_ staticString: StaticString) {
		self.init(string: "\(staticString)")!
	}
}


#if canImport(AppKit)
private struct WindowAccessor: NSViewRepresentable {
	private final class WindowAccessorView: NSView {
		@Binding var windowBinding: NSWindow?

		init(binding: Binding<NSWindow?>) {
			self._windowBinding = binding
			super.init(frame: .zero)
		}

		override func viewDidMoveToWindow() {
			super.viewDidMoveToWindow()
			windowBinding = window
		}

		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError() // swiftlint:disable:this fatal_error_message
		}
	}

	@Binding var window: NSWindow?

	init(_ window: Binding<NSWindow?>) {
		self._window = window
	}

	func makeNSView(context: Context) -> NSView {
		WindowAccessorView(binding: $window)
	}

	func updateNSView(_ nsView: NSView, context: Context) {}
}

extension View {
	/**
	Bind the native backing-window of a SwiftUI window to a property.
	*/
	func bindNativeWindow(_ window: Binding<NSWindow?>) -> some View {
		background(WindowAccessor(window))
	}
}

private struct WindowViewModifier: ViewModifier {
	@State private var window: NSWindow?

	let onWindow: (NSWindow?) -> Void

	func body(content: Content) -> some View {
		onWindow(window)

		return content
			.bindNativeWindow($window)
	}
}

extension View {
	/**
	Access the native backing-window of a SwiftUI window.
	*/
	func accessNativeWindow(_ onWindow: @escaping (NSWindow?) -> Void) -> some View {
		modifier(WindowViewModifier(onWindow: onWindow))
	}

	/**
	Set the window level of a SwiftUI window.
	*/
	func windowLevel(_ level: NSWindow.Level) -> some View {
		accessNativeWindow {
			$0?.level = level
		}
	}
}
#endif


/**
Useful in SwiftUI:

```
ForEach(persons.indexed(), id: \.1.id) { index, person in
	// …
}
```
*/
struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
	typealias Index = Base.Index
	typealias Element = (index: Index, element: Base.Element)

	let base: Base
	var startIndex: Index { base.startIndex }
	var endIndex: Index { base.endIndex }

	func index(after index: Index) -> Index {
		base.index(after: index)
	}

	func index(before index: Index) -> Index {
		base.index(before: index)
	}

	func index(_ index: Index, offsetBy distance: Int) -> Index {
		base.index(index, offsetBy: distance)
	}

	subscript(position: Index) -> Element {
		(index: position, element: base[position])
	}
}

extension RandomAccessCollection {
	/**
	Returns a sequence with a tuple of both the index and the element.

	- Important: Use this instead of `.enumerated()`. See: https://khanlou.com/2017/03/you-probably-don%27t-want-enumerated/
	*/
	func indexed() -> IndexedCollection<Self> {
		IndexedCollection(base: self)
	}
}


extension Numeric {
	mutating func increment(by value: Self = 1) -> Self {
		self += value
		return self
	}

	mutating func decrement(by value: Self = 1) -> Self {
		self -= value
		return self
	}

	func incremented(by value: Self = 1) -> Self {
		self + value
	}

	func decremented(by value: Self = 1) -> Self {
		self - value
	}
}


// TODO
//extension SSApp {
//	private static let key = Defaults.Key("SSApp_requestReview", default: 0)
//
//	/**
//	Requests a review only after this method has been called the given amount of times.
//	*/
//	static func requestReviewAfterBeingCalledThisManyTimes(_ counts: [Int]) {
//		guard
//			!SSApp.isFirstLaunch,
//			counts.contains(Defaults[key].increment())
//		else {
//			return
//		}
//
//		SKStoreReviewController.requestReview()
//	}
//}


#if canImport(AppKit)
extension NSImage {
	/**
	Draw a color as an image.
	*/
	static func color(
		_ color: NSColor,
		size: CGSize,
		borderWidth: Double = 0,
		borderColor: NSColor? = nil,
		cornerRadius: Double? = nil
	) -> Self {
		Self(size: size, flipped: false) { bounds in
			NSGraphicsContext.current?.imageInterpolation = .high

			guard let cornerRadius = cornerRadius else {
				color.drawSwatch(in: bounds)
				return true
			}

			let targetRect = bounds.insetBy(
				dx: borderWidth,
				dy: borderWidth
			)

			let bezierPath = NSBezierPath(
				roundedRect: targetRect,
				xRadius: cornerRadius,
				yRadius: cornerRadius
			)

			color.set()
			bezierPath.fill()

			if
				borderWidth > 0,
				let borderColor = borderColor
			{
				borderColor.setStroke()
				bezierPath.lineWidth = borderWidth
				bezierPath.stroke()
			}

			return true
		}
	}
}
#elseif canImport(UIKit)
extension UIImage {
	static func color(
		_ color: UIColor,
		size: CGSize,
		scale: Double? = nil
	) -> UIImage {
		let format = UIGraphicsImageRendererFormat()
		format.opaque = true

		if let scale = scale {
			format.scale = scale
		}

		return UIGraphicsImageRenderer(size: size, format: format).image { rendererContext in
			color.setFill()
			rendererContext.fill(CGRect(origin: .zero, size: size))
		}
	}
}
#endif


extension SSApp {
	/**
	This is like `SSApp.runOnce()` but let's you have an else-statement too.

	```
	if SSApp.runOnceShouldRun(identifier: "foo") {
		// True only the first time and only once.
	} else {

	}
	```
	*/
	static func runOnceShouldRun(identifier: String) -> Bool {
		let key = "SS_App_runOnce__\(identifier)"

		guard !UserDefaults.standard.bool(forKey: key) else {
			return false
		}

		UserDefaults.standard.set(true, forKey: key)
		return true
	}

	/**
	Run a closure only once ever, even between relaunches of the app.
	*/
	static func runOnce(identifier: String, _ execute: () -> Void) {
		guard runOnceShouldRun(identifier: identifier) else {
			return
		}

		execute()
	}
}


extension Collection {
	func appending(_ newElement: Element) -> [Element] {
		self + [newElement]
	}

	func prepending(_ newElement: Element) -> [Element] {
		[newElement] + self
	}
}


extension Collection {
	var nilIfEmpty: Self? { isEmpty ? nil : self }
}

extension StringProtocol {
	var nilIfEmptyOrWhitespace: Self? { isEmptyOrWhitespace ? nil : self }
}

extension AdditiveArithmetic {
	/**
	Return `nil` if the value is `0`.
	*/
	var nilIfZero: Self? { self == .zero ? nil : self }
}


extension View {
	func multilineText() -> some View {
		lineLimit(nil)
			.fixedSize(horizontal: false, vertical: true)
	}
}


private struct SecondaryTextStyleModifier: ViewModifier {
	@ScaledMetric private var fontSize = XFont.smallSystemFontSize

	func body(content: Content) -> some View {
		content
			.font(.system(size: fontSize))
			.foregroundStyle(.secondary)
	}
}


extension View {
	func secondaryTextStyle() -> some View {
		modifier(SecondaryTextStyleModifier())
	}
}


extension View {
	/**
	Usually used for a verbose description of a settings item.
	*/
	func settingSubtitleTextStyle() -> some View {
		secondaryTextStyle()
			.multilineText()
	}
}


extension String {
	/**
	Returns a random emoticon (part of emojis).

	See: https://en.wikipedia.org/wiki/Emoticons_(Unicode_block)
	*/
	static func randomEmoticon() -> Self {
		let scalarValue = Int.random(in: 0x1F600...0x1F64F)

		guard let scalar = Unicode.Scalar(scalarValue) else {
			// This should in theory never be hit.
			assertionFailure()
			return ""
		}

		return String(scalar)
	}
}


extension String {
	/**
	Returns a version of the string without emoji.

	```
	"foo🦄bar🌈👩‍👩‍👦‍👦".removingEmoji()
	//=> "foobar"
	```
	*/
	func removingEmoji() -> Self {
		Self(unicodeScalars.filter { !$0.properties.isEmojiPresentation })
	}
}


extension Date {
	/**
	Returns a random `Date` within the given range.

	```
	Date.random(in: Date.now...Date.now.addingTimeInterval(10000))
	```
	*/
	static func random(in range: ClosedRange<Self>) -> Self {
		let timeIntervalRange = range.lowerBound.timeIntervalSinceNow...range.upperBound.timeIntervalSinceNow
		return Self(timeIntervalSinceNow: .random(in: timeIntervalRange))
	}
}


extension DateComponents {
	/**
	Returns a random `DateComponents` within the given range.

	The `start` can be after or before `end`.

	```
	let start = Calendar.current.dateComponents(in: .current, from: .now)
	let end = Calendar.current.dateComponents(in: .current, from: .now.addingTimeInterval(1000))
	DateComponents.random(start: start, end: end, for: .current)?.date
	```
	*/
	static func random(start: Self, end: Self, for calendar: Calendar) -> Self? {
		guard
			let startDate = start.date,
			let endDate = end.date
		else {
			return nil
		}

		return calendar.dateComponents(in: .current, from: .random(in: .fromGraceful(startDate, endDate)))
	}
}


extension ClosedRange {
	/**
	Create a `ClosedRange` where it does not matter which bound is upper and lower.

	Using a range literal would hard crash if the lower bound is higher than the upper bound.
	*/
	static func fromGraceful(_ bound1: Bound, _ bound2: Bound) -> Self {
		bound1 <= bound2 ? bound1...bound2 : bound2...bound1
	}
}


enum SortType {
	/**
	This sorting method should be used whenever file names or other strings are presented in lists and tables where Finder-like sorting is appropriate.
	*/
	case natural

	case localized
	case localizedCaseInsensitive
}

extension Sequence where Element: StringProtocol {
	// TODO: Use the new macOS 12, `SortComparator` stuff here: https://developer.apple.com/documentation/foundation/sortcomparator
	// https://developer.apple.com/documentation/swift/sequence/3802502-sorted#
	/**
	Sort a collection of strings.

	```
	let x = ["Kofi", "Abena", "Peter", "Kweku", "Akosua", "abena", "bee", "ábenā"]

	x.sorted(type: .natural)
	//=> ["abena", "Abena", "ábenā", "Akosua", "bee", "Kofi", "Kweku", "Peter"]

	x.sorted(type: .localized)
	//=> ["abena", "Abena", "ábenā", "Akosua", "bee", "Kofi", "Kweku", "Peter"]

	x.sorted(type: .localizedCaseInsensitive)
	//=> ["Abena", "abena", "ábenā", "Akosua", "bee", "Kofi", "Kweku", "Peter"]

	x.sorted()
	//=> ["Abena", "Akosua", "Kofi", "Kweku", "Peter", "abena", "bee", "ábenā"]
	```
	*/
	func sorted(type: SortType, order: SortOrder = .forward) -> [Element] {
		let comparisonResult = order == .forward ? ComparisonResult.orderedAscending : .orderedDescending

		switch type {
		case .natural:
			return sorted { $0.localizedStandardCompare($1) == comparisonResult }
		case .localized:
			return sorted { $0.localizedCompare($1) == comparisonResult }
		case .localizedCaseInsensitive:
			return sorted { $0.localizedCaseInsensitiveCompare($1) == comparisonResult }
		}
	}
}


extension Sequence where Element: StringProtocol {
	/**
	Returns an array with duplicate strings removed, by comparing the string using localized comparison.

	- Parameters:
	  - caseInsensitive: Ignore the case of the characters when comparing.
	  - overrideInclusion: Lets you decide if an individual element should be force included or excluded. This can be useful to, for example, force include multiple empty string elements, which would otherwise be considered duplicates.

	```
	["a", "A", "b", "B"].localizedRemovingDuplicates(caseInsensitive: true)
	//=> ["a", "b"]
	```
	*/
	func localizedRemovingDuplicates(
		caseInsensitive: Bool = false,
		// TODO: Need a better name for this parameter.
		overrideInclusion: ((Element) -> Bool?)? = nil // swiftlint:disable:this discouraged_optional_boolean
	) -> [Element] {
		reduce(into: []) { result, element in
			if let shouldInclude = overrideInclusion?(element) {
				if shouldInclude {
					result.append(element)
				}
				return
			}

			let contains = result.contains {
				caseInsensitive
					? $0.localizedCaseInsensitiveCompare(element) == .orderedSame
					: $0.localizedCompare(element) == .orderedSame
			}

			if !contains {
				result.append(element)
			}
		}
	}
}


extension String {
	/**
	Returns a string with duplicate lines removed, by using localized comparison.

	Empty and whitespace-only lines are preserved.
	*/
	func localizedRemovingDuplicateLines(caseInsensitive: Bool = false) -> Self {
		lines()
			.localizedRemovingDuplicates(caseInsensitive: caseInsensitive) {
				if $0.isEmptyOrWhitespace {
					return true
				}

				return nil
			}
			.joined(separator: "\n")
	}
}


extension Sequence {
	/**
	Returns an array with duplicates removed by checking for duplicates based on the given key path.

	```
	let a = [CGPoint(x: 1, y: 1), CGPoint(x: 2, y: 1), CGPoint(x: 1, y: 2)]
	let b = a.removingDuplicates(by: \.y)
	//=> [CGPoint(x: 1, y: 1), CGPoint(x: 1, y: 2)]
	```
	*/
	func removingDuplicates<T: Equatable>(by keyPath: KeyPath<Element, T>) -> [Element] {
		var result = [Element]()
		var seen = [T]()
		for value in self {
			let key = value[keyPath: keyPath]
			if !seen.contains(key) {
				seen.append(key)
				result.append(value)
			}
		}
		return result
	}

	/**
	Returns an array with duplicates removed by checking for duplicates based on the given key path.

	```
	let a = [CGPoint(x: 1, y: 1), CGPoint(x: 2, y: 1), CGPoint(x: 1, y: 2)]
	let b = a.removingDuplicates(by: \.y)
	//=> [CGPoint(x: 1, y: 1), CGPoint(x: 1, y: 2)]
	```
	*/
	func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
		var seenKeys = Set<T>()
		return filter { seenKeys.insert($0[keyPath: keyPath]).inserted }
	}
}


extension String {
	/**
	Returns a version of the string with the first character lowercased.
	*/
	var lowercasedFirstCharacter: String {
		prefix(1).lowercased() + dropFirst()
	}

	/**
	Returns a version of the string transformed to pascal case.
	*/
	func pascalCasing() -> Self {
		guard !isEmpty else {
			return ""
		}

		return components(separatedBy: .alphanumerics.inverted)
			.map(\.capitalized)
			.joined()
	}

	/**
	Returns a version of the string transformed to pascal case.
	*/
	func camelCasing() -> Self {
		guard !isEmpty else {
			return ""
		}

		return pascalCasing().lowercasedFirstCharacter
	}

	private func delimiterCasing(delimiter: String) -> String {
		guard !isEmpty else {
			return ""
		}

		return components(separatedBy: .alphanumerics.inverted)
			.filter { !$0.isEmpty }
			.map { $0.lowercased() }
			.joined(separator: delimiter)
	}

	/**
	Returns a version of the string transformed to snake case.
	*/
	func snakeCasing() -> String {
		delimiterCasing(delimiter: "_")
	}

	/**
	Returns a version of the string transformed to constant case.
	*/
	func constantCasing() -> String {
		snakeCasing().uppercased()
	}

	/**
	Returns a version of the string transformed to dash case.
	*/
	func dashCasing() -> String {
		delimiterCasing(delimiter: "-")
	}
}


extension Comparable {
	/**
	```
	20.5.clamped(to: 10.3...15)
	//=> 15
	```
	*/
	func clamped(to range: ClosedRange<Self>) -> Self {
		min(max(self, range.lowerBound), range.upperBound)
	}
}


extension StringProtocol {
	/**
	Check if the string only contains whitespace characters.
	*/
	var isWhitespace: Bool {
		allSatisfy(\.isWhitespace)
	}

	/**
	Check if the string is empty or only contains whitespace characters.
	*/
	var isEmptyOrWhitespace: Bool { isEmpty || isWhitespace }
}


extension String {
	func lines() -> [Self] {
		components(separatedBy: .newlines)
	}
}


extension String {
	/**
	Returns a string with empty or whitespace-only lines removed.
	*/
	func removingEmptyLines() -> Self {
		lines()
			.filter { !$0.isEmptyOrWhitespace }
			.joined(separator: "\n")
	}
}


extension XColor {
	/**
	Generate a random color, avoiding black and white.
	*/
	static func randomAvoidingBlackAndWhite() -> Self {
		self.init(
			hue: .random(in: 0...1),
			saturation: .random(in: 0.5...1), // 0.5 is to get away from white
			brightness: .random(in: 0.5...1), // 0.5 is to get away from black
			alpha: 1
		)
	}
}


#if canImport(UIKit)
// swiftlint:disable no_cgfloat
extension UIColor {
	/**
	AppKit polyfill.

	The alpha (opacity) component value of the color.
	*/
	var alphaComponent: CGFloat {
		var alpha: CGFloat = 0
		getRed(nil, green: nil, blue: nil, alpha: &alpha)
		return alpha
	}

	var redComponent: CGFloat {
		var red: CGFloat = 0
		getRed(&red, green: nil, blue: nil, alpha: nil)
		return red
	}

	var greenComponent: CGFloat {
		var green: CGFloat = 0
		getRed(nil, green: &green, blue: nil, alpha: nil)
		return green
	}

	var blueComponent: CGFloat {
		var blue: CGFloat = 0
		getRed(nil, green: nil, blue: &blue, alpha: nil)
		return blue
	}
}
// swiftlint:enable no_cgfloat
#endif


extension XColor {
	/**
	- Important: Don't forget to convert it to the correct color space first.
	*/
	var hex: Int {
		#if canImport(AppKit)
		guard numberOfComponents == 4 else {
			assertionFailure()
			return 0x0
		}
		#endif

		let red = Int((redComponent * 0xFF).rounded())
		let green = Int((greenComponent * 0xFF).rounded())
		let blue = Int((blueComponent * 0xFF).rounded())

		return red << 16 | green << 8 | blue
	}

	/**
	- Important: Don't forget to convert it to the correct color space first.
	*/
	var hexString: String {
		String(format: "#%06x", hex)
	}
}


extension String {
	/**
	Check if the string starts with the given prefix and prepend it if not.

	```
	" Bar".ensurePrefix("Foo")
	//=> "Foo Bar"
	"Foo Bar".ensurePrefix("Foo")
	//=> "Foo Bar"
	```
	*/
	func ensurePrefix(_ prefix: Self) -> Self {
		hasPrefix(prefix) ? self : (prefix + self)
	}

	/**
	Check if the string ends with the given suffix and append it if not.

	```
	"Foo ".ensureSuffix("Bar")
	//=> "Foo Bar"
	"Foo Bar".ensureSuffix("Bar")
	//=> "Foo Bar"
	```
	*/
	func ensureSuffix(_ suffix: Self) -> Self {
		hasSuffix(suffix) ? self : (self + suffix)
	}
}


extension StringProtocol {
	/**
	```
	"foo bar".replacingPrefix("foo", with: "unicorn")
	//=> "unicorn bar"
	```
	*/
	func replacingPrefix(_ prefix: String, with replacement: String) -> String {
		guard hasPrefix(prefix) else {
			return String(self)
		}

		return replacement + dropFirst(prefix.count)
	}

	/**
	```
	"foo bar".replacingSuffix("bar", with: "unicorn")
	//=> "foo unicorn"
	```
	*/
	func replacingSuffix(_ suffix: String, with replacement: String) -> String {
		guard hasSuffix(suffix) else {
			return String(self)
		}

		return dropLast(suffix.count) + replacement
	}
}


extension URL {
	/**
	Returns the user's real home directory when called in a sandboxed app.
	*/
	static let realHomeDirectory = Self(
		fileURLWithFileSystemRepresentation: getpwuid(getuid())!.pointee.pw_dir!,
		isDirectory: true,
		relativeTo: nil
	)
}


extension URL {
	var tildePath: String {
		// Note: Can't use `FileManager.default.homeDirectoryForCurrentUser.relativePath` or `NSHomeDirectory()` here as they return the sandboxed home directory, not the real one.
		path.replacingPrefix(Self.realHomeDirectory.path, with: "~")
	}
}


extension Sequence {
	/**
	Returns an array of elements split into groups of the given size.

	If it can't be split evenly, the final chunk will be the remaining elements.

	If the requested chunk size is larger than the sequence, the chunk will be smaller than requested.

	```
	[1, 2, 3, 4].chunked(by: 2)
	//=> [[1, 2], [3, 4]]
	```
	*/
	func chunked(by chunkSize: Int) -> [[Element]] {
		guard chunkSize > 0 else {
			return []
		}

		return reduce(into: []) { result, current in
			if
				let last = result.last,
				last.count < chunkSize
			{
				result.append(result.removeLast() + [current])
			} else {
				result.append([current])
			}
		}
	}
}


extension Collection {
	/**
	Returns the element at the specified index if it is within bounds, otherwise `nil`.
	*/
	subscript(safe index: Index) -> Element? {
		indices.contains(index) ? self[index] : nil
	}
}


extension Collection {
	/**
	Returns the second element if it exists, otherwise `nil`.
	*/
	var second: Element? {
		self[safe: index(startIndex, offsetBy: 1)]
	}
}


#if !APP_EXTENSION
enum ShortcutsApp {
	@MainActor
	static func open() {
		"shortcuts://".openUrl()
	}

	@MainActor
	static func createShortcut() {
		"shortcuts://create-shortcut".openUrl()
	}
}
#endif


enum OperatingSystem {
	case macOS
	case iOS
	case tvOS
	case watchOS

	#if os(macOS)
	static let current = macOS
	#elseif os(iOS)
	static let current = iOS
	#elseif os(tvOS)
	static let current = tvOS
	#elseif os(watchOS)
	static let current = watchOS
	#else
	#error("Unsupported platform")
	#endif
}

typealias OS = OperatingSystem

extension View {
	/**
	Conditionally apply modifiers depending on the target operating system.

	```
	struct ContentView: View {
		var body: some View {
			Text("Unicorn")
				.font(.system(size: 10))
				.ifOS(.macOS, .tvOS) {
					$0.font(.system(size: 20))
				}
		}
	}
	```
	*/
	@ViewBuilder
	func ifOS<Content: View>(
		_ operatingSystems: OperatingSystem...,
		modifier: (Self) -> Content
	) -> some View {
		if operatingSystems.contains(.current) {
			modifier(self)
		} else {
			self
		}
	}
}


extension View {
	/**
	Embed the view in a scroll view.
	*/
	@ViewBuilder
	func embedInScrollView(shouldEmbed: Bool = true, alignment: Alignment = .center) -> some View {
		if shouldEmbed {
			GeometryReader { proxy in
				ScrollView {
					frame(
						minHeight: proxy.size.height,
						maxHeight: .infinity,
						alignment: alignment
					)
				}
			}
		} else {
			self
		}
	}
}


private struct EmbedInScrollViewIfAccessibilitySizeModifier: ViewModifier {
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	let alignment: Alignment

	func body(content: Content) -> some View {
		content.embedInScrollView(shouldEmbed: dynamicTypeSize.isAccessibilitySize, alignment: alignment)
	}
}

extension View {
	/**
	Embed the view in a scroll view if the system has accessibility dynamic type enabled.
	*/
	func embedInScrollViewIfAccessibilitySize(alignment: Alignment = .center) -> some View {
		modifier(EmbedInScrollViewIfAccessibilitySizeModifier(alignment: alignment))
	}
}


private struct ActuallyHiddenIfAccessibilitySizeModifier: ViewModifier {
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	func body(content: Content) -> some View {
		if !dynamicTypeSize.isAccessibilitySize {
			content
		}
	}
}

extension View {
	/**
	Excludes the view from the hierarchy if the device has enabled accessibility size text.
	*/
	func actuallyHiddenIfAccessibilitySize() -> some View {
		modifier(ActuallyHiddenIfAccessibilitySizeModifier())
	}
}


/**
Modern alternative to `OptionSet`.

Just use an enum instead.

```
typealias Toppings = Set<Topping>

enum Topping: String, Option {
	case pepperoni
	case onions
	case bacon
	case extraCheese
	case greenPeppers
	case pineapple
}
```
*/
protocol Option: RawRepresentable, Hashable, CaseIterable {}

extension Set where Element: Option {
	var rawValue: Int {
		var rawValue = 0
		for (index, element) in Element.allCases.enumerated() {
			if contains(element) {
				rawValue |= (1 << index)
			}
		}

		return rawValue
	}

	var description: String {
		map { String(describing: $0) }.joined(separator: ", ")
	}
}


extension String {
	/**
	Returns a persistent non-crypto hash of the string in the fastest way possible.

	- Note: This exists as `.hashValue` is not guaranteed to be equal across different executions of your program.
	*/
	var persistentHash: UInt64 {
		var result: UInt64 = 5381
		let buffer = [UInt8](utf8)

		for element in buffer {
			result = 127 * (result & 0x00ffffffffffffff) + UInt64(element)
		}

		return result
	}
}


extension RandomNumberGenerator where Self == SystemRandomNumberGenerator {
	/**
	```
	random(length: length, using: &.system)
	```
	*/
	static var system: Self {
		get { .init() }
		set {} // swiftlint:disable:this unused_setter_value
	}
}


/**
A type-erased random number generator.
*/
struct AnyRandomNumberGenerator: RandomNumberGenerator {
	@usableFromInline
	var enclosed: RandomNumberGenerator

	@inlinable
	init(_ enclosed: RandomNumberGenerator) {
		self.enclosed = enclosed
	}

	@inlinable
	mutating func next() -> UInt64 {
		enclosed.next()
	}
}

extension RandomNumberGenerator {
	/**
	Type-erase the random number generator.
	*/
	func eraseToAny() -> AnyRandomNumberGenerator {
		AnyRandomNumberGenerator(self)
	}
}


#if !os(watchOS)
struct SeededRandomNumberGenerator: RandomNumberGenerator {
	private let source: GKMersenneTwisterRandomSource

	init(seed: UInt64) {
		self.source = GKMersenneTwisterRandomSource(seed: seed)
	}

	init(seed: String) {
		self.init(seed: seed.persistentHash)
	}

	func next() -> UInt64 {
		let next1 = UInt64(bitPattern: Int64(source.nextInt()))
		let next2 = UInt64(bitPattern: Int64(source.nextInt()))
		return next1 ^ (next2 << 32)
	}
}
#endif


extension String {
	enum RandomCharacter: String, Option {
		case lowercase
		case uppercase
		case digits
	}

	typealias RandomCharacters = Set<RandomCharacter>

	/**
	Generate a random ASCII string from a custom set of characters.

	```
	String.random(length: 10, characters: "abc123")
	//=> "ca32aab12c"
	```
	*/
	static func random<T>(
		length: Int,
		characters: String,
		using generator: inout T
	) -> Self where T: RandomNumberGenerator {
		precondition(!characters.isEmpty)
		return Self((0..<length).map { _ in characters.randomElement(using: &generator)! })
	}

	/**
	Generate a random ASCII string from a custom set of characters.

	```
	String.random(length: 10, characters: "abc123")
	//=> "ca32aab12c"
	```
	*/
	static func random(
		length: Int,
		characters: String
	) -> Self {
		random(length: length, characters: characters, using: &.system)
	}

	/**
	Generate a random ASCII string.

	```
	String.random(length: 10, characters: [.lowercase])
	//=> "czzet1fv6d"
	```
	*/
	static func random<T>(
		length: Int,
		characters: RandomCharacters = [.lowercase, .uppercase, .digits],
		using generator: inout T
	) -> Self where T: RandomNumberGenerator {
		var characterString = ""

		if characters.contains(.lowercase) {
			characterString += "abcdefghijklmnopqrstuvwxyz"
		}

		if characters.contains(.uppercase) {
			characterString += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		}

		if characters.contains(.digits) {
			characterString += "0123456789"
		}

		return random(length: length, characters: characterString, using: &generator)
	}

	/**
	Generate a random ASCII string.

	```
	String.random(length: 10, characters: [.lowercase])
	//=> "czzetefvgd"
	```
	*/
	static func random(
		length: Int,
		characters: RandomCharacters = [.lowercase, .uppercase, .digits]
	) -> Self {
		random(length: length, characters: characters, using: &.system)
	}
}


extension RangeReplaceableCollection {
	func removingSubrange<R>(_ bounds: R) -> Self where R: RangeExpression, Index == R.Bound {
		var copy = self
		copy.removeSubrange(bounds)
		return copy
	}
}


extension Collection {
	/**
	Returns a sequence with a tuple of both the index and the element.
	*/
	func indexed() -> Zip2Sequence<Indices, Self> {
		zip(indices, self)
	}
}


extension Collection where Index: Hashable {
	/**
	Returns an array with elements at the given offsets (indices) removed.

	Invalid indices are ignored.

	```
	[1, 2, 3, 4].removing(atIndices: [0, 3])
	//=> [2, 3]
	```

	See the built-in `remove(atOffset:)` for a mutable version.
	*/
	func removing(atIndices indices: [Index]) -> [Element] {
		let indiceSet = Set(indices)
		return indexed().filter { !indiceSet.contains($0.0) }.map(\.1)
	}
}


extension Locale {
	/**
	Unix representation of locale usually used for normalizing.
	*/
	static let posix = Self(identifier: "en_US_POSIX")
}


extension URL {
	private func resourceValue<T>(forKey key: URLResourceKey) -> T? {
		guard let values = try? resourceValues(forKeys: [key]) else {
			return nil
		}

		return values.allValues[key] as? T
	}

	/**
	Set multiple resources values in one go.

	```
	try destinationURL.setResourceValues {
		if let creationDate = creationDate {
			$0.creationDate = creationDate
		}

		if let modificationDate = modificationDate {
			$0.contentModificationDate = modificationDate
		}
	}
	```
	*/
	func setResourceValues(with closure: (inout URLResourceValues) -> Void) throws {
		var copy = self
		var values = URLResourceValues()
		closure(&values)
		try copy.setResourceValues(values)
	}

	var contentType: UTType? { resourceValue(forKey: .contentTypeKey) }
}


extension CGImage {
	/**
	Get metadata from an image on disk.

	- Returns: `CGImageProperties` https://developer.apple.com/documentation/imageio/cgimageproperties
	*/
	static func metadata(_ url: URL) -> [String: Any] {
		guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
			return [:]
		}

		return CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] ?? [:]
	}

	/**
	Get metadata from an image in memory.

	- Returns: `CGImageProperties` https://developer.apple.com/documentation/imageio/cgimageproperties
	*/
	static func metadata(_ data: Data) -> [String: Any] {
		guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
			return [:]
		}

		return CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] ?? [:]
	}
}


extension URL {
	/**
	Creates a unique temporary directory and returns the URL.

	The URL is unique for each call.

	The system ensures the directory is not cleaned up until after the app quits.
	*/
	static func uniqueTemporaryDirectory(
		appropriateFor: Self = Bundle.main.bundleURL
	) throws -> Self {
		try FileManager.default.url(
			for: .itemReplacementDirectory,
			in: .userDomainMask,
			appropriateFor: appropriateFor,
			create: true
		)
	}

	/**
	Copy the file at the current URL to a unique temporary directory and return the new URL.
	*/
	func copyToUniqueTemporaryDirectory() throws -> Self {
		let destinationUrl = try Self.uniqueTemporaryDirectory(appropriateFor: self)
			.appendingPathComponent(lastPathComponent, isDirectory: false)

		try FileManager.default.copyItem(at: self, to: destinationUrl)

		return destinationUrl
	}
}


extension Data {
	/**
	Write the data to a unique temporary path and return the `URL`.

	By default, the file has no file extension.
	*/
	func writeToUniqueTemporaryFile(
		filename: String = "file",
		contentType: UTType = .data
	) throws -> URL {
		let destinationUrl = try URL.uniqueTemporaryDirectory()
			.appendingPathComponent(filename, conformingTo: contentType)

		try write(to: destinationUrl)

		return destinationUrl
	}
}


extension CGImage {
	// TODO: Use the modern macOS 12 API for parsing dates.
	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = .posix
		formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
		return formatter
	}()

	private static func captureDateFromMetadata(_ metadata: [String: Any]) -> Date? {
		guard
			let exifDictionary = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any],
			let dateTimeOriginal = exifDictionary[kCGImagePropertyExifDateTimeOriginal as String] as? String,
			let captureDate = dateFormatter.date(from: dateTimeOriginal)
		else {
			return nil
		}

		return captureDate
	}

	/**
	Returns the original capture date & time from the Exif metadata of the image at the given URL.
	*/
	static func captureDate(ofImageAt url: URL) -> Date? {
		captureDateFromMetadata(metadata(url))
	}

	/**
	Returns the original capture date & time from the Exif metadata of the image data.
	*/
	static func captureDate(ofImage data: Data) -> Date? {
		captureDateFromMetadata(metadata(data))
	}
}


extension INFile {
	var contentType: UTType? {
		guard let typeIdentifier = typeIdentifier else {
			return nil
		}

		return UTType(typeIdentifier)
	}
}


extension INFile {
	/**
	Write the data to a unique temporary path and return the `URL`.
	*/
	func writeToUniqueTemporaryFile() throws -> URL {
		try data.writeToUniqueTemporaryFile(
			filename: filename,
			contentType: contentType ?? .data
		)
	}
}


extension INFile {
	/**
	Gives you a copy of the file written to disk which you can modify as you please.

	You are expected to return a file URL to the same or a different file.

	- Note: If you just need to modify the data, access `.data` instead.

	Use-cases:
	- Change modification date of a file.
	- Set Exif metadata.
	- Convert to a different file type.

	We intentionally do not use `.fileURL` as accessing it when the file is, for example, in the `Downloads` directory, causes a permission prompt on macOS, which requires manual interaction.
	*/
	func modifyingFileAsURL(_ modify: (URL) throws -> URL) throws -> INFile {
		try modify(writeToUniqueTemporaryFile()).toINFile
	}
}


extension URL {
	/**
	Create a `INFile` from the URL.
	*/
	var toINFile: INFile {
		INFile(
			fileURL: self,
			filename: lastPathComponent,
			typeIdentifier: contentType?.identifier
		)
	}
}


extension Sequence {
	func compact<T>() -> [T] where Element == T? {
		// TODO: Make this `compactMap(\.self)` when https://bugs.swift.org/browse/SR-12897 is fixed.
		compactMap { $0 }
	}
}


extension Sequence where Element: Sequence {
	func flatten() -> [Element.Element] {
		// TODO: Make this `flatMap(\.self)` when https://bugs.swift.org/browse/SR-12897 is fixed.
		flatMap { $0 }
	}
}
