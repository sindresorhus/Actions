import SwiftUI
import Combine
import StoreKit
import GameplayKit
import UniformTypeIdentifiers
import Intents
import IntentsUI
import CoreBluetooth
import CoreLocation
import Contacts
import AudioToolbox
import SystemConfiguration
import Network
import TabularData
import Speech
import NaturalLanguage
import JavaScriptCore
import CoreImage.CIFilterBuiltins
import AppIntents
import PDFKit
import os
import MapKit
import Sentry

#if os(macOS)
import IOKit.ps
import CoreWLAN
import ApplicationServices

typealias XColor = NSColor
typealias XFont = NSFont
typealias XImage = NSImage
typealias XPasteboard = NSPasteboard
typealias XApplication = NSApplication
typealias XApplicationDelegate = NSApplicationDelegate
typealias XApplicationDelegateAdaptor = NSApplicationDelegateAdaptor
typealias XScreen = NSScreen
typealias XAccessibility = NSAccessibility
typealias XTextContentType = NSTextContentType
typealias WindowIfMacOS = Window
#else
import VisionKit
import CoreMotion
import CallKit

typealias XColor = UIColor
typealias XFont = UIFont
typealias XImage = UIImage
typealias XPasteboard = UIPasteboard
typealias XApplication = UIApplication
typealias XApplicationDelegate = UIApplicationDelegate
typealias XApplicationDelegateAdaptor = UIApplicationDelegateAdaptor
typealias XScreen = UIScreen
typealias XAccessibility = UIAccessibility
typealias XTextContentType = UITextContentType
typealias WindowIfMacOS = WindowGroup
#endif

// TODO: See if I can remove any of these when targeting macOS 15.
// TODO: Remove me when it's support it natively.
#if os(macOS)
extension NSRunningApplication: @unchecked Sendable {}
extension NSWorkspace.OpenConfiguration: @unchecked Sendable {}
extension NSImage: @unchecked Sendable {}
#endif


// TODO: Remove this when everything is converted to async/await.
func delay(_ duration: Duration, closure: @escaping () -> Void) {
	DispatchQueue.main.asyncAfter(deadline: .now() + duration.toTimeInterval, execute: closure)
}


func sleep(_ duration: Duration) {
	let durationInMicroseconds = duration.toTimeInterval * Double(USEC_PER_SEC)
	assert(durationInMicroseconds <= Double(UInt32.max), "The given duration overflows the `sleep` method")
	let clampedDuration = min(durationInMicroseconds, Double(UInt32.max))
	usleep(UInt32(clampedDuration))
}


enum SSApp {
	static let idString = Bundle.main.bundleIdentifier!
	static let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
	static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	static let build = Int(Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String)!
	static let versionWithBuild = "\(version) (\(build))"
	static let url = Bundle.main.bundleURL

	#if DEBUG
	static let isDebug = true
	#else
	static let isDebug = false
	#endif

	static var isDarkMode: Bool {
		#if os(macOS)
			// The `effectiveAppearance` check does not detect dark mode in an intent handler extension.
			#if APP_EXTENSION
			UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
			#else
			NSApp?.effectiveAppearance.isDarkMode ?? false
			#endif
		#else
		UIScreen.main.traitCollection.userInterfaceStyle == .dark
		#endif
	}

	#if os(macOS)
	static func quit() {
		Task { @MainActor in
			NSApp.terminate(nil)
		}
	}
	#endif

	#if canImport(UIKit)
	/**
	Move the app to the background, which returns the user to their home screen.
	*/
	@available(iOSApplicationExtension, unavailable)
	static func moveToBackground() {
		Task { @MainActor in
			UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
		}
	}
	#endif

	static let isFirstLaunch: Bool = {
		let key = "SS_hasLaunched"

		if UserDefaults.standard.bool(forKey: key) {
			return false
		}

		UserDefaults.standard.set(true, forKey: key)
		return true
	}()

	/**
	The date and time the app was launched for the first time.
	*/
	static let firstLaunchDate: Date = {
		let key = "SS_firstLaunchDate"

		if let date = UserDefaults.standard.object(forKey: key) as? Date {
			return date
		}

		let date = Date()
		UserDefaults.standard.set(date, forKey: key)
		return date
	}()

	private static func getFeedbackMetadata() -> String {
		"""
		\(name) \(versionWithBuild) - \(idString)
		\(Device.operatingSystemString)
		\(Device.modelIdentifier)
		"""
	}

	static func openSendFeedbackPage() {
		let query: [String: String] = [
			"product": name,
			"metadata": getFeedbackMetadata()
		]

		URL("https://sindresorhus.com/feedback")
			.addingDictionaryAsQuery(query)
			.open()
	}

	static func sendFeedback(
		email: String,
		message: String
	) async throws {
		let endpoint = URL("https://formcarry.com/s/UBfgr97yfY")

		let parameters = [
			"_gotcha": nil, // Spam prevention.
			"timestamp": "\(Int(Date.now.timeIntervalSince1970))",
			"product": name,
			"metadata": getFeedbackMetadata(),
			"email": email.lowercased(),
			"message": message
		]

		_ = try await URLSession.shared.json(.post, url: endpoint, parameters: parameters as [String: Any])
	}
}


extension SSApp {
	/**
	Initialize Sentry.
	*/
	static func initSentry(_ dsn: String) {
		#if !DEBUG && canImport(Sentry)
		SentrySDK.start {
			$0.dsn = dsn
			$0.enableSwizzling = false
			$0.enableAppHangTracking = false // https://github.com/getsentry/sentry-cocoa/issues/2643
		}
		#endif
	}
}


extension NSObject {
	/**
	Returns the class name without module name.
	*/
	static var simpleClassName: String { String(describing: self) }

	/**
	Returns the class name of the instance without module name.
	*/
	var simpleClassName: String { Self.simpleClassName }
}


extension Error {
	/**
	Whether the error was originally created as an `NSError`.
	*/
	var isNSError: Bool {
		(self as NSError).simpleClassName != "__SwiftNativeNSError"
	}
}


extension NSError {
	static func from(error: Error, userInfo: [String: Any] = [:]) -> NSError {
		let nsError = error as NSError

		// Since Error and NSError are often bridged between each other, we check if it was originally an NSError and then return that. If the code is 1 we still wrap it even though it's an NSError to get better Sentry reporting.
		guard !error.isNSError || nsError.code == 1 else {
			guard !userInfo.isEmpty else {
				return nsError
			}

			return nsError.appending(userInfo: userInfo)
		}

		var userInfo = nsError.userInfo.appending(userInfo)
		userInfo[NSLocalizedDescriptionKey] = error.localizedDescription

		// Awful, but no better way to get the enum case name.
		// This gets `Error.generateFrameFailed` from `Error.generateFrameFailed(Error Domain=AVFoundationErrorDomain Code=-11832 […]`.
		let errorName = "\(error)".split(separator: "(").first ?? ""

		return .init(
			domain: "\(nsError.domain)\(errorName.isEmpty ? "" : ".")\(errorName)",
			code: nsError.code,
			userInfo: userInfo
		)
	}

	/**
	Returns a new error with the user info appended.
	*/
	func appending(userInfo newUserInfo: [String: Any]) -> NSError {
		// Cannot use `Self` here: https://github.com/apple/swift/issues/58046
		NSError(
			domain: domain,
			code: code,
			userInfo: userInfo.appending(newUserInfo)
		)
	}
}

extension SSApp {
	@inlinable
	static func reportError(
		_ error: Error,
		userInfo: [String: Any] = [:],
		file: String = #fileID,
		line: Int = #line
	) {
		guard !(error is CancellationError) else {
			#if DEBUG
			print("[\(file):\(line)] CancellationError:", error)
			#endif
			return
		}

		let userInfo = userInfo
			.appendingIfNotHasKey([
				"file": file,
				"line": line
			])

		let error = NSError.from(
			error: error,
			userInfo: userInfo
		)

		#if DEBUG
		print("[\(file):\(line)] Reporting error:", error)
		#endif

		#if canImport(Sentry)
		SentrySDK.capture(error: error)
		#endif
	}

	@inlinable
	static func reportError(
		_ message: String,
		userInfo: [String: Any] = [:],
		file: String = #fileID,
		line: Int = #line
	) {
		reportError(
			message.toError,
			userInfo: userInfo,
			file: file,
			line: line
		)
	}
}

extension Error {
	@discardableResult
	func report(
		userInfo: [String: Any] = [:],
		file: String = #file,
		line: Int = #line
	) -> Self {
		SSApp.reportError(
			self,
			userInfo: userInfo,
			file: file,
			line: line
		)

		return self
	}
}

extension SSApp {
	/**
	Adds a breadcrumb for Sentry crash reporting.
	*/
	static func addBreadcrumb(
		_ message: String,
		data: [String: Any]? = nil // swiftlint:disable:this discouraged_optional_collection
	) {
		#if !DEBUG && canImport(Sentry)
		let breadcrumb = Breadcrumb(level: .info, category: "app.ss")

		breadcrumb.message = message

		if let data {
			breadcrumb.data = data
		}

		SentrySDK.addBreadcrumb(breadcrumb)
		#endif
	}
}


extension Dictionary {
	/**
	Check if the dictionary has the given key.

	- Note: Should in theory be faster than `Dictionary#keys.contains()`.
	*/
	func hasKey(_ key: Key) -> Bool {
		index(forKey: key) != nil
	}
}


extension Dictionary {
	/**
	Adds the elements of the given dictionary to a copy of self and returns that.

	Identical keys in the given dictionary overwrites keys in the copy of self.

	- Note: This exists as an addition to `+` as Swift sometimes struggle to infer the type of `dict + dict`.
	*/
	func appending(_ dictionary: Self) -> Self {
		self + dictionary
	}
}


extension Dictionary {
	/**
	Appends each item in the given dictionary where the key don't already exists.
	*/
	func appendingIfNotHasKey(_ dictionary: Self) -> Self {
		var copy = self

		for (key, value) in dictionary {
			guard !copy.hasKey(key) else {
				continue
			}

			copy[key] = value
		}

		return copy
	}
}


#if os(macOS)
extension NSAppearance {
	var isDarkMode: Bool { bestMatch(from: [.darkAqua, .aqua]) == .darkAqua }
}
#endif


extension CGSize {
	static func * (lhs: Self, rhs: Double) -> Self {
		.init(width: lhs.width * rhs, height: lhs.height * rhs)
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
	#if os(macOS)
	private static func ioPlatformExpertDevice(key: String) -> CFTypeRef? {
		let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
		defer {
			IOObjectRelease(service)
		}

		return IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue()
	}
	#endif

	/**
	The name of the operating system running on the device.

	```
	Device.operatingSystemName
	//=> "macOS"

	Device.operatingSystemName
	//=> "iOS"
	```
	*/
	static let operatingSystemName: String = {
		#if os(macOS)
		"macOS"
		#else
		UIDevice.current.systemName
		#endif
	}()

	/**
	The version of the operating system running on the device.

	```
	// macOS
	Device.operatingSystemVersion
	//=> "10.14.2"

	// iOS
	Device.operatingSystemVersion
	//=> "13.5.1"
	```
	*/
	static let operatingSystemVersion: String = {
		#if os(macOS)
		let os = ProcessInfo.processInfo.operatingSystemVersion
		return "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
		#else
		UIDevice.current.systemVersion
		#endif
	}()

	/**
	The name and version of the operating system running on the device.

	```
	// macOS
	Device.operatingSystemString
	//=> "macOS 10.14.2"

	// iOS
	Device.operatingSystemString
	//=> "iOS 13.5.1"
	```
	*/
	static let operatingSystemString = "\(operatingSystemName) \(operatingSystemVersion)"

	/**
	```
	Device.modelIdentifier
	//=> "MacBookPro11,3"

	Device.modelIdentifier
	//=> "iPhone12,8"
	```
	*/
	static let modelIdentifier: String = {
		#if os(macOS)
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
		"Simulator"
		#else
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

	/**
	Check if the device is connected to a VPN.
	*/
	@available(macOS, unavailable)
	static var isConnectedToVPN: Bool {
		guard
			let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as NSDictionary? as? [String: Any],
			let scoped = proxySettings["__SCOPED__"] as? [String: Any]
		else {
			return false
		}

		let vpnKeys = [
			"tap",
			"tun",
			"ppp",
			"ipsec",
			"utun"
		]

		return scoped.keys.contains { key in
			vpnKeys.contains { key.hasPrefix($0) }
		}
	}

	/**
	Whether the device has a small screen.

	This is useful for detecting iPhone SE and iPhone 6S, which has a very small screen and are still supported.

	On macOS, it always returns false.
	*/
	static let hasSmallScreen: Bool = {
		#if os(macOS)
		false
		#else
		UIScreen.main.bounds.height < 700
		#endif
	}()

	@available(iOS, unavailable)
	@available(tvOS, unavailable)
	@available(watchOS, unavailable)
	@available(macOSApplicationExtension, unavailable) // `CGSessionCopyCurrentDictionary()` returns `nil` in an app extension.
	static var isScreenLocked: Bool {
		#if canImport(Quartz)
		let key = String("dekcoLsIneercSnoisseSSGC".reversed())
		let dictionary = CGSessionCopyCurrentDictionary() as? [String: Any]
		return dictionary?[key] as? Bool ?? false
		#else
		false
		#endif
	}

	/**
	Whether Wi-Fi is available and powered on.
	*/
	@available(iOS, unavailable)
	@available(tvOS, unavailable)
	@available(watchOS, unavailable)
	static var isWiFiOn: Bool {
		#if canImport(CoreWLAN)
		CWWiFiClient.shared().interface()?.powerOn() ?? false
		#else
		false
		#endif
	}

	/**
	Returns a timestamp representing the current instant in nanoseconds.
	*/
	static var timestamp: Int { Int(clamping: clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW)) }

	/**
	The uptime of the system, not incuding sleep.
	*/
	static var uptime: Duration { ProcessInfo.processInfo.systemUptime.timeIntervalToDuration }

	/**
	The uptime of the system including sleep. Also known as monotonic clock time.
	*/
	static var uptimeIncludingSleep: Duration {
		.nanoseconds(clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW_APPROX))
	}

	static var isAccelerometerAvailable: Bool {
		#if os(macOS)
		false
		#else
		CMMotionManager().isAccelerometerAvailable
		#endif
	}

	/**
	Check if the device currently has an active call.

	On macOS, it's always `false`.
	*/
	static var hasActiveCall: Bool {
		#if os(macOS)
		false
		#else
		CXCallObserver().calls.contains { !$0.hasEnded }
		#endif
	}
}


#if canImport(UIKit)
extension Device {
	/**
	Creates an asynchronous stream that continuously checks if the device is moving.

	This function utilizes the device's accelerometer to determine if the device is in motion. It compares the absolute values of the accelerometer's x, y, and z axis readings against a specified threshold to detect movement.

	- Parameters:
	 - minAcceleration: The minimum acceleration on any axis to consider the device as moving, measured in gravitational force units (G's).
	*/
	static func isMovingUpdates(minAcceleration threshold: Double) -> AsyncThrowingStream<Bool, Error> {
		motionUpdates(interval: .seconds(0.1))
			.map {
				let acceleration = $0.userAcceleration
				return abs(acceleration.x) > threshold
					|| abs(acceleration.y) > threshold
					|| abs(acceleration.z) > threshold
			}
			.eraseToAsyncThrowingStream()
	}

	static var didShake: AsyncThrowingStream<Void, Error> {
		isMovingUpdates(minAcceleration: 1.8)
			.filter { $0 }
			.map { _ in }
			.eraseToAsyncThrowingStream()
	}
}
#endif


#if os(macOS)
enum InternalMacBattery {
	struct State {
		private static func powerSourceInfo() -> [String: AnyObject] {
			guard
				let blob = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
				let sources = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() as [CFTypeRef]?, // swiftlint:disable:this discouraged_optional_collection
				let source = sources.first,
				let description = IOPSGetPowerSourceDescription(blob, source)?.takeUnretainedValue() as? [String: AnyObject]
			else {
				return [:]
			}

			return description
		}

		/**
		Whether the device has a battery.
		*/
		let hasBattery: Bool

		/**
		Whether the power adapter is connected.
		*/
		let isPowerAdapterConnected: Bool

		/**
		Whether the battery is charging.
		*/
		let isCharging: Bool

		/**
		Whether the battery is fully charged and connected to a power adapter.
		*/
		let isCharged: Bool

		init() {
			let info = Self.powerSourceInfo()

			self.hasBattery = (info[kIOPSIsPresentKey] as? Bool) == true
				&& (info[kIOPSTypeKey] as? String) == kIOPSInternalBatteryType

			if hasBattery {
				self.isPowerAdapterConnected = info[kIOPSPowerSourceStateKey] as? String == kIOPSACPowerValue
				self.isCharging = info[kIOPSIsChargingKey] as? Bool ?? false
				self.isCharged = info[kIOPSIsChargedKey] as? Bool ?? false
			} else {
				self.isPowerAdapterConnected = true
				self.isCharging = false
				self.isCharged = false
			}
		}
	}

	/**
	The state of the internal battery.

	If the device does not have a battery, it still tries to return sensible values.
	*/
	static var state: State { .init() }
}
#endif


extension Device {
	enum BatteryState {
		/**
		The battery state for the device cannot be determined.
		*/
		case unknown

		/**
		The device is not plugged into power; the battery is discharging.
		*/
		case unplugged

		/**
		The device is plugged into power and the battery is less than 100% charged.
		*/
		case charging

		/**
		The device is plugged into power and the battery is 100% charged.
		*/
		case full
	}

	/**
	The state of the device's battery.
	*/
	static var batteryState: BatteryState {
		#if os(macOS)
		let state = InternalMacBattery.state

		guard state.isPowerAdapterConnected else {
			return .unplugged
		}

		if state.isCharged {
			return .full
		}

		if state.isCharging {
			return .charging
		}

		return .unknown
		#else
		UIDevice.current.isBatteryMonitoringEnabled = true

		switch UIDevice.current.batteryState {
		case .unknown:
			return .unknown
		case .unplugged:
			return .unplugged
		case .charging:
			return .charging
		case .full:
			return .full
		@unknown default:
			return .unknown
		}
		#endif
	}
}


extension Dictionary {
	func compactValues<T>() -> [Key: T] where Value == T? {
		// TODO: Make this `compactMapValues(\.self)` when https://github.com/apple/swift/issues/55343 is fixed.
		compactMapValues { $0 }
	}
}


extension CharacterSet {
	/**
	Characters allowed to be unescaped in an URL.

	https://tools.ietf.org/html/rfc3986#section-2.3
	*/
	static let urlUnreservedRFC3986 = CharacterSet(charactersIn: "-._~")
		.union(asciiLettersAndNumbers)
}


private func escapeQueryComponent(_ query: String) -> String {
	query.addingPercentEncoding(withAllowedCharacters: .urlUnreservedRFC3986)!
}


extension Dictionary where Key == String {
	/**
	This correctly escapes items. See `escapeQueryComponent`.
	*/
	var toQueryItems: [URLQueryItem] {
		map {
			URLQueryItem(
				name: escapeQueryComponent($0),
				value: escapeQueryComponent("\($1)")
			)
		}
	}

	var toQueryString: String {
		var components = URLComponents()
		components.queryItems = toQueryItems
		return components.query!
	}
}


extension URLComponents {
	mutating func addDictionaryAsQuery(_ dictionary: [String: String]) {
		percentEncodedQuery = dictionary.toQueryString
	}
}


typealias QueryDictionary = [String: String]


extension URLComponents {
	/**
	This correctly escapes items. See `escapeQueryComponent`.
	*/
	var queryDictionary: QueryDictionary {
		get {
			queryItems?.toDictionary { ($0.name, $0.value) }.compactValues() ?? [:]
		}
		set {
			// Using `percentEncodedQueryItems` instead of `queryItems` since the query items are already custom-escaped. See `escapeQueryComponent`.
			percentEncodedQueryItems = newValue.toQueryItems
		}
	}
}


extension URL {
	var queryItems: [URLQueryItem] {
		guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
			return []
		}

		return components.queryItems ?? []
	}

	var queryDictionary: QueryDictionary {
		guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
			return [:]
		}

		return components.queryDictionary
	}

	func addingDictionaryAsQuery(_ dictionary: [String: String]) -> Self {
		var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
		components.addDictionaryAsQuery(dictionary)
		return components.url ?? self
	}

	/**
	Returns `self` with the given `URLQueryItem` appended.
	*/
	func appendingQueryItem(_ queryItem: URLQueryItem) -> Self {
		guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
			return self
		}

		if components.queryItems == nil {
			components.queryItems = []
		}

		components.queryItems?.append(queryItem)

		return components.url ?? self
	}

	/**
	Returns `self` with the given `name` and `value` appended if the `value` is not `nil`.
	*/
	func appendingQueryItem(name: String, value: String?) -> Self {
		appendingQueryItem(URLQueryItem(name: name, value: value))
	}

	/**
	Get the value of the first query item with the given name.
	*/
	func queryItemValue(forName name: String) -> String? {
		queryItems.first { $0.name == name }?.value
	}
}


extension StringProtocol {
	/**
	Makes it easier to deal with optional sub-strings.
	*/
	var toString: String { String(self) }
}


// swiftlint:disable:next no_cgfloat
extension CGFloat {
	/**
	Get a Double from a CGFloat. This makes it easier to work with optionals.
	*/
	var toDouble: Double { Double(self) }
}

extension Int {
	/**
	Get a Double from an Int. This makes it easier to work with optionals.
	*/
	var toDouble: Double { Double(self) }
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
		#if os(macOS)
		NSWorkspace.shared.open(self)
		#elseif !APP_EXTENSION
		Task { @MainActor in
			UIApplication.shared.open(self)
		}
		#endif
	}
}


extension URL {
	/**
	Opens the URL or throws with a human-friendly error message if it is unable to.

	- Note: It does nothing in app extensions.
	*/
	@MainActor // It's marked mainactor as `UIApplication.shared.open` requires it, but is not yet annotated. (iOS 16.0)
	func openAsync() async throws {
		#if os(macOS)
		try await NSWorkspace.shared.open(self, configuration: .init())
		#elseif !APP_EXTENSION
		guard await UIApplication.shared.open(self) else {
			throw "Failed to open the URL “\(absoluteString)”.".toError
		}
		#endif
	}

	#if !APP_EXTENSION
	@MainActor
	func openAsyncOrOpenShortcutsApp() async throws {
		do {
			try await openAsync()
		} catch {
			ShortcutsApp.open()
			throw error
		}
	}
	#endif
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


#if os(macOS)
private struct WindowAccessor: NSViewRepresentable {
	@MainActor
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
	func bindHostingWindow(_ window: Binding<NSWindow?>) -> some View {
		background(WindowAccessor(window))
	}
}

private struct WindowViewModifier: ViewModifier {
	@State private var window: NSWindow?

	let onWindow: (NSWindow?) -> Void

	func body(content: Content) -> some View {
		onWindow(window)

		return content
			.bindHostingWindow($window)
	}
}

extension View {
	/**
	Access the native backing-window of a SwiftUI window.
	*/
	@MainActor
	func accessHostingWindow(_ onWindow: @escaping (NSWindow?) -> Void) -> some View {
		modifier(WindowViewModifier(onWindow: onWindow))
	}

	/**
	Set the window level of a SwiftUI window.
	*/
	@MainActor
	func windowLevel(_ level: NSWindow.Level) -> some View {
		accessHostingWindow {
			$0?.level = level
		}
	}

	/**
	Centers the window when the view appears.
	*/
	@MainActor
	func windowCenterOnAppear() -> some View {
		withState(nil as NSWindow?) { valueBinding in
			bindHostingWindow(valueBinding)
				.task {
					valueBinding.wrappedValue?.center()
				}
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


#if os(macOS)
extension NSImage {
	/**
	Draw a color as an image.
	*/
	static func color(
		_ color: Color,
		size: CGSize,
		scale: Double,
		borderWidth: Double = 0,
		borderColor: NSColor? = nil,
		cornerRadius: Double? = nil
	) -> Self {
		Self(size: size * scale, flipped: false) { bounds in
			NSGraphicsContext.current?.imageInterpolation = .high

			guard let cornerRadius else {
				color.toXColor.set()
				bounds.fill()
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

			color.toXColor.set()
			bezierPath.fill()

			if
				borderWidth > 0,
				let borderColor
			{
				borderColor.setStroke()
				bezierPath.lineWidth = borderWidth
				bezierPath.stroke()
			}

			return true
		}
	}
}
#else
extension UIImage {
	static func color(
		_ color: Color,
		size: CGSize,
		scale: Double
	) -> UIImage {
		let format = UIGraphicsImageRendererFormat()
		format.opaque = color.resolve(in: .init()).opacity == 1
		format.scale = scale

		return UIGraphicsImageRenderer(size: size, format: format).image { rendererContext in
			color.toXColor.setFill()
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


extension RangeReplaceableCollection {
	mutating func prepend(_ newElement: Element) {
		insert(newElement, at: startIndex)
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


extension Character {
	var isSimpleEmoji: Bool {
		guard let firstScalar = unicodeScalars.first else {
			return false
		}

		return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
	}

	var isCombinedIntoEmoji: Bool {
		unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false
	}

	var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}


extension String {
	/**
	Get all the emojis in the string.

	```
	"foo🦄bar🌈👩‍👩‍👦‍👦".emojis
	//=> ["🦄", "🌈", "👩‍👩‍👦‍👦"]
	```
	*/
	var emojis: [Character] { filter(\.isEmoji) }
}


extension String {
	/**
	Returns a version of the string without emojis.

	```
	"foo🦄✈️bar🌈👩‍👩‍👦‍👦".removingEmojis()
	//=> "foobar"
	```
	*/
	func removingEmojis() -> Self {
		Self(filter { !$0.isEmoji })
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
		Self(
			timeIntervalSinceNow: .random(
				in: .fromGraceful(
					range.lowerBound.timeIntervalSinceNow,
					range.upperBound.timeIntervalSinceNow
				)
			)
		)
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

	/**
	Assumes each string is a valid number.

	Non-numbers will be sorted last.
	*/
	case number
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
		case .number:
			return sortedByReturnValue(order: order) { Double($0) ?? .infinity }
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


extension Sequence where Element: Hashable {
	/**
	Returns the unique elements in a sequence.

	```
	[1, 2, 1].removingDuplicates()
	//=> [1, 2]
	```
	*/
	func removingDuplicates() -> [Element] {
		var seen = Set<Element>()
		return filter { seen.insert($0).inserted }
	}
}


extension Sequence where Element: Equatable {
	/**
	Returns the unique elements in a sequence.

	```
	[1, 2, 1].removingDuplicates()
	//=> [1, 2]
	```
	*/
	func removingDuplicates() -> [Element] {
		reduce(into: []) { result, element in
			if !result.contains(element) {
				result.append(element)
			}
		}
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


extension String {
	var firstLine: Self {
		components(separatedBy: .newlines).first ?? self
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
	Returns a new string with empty or whitespace-only lines removed.
	*/
	func removingEmptyLines() -> Self {
		lines()
			.filter { !$0.isEmptyOrWhitespace }
			.joined(separator: "\n")
	}
}


extension String {
	/**
	Returns a new string with the lines in reversed order.
	*/
	func reversingLines() -> Self {
		lines()
			.reversed()
			.joined(separator: "\n")
	}
}


extension Color.Resolved {
	/**
	Generate a random color, avoiding black and white.
	*/
	static func randomAvoidingBlackAndWhite() -> Self {
		XColor(
			hue: .random(in: 0...1),
			saturation: .random(in: 0.5...1), // 0.5 is to get away from white
			brightness: .random(in: 0.5...1), // 0.5 is to get away from black
			alpha: 1
		)
		.toColor
		.resolve(in: .init())
	}
}


extension String {
	func parseHexColor() -> (red: Double, green: Double, blue: Double, alpha: Double)? {
		let hexString = trimmed.removingPrefix("#")

		guard
			hexString.count == 3 || hexString.count == 6 || hexString.count == 8,
			let int = UInt64(hexString, radix: 16)
		else {
			return nil
		}

		let alpha, red, green, blue: UInt64
		switch hexString.count {
		case 3: // RGB (12-bit)
			(alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			return nil
		}

		return (
			Double(red) / 255,
			Double(green) / 255,
			Double(blue) / 255,
			Double(alpha) / 255
		)
	}
}

extension Color.Resolved {
	init?(
		hexString: String,
		opacity: Double? = nil,
		respectOpacity: Bool = true
	) {
		guard
			let (red, green, blue, alpha) = hexString.parseHexColor()
		else {
			return nil
		}

		self.init(
			red: red.toFloat,
			green: green.toFloat,
			blue: blue.toFloat,
			opacity: opacity?.toFloat ?? (respectOpacity ? alpha.toFloat : 1)
		)
	}
}


extension Color.Resolved {
	/**
	- Note: It respects the opacity of the color.
	*/
	var hex: Int {
		let red = Int((red * 0xFF).rounded())
		let green = Int((green * 0xFF).rounded())
		let blue = Int((blue * 0xFF).rounded())
		let opacity = Int((opacity * 0xFF).rounded())
		return opacity << 24 | red << 16 | green << 8 | blue
	}

	/**
	- Note: It includes the opacity of the color if not `1`.
	*/
	var hexString: String {
		if opacity < 1 {
			String(format: "#%08x", hex)
		} else {
			String(format: "#%06x", hex & 0xFFFFFF) // Masking to remove the alpha portion for full opacity
		}
	}
}


extension Color.Resolved {
	var toColor: Color { .init(self) }
}


extension XColor {
	/**
	Convert a `NSColor`/`UIColor` to a `Color`.
	*/
	var toColor: Color { Color(self) }
}

extension Color {
	/**
	Convert a `Color` to a `NSColor`/`UIColor`.
	*/
	var toXColor: XColor { XColor(self) }
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


extension String {
	func removingPrefix(_ prefix: Self, caseSensitive: Bool = true) -> Self {
		guard caseSensitive else {
			guard let range = range(of: prefix, options: [.caseInsensitive, .anchored]) else {
				return self
			}

			return replacingCharacters(in: range, with: "")
		}

		guard hasPrefix(prefix) else {
			return self
		}

		return Self(dropFirst(prefix.count))
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
	case visionOS

	#if os(macOS)
	static let current = macOS
	#elseif os(iOS)
	static let current = iOS
	#elseif os(tvOS)
	static let current = tvOS
	#elseif os(watchOS)
	static let current = watchOS
	#elseif os(visionOS)
	static let current = visionOS
	#else
	#error("Unsupported platform")
	#endif

	static let isMacOS = current == .macOS
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
	func ifOS(
		_ operatingSystems: OperatingSystem...,
		modifier: (Self) -> some View
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
		for (index, element) in Element.allCases.enumerated() where contains(element) {
			rawValue |= (1 << index)
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
			result = 127 * (result & 0x00FF_FFFF_FFFF_FFFF) + UInt64(element)
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

extension RandomNumberGenerator where Self == SeededRandomNumberGenerator {
	/**
	```
	var generator = RandomNumberGenerator.seeded(seed: "🦄")
	random(length: length, using: &generator)
	```
	*/
	static func seeded(seed: String) -> Self {
		.init(seed: seed)
	}
}

extension SeededRandomNumberGenerator {
	/**
	Uses a seeded random generator if the seed is specified, otherwise, the system random generator.

	```
	var generator = SeededRandomNumberGenerator.seededOrNot(seed: "🦄")
	random(length: length, using: &generator)
	```
	*/
	static func seededOrNot(seed: String? = nil) -> any RandomNumberGenerator {
		seed.flatMap { .seeded(seed: $0) } ?? .system
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
	static func random(
		length: Int,
		characters: String,
		using generator: inout some RandomNumberGenerator
	) -> Self {
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
	static func random(
		length: Int,
		characters: RandomCharacters = [.lowercase, .uppercase, .digits],
		using generator: inout some RandomNumberGenerator
	) -> Self {
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


extension Locale {
	/**
	American English.
	*/
	static let englishUS = Self(languageCode: .english, languageRegion: .unitedStates)
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
		if let creationDate {
			$0.creationDate = creationDate
		}

		if let modificationDate {
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

	var contentType: UTType? {
		resourceValue(forKey: .contentTypeKey)
			?? UTType(filenameExtension: pathExtension)
	}

	var localizedName: String { resourceValue(forKey: .localizedNameKey) ?? lastPathComponent }
}


extension URL {
	/**
	Check whether the given string is a valid URL scheme.
	*/
	static func isValidScheme(_ scheme: String) -> Bool {
		scheme.first?.isASCIILetterOrNumber == true
			&& scheme.hasOnlyCharacters(in: .urlSchemeAllowed)
	}
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

extension CGImage {
	/**
	Writes the metadata to the image by merging it into the existing metadata.
	*/
	private static func writeMetadata(
		_ metadata: [String: Any],
		to source: CGImageSource,
		using destinationProvider: (CFString) -> CGImageDestination?
	) throws {
		guard
			let type = CGImageSourceGetType(source),
			let destination = destinationProvider(type)
		else {
			throw "Failed to read image.".toError
		}

		let mutableMetadata = CGImageMetadataCreateMutable()

		for namespace in metadata {
			guard let subMetadata = namespace.value as? [String: Any] else {
				continue
			}

			for (key, value) in subMetadata {
				CGImageMetadataSetValueMatchingImageProperty(mutableMetadata, namespace.key as CFString, key as CFString, value as! CFString)
			}
		}

		let options: [String: Any] = [
			kCGImageDestinationMetadata as String: mutableMetadata,
			kCGImageDestinationMergeMetadata as String: true
		]

		var error: Unmanaged<CFError>?
		CGImageDestinationCopyImageSource(destination, source, options as CFDictionary, &error)

		if let error = error?.takeRetainedValue() {
			throw error
		}
	}

	private static func writeMetadata(_ metadata: [String: Any], to url: URL) throws {
		guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
			throw "Failed to read image.".toError
		}

		try writeMetadata(metadata, to: source) { type in
			CGImageDestinationCreateWithURL(url as CFURL, type, 1, nil)
		}
	}

	private static func writeMetadata(_ metadata: [String: Any], to data: inout Data) throws {
		guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
			throw "Failed to read image.".toError
		}

		let updatedData = NSMutableData()

		try writeMetadata(metadata, to: source) { type in
			CGImageDestinationCreateWithData(updatedData, type, 1, nil)
		}

		data = updatedData as Data
	}
}


extension CGImage {
	private static func locationFromMetadata(_ metadata: [String: Any]) -> LocationCoordinate2D? {
		guard
			let gpsDictionary = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any],
			let latitude = gpsDictionary[kCGImagePropertyGPSLatitude as String] as? Double,
			let latitudeRef = gpsDictionary[kCGImagePropertyGPSLatitudeRef as String] as? String,
			let longitude = gpsDictionary[kCGImagePropertyGPSLongitude as String] as? Double,
			let longitudeRef = gpsDictionary[kCGImagePropertyGPSLongitudeRef as String] as? String
		else {
			return nil
		}

		let finalLatitude = latitudeRef == "N" ? latitude : -latitude
		let finalLongitude = longitudeRef == "E" ? longitude : -longitude

		return LocationCoordinate2D(latitude: finalLatitude, longitude: finalLongitude)
	}

	static func location(ofImageAt url: URL) -> LocationCoordinate2D? {
		locationFromMetadata(metadata(url))
	}

	static func location(ofImage data: Data) -> LocationCoordinate2D? {
		locationFromMetadata(metadata(data))
	}
}

extension CGImage {
	private static func set(
		location: LocationCoordinate2D,
		forMetadata metadata: inout [String: Any]
	) {
		let latitudeRef = location.latitude >= 0 ? "N" : "S"
		let longitudeRef = location.longitude >= 0 ? "E" : "W"

		let gpsDictionary: [String: Any] = [
			kCGImagePropertyGPSLatitude as String: abs(location.latitude),
			kCGImagePropertyGPSLatitudeRef as String: latitudeRef,
			kCGImagePropertyGPSLongitude as String: abs(location.longitude),
			kCGImagePropertyGPSLongitudeRef as String: longitudeRef
		]

		metadata[kCGImagePropertyGPSDictionary as String] = gpsDictionary
	}

	static func setLocation(
		_ location: LocationCoordinate2D,
		forImageAt url: URL
	) throws {
		var metadata = [String: Any]()
		set(location: location, forMetadata: &metadata)
		try writeMetadata(metadata, to: url)
	}

	static func setLocation(
		_ location: LocationCoordinate2D,
		forImageData imageData: inout Data
	) throws {
		var metadata = [String: Any]()
		set(location: location, forMetadata: &metadata)
		try writeMetadata(metadata, to: &imageData)
	}
}

#if os(macOS)
extension NSBitmapImageRep {
	func pngData() -> Data? {
		representation(using: .png, properties: [:])
	}

	func jpegData(compressionQuality: Double) -> Data? {
		representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
	}
}

extension Data {
	var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}

extension NSImage {
	/**
	UIKit polyfill.
	*/
	func pngData() -> Data? {
		tiffRepresentation?.bitmap?.pngData()
	}

	/**
	UIKit polyfill.
	*/
	func jpegData(compressionQuality: Double) -> Data? {
		tiffRepresentation?.bitmap?.jpegData(compressionQuality: compressionQuality)
	}
}
#endif


extension XImage {
	/**
	Convert a `UIImage`/`NSImage` to a `CIImage`.
	*/
	var toCIImage: CIImage? {
		#if os(macOS)
		if let cgImage {
			return CIImage(cgImage: cgImage, options: [.applyOrientationProperty: true])
		}

		guard let tiffRepresentation else {
			return nil
		}

		return CIImage(data: tiffRepresentation, options: [.applyOrientationProperty: true])
		#else
		CIImage(image: self, options: [.applyOrientationProperty: true])
		#endif
	}
}


extension URL {
	/**
	Creates a unique temporary directory and returns the URL.

	The URL is unique for each call.

	The system ensures the directory is not cleaned up until after the app quits.
	*/
	static func uniqueTemporaryDirectory(
		appropriateFor: Self? = nil
	) throws -> Self {
		let url = {
			// TODO: Test if I can use `URL.documentsDirectory` on macOS too? Wait until macOS 14 is targeted.
			#if os(macOS)
			Bundle.main.bundleURL
			#else
			// See: https://developer.apple.com/forums/thread/735726
			URL.documentsDirectory
			#endif
		}

		return try FileManager.default.url(
			for: .itemReplacementDirectory,
			in: .userDomainMask,
			appropriateFor: appropriateFor ?? url(),
			create: true
		)
	}

	/**
	Copy the file at the current URL to a unique temporary directory and return the new URL.
	*/
	func copyToUniqueTemporaryDirectory(filename: String? = nil) throws -> Self {
		let destinationUrl = try Self.uniqueTemporaryDirectory(appropriateFor: self)
			.appendingPathComponent(filename ?? lastPathComponent, isDirectory: false)

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
		filename: String? = nil,
		contentType: UTType = .data
	) throws -> URL {
		let destinationUrl = try URL.uniqueTemporaryDirectory()
			.appendingPathComponent(filename ?? "file", conformingTo: contentType)

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


extension IntentFile {
	var filenameWithoutExtension: String {
		filename.removingFileExtension()
	}
}


extension IntentFile {
	/**
	Write the data to a unique temporary path and return the `URL`.
	*/
	func writeToUniqueTemporaryFile() throws -> URL {
		try data.writeToUniqueTemporaryFile(
			filename: filename,
			contentType: type ?? .data
		)
	}
}


extension IntentFile {
	func removingOnCompletion() -> Self {
		var copy = self
		copy.removedOnCompletion = true
		return copy
	}
}


extension IntentFile {
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
	func modifyingFileAsURL(_ modify: (URL) throws -> URL) throws -> Self {
		try modify(writeToUniqueTemporaryFile())
			.toIntentFile
			.removingOnCompletion()
	}
}


extension IntentFile {
	func withData(_ modifyData: (inout Data) throws -> Void) rethrows -> Self {
		var data = data
		try modifyData(&data)

		return .init(
			data: data,
			filename: filename,
			type: type
		)
	}
}


extension URL {
	/**
	Create a `IntentFile` from the URL.
	*/
	var toIntentFile: IntentFile {
		.init(
			fileURL: self,
			filename: lastPathComponent,
			type: contentType
		)
	}
}


extension XImage {
	/**
	Create an `IntentFile` from the image.
	*/
	func toIntentFile(filename: String? = nil) throws -> IntentFile {
		guard let data = pngData() else {
			throw "Failed to generate PNG data from image.".toError
		}

		return data.toIntentFile(contentType: .png, filename: filename)
	}
}


extension Data {
	/**
	Create an `IntentFile` from the data.
	*/
	func toIntentFile(
		contentType: UTType,
		filename: String? = nil
	) -> IntentFile {
		.init(
			data: self,
			filename: filename ?? "file",
			type: contentType
		)
			.removingOnCompletion()
	}
}


extension String {
	/**
	Create an `IntentFile` from the string.
	*/
	func toIntentFile(
		filename: String? = nil
	) -> IntentFile {
		toData.toIntentFile(contentType: .utf8PlainText, filename: filename)
	}
}


extension Sequence {
	func compact<T>() -> [T] where Element == T? {
		// TODO: Make this `compactMap(\.self)` when https://github.com/apple/swift/issues/55343 is fixed.
		compactMap { $0 }
	}
}


extension Sequence where Element: Sequence {
	func flatten() -> [Element.Element] {
		// TODO: Make this `flatMap(\.self)` when https://github.com/apple/swift/issues/55343 is fixed.
		flatMap { $0 }
	}
}


extension URLResponse {
	/**
	Get the `HTTPURLResponse`.
	*/
	var http: HTTPURLResponse? { self as? HTTPURLResponse }

	func throwIfHTTPResponseButNotSuccessStatusCode() throws {
		guard let http else {
			return
		}

		try http.throwIfNotSuccessStatusCode()
	}
}


extension HTTPURLResponse {
	struct StatusCodeError: LocalizedError {
		let errorCode: Int

		var errorDescription: String? {
			"Request failed: \(HTTPURLResponse.localizedString(forStatusCode: errorCode)) (\(errorCode))"
		}
	}

	/**
	`true` if the status code is in `200...299` range.
	*/
	var hasSuccessStatusCode: Bool { (200...299).contains(statusCode) }

	func throwIfNotSuccessStatusCode() throws {
		guard !hasSuccessStatusCode else {
			return
		}

		throw StatusCodeError(errorCode: statusCode)
	}
}


extension URLRequest {
	enum Method: String {
		case get
		case post
		case delete
		case put
		case head
	}

	enum ContentType {
		static let json = "application/json"
	}

	enum UserAgent {
		static let `default` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15"
	}

	typealias Headers = [String: String]

	static func json(
		_ method: Method,
		url: URL,
		data: Data? = nil
	) -> Self {
		var request = self.init(url: url)
		request.method = method
		request.addValue(ContentType.json, forHTTPHeaderField: "Accept")
		request.addValue(ContentType.json, forHTTPHeaderField: "Content-Type")

		if let data {
			request.httpBody = data
		}

		return request
	}

	static func json(
		_ method: Method,
		url: URL,
		parameters: [String: Any]
	) throws -> Self {
		json(
			method,
			url: url,
			data: try JSONSerialization.data(withJSONObject: parameters, options: [])
		)
	}

	init(
		method: Method,
		url: URL,
		contentType: String? = nil,
		headers: Headers = [:],
		timeout: Duration = .seconds(60)
	) {
		self.init(url: url, timeoutInterval: timeout.toTimeInterval)
		self.method = method
		self.allHTTPHeaderFields = headers

		if let contentType {
			addContentType(contentType)
		}
	}

	var userAgent: String? {
		get { value(forHTTPHeaderField: "User-Agent") }
		set {
			setValue(newValue, forHTTPHeaderField: "User-Agent")
		}
	}

	/**
	Strongly-typed version of `httpMethod`.
	*/
	var method: Method {
		get {
			guard let httpMethod else {
				return .get
			}

			return Method(rawValue: httpMethod.lowercased())!
		}
		set {
			httpMethod = newValue.rawValue
		}
	}

	mutating func addContentType(_ contentType: String) {
		addValue(contentType, forHTTPHeaderField: "Content-Type")
	}
}


extension URLSession {
	/**
	Send a JSON request.

	- Note: This method assumes the response is a JSON object.
	*/
	func json(
		_ method: URLRequest.Method,
		url: URL,
		parameters: [String: Any]
	) async throws -> ([String: Any], URLResponse) {
		let request = try URLRequest.json(method, url: url, parameters: parameters)
		let (data, response) = try await data(for: request)
		try response.throwIfHTTPResponseButNotSuccessStatusCode()

		return (
			try data.jsonToDictionary(),
			response
		)
	}
}


extension Error {
	var presentableMessage: String {
		let description = localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)

		guard
			let recoverySuggestion = (self as NSError).localizedRecoverySuggestion?.trimmingCharacters(in: .whitespacesAndNewlines)
		else {
			return description
		}

		return "\(description.ensureSuffix(".")) \(recoverySuggestion.ensureSuffix("."))"
	}
}


struct GeneralError: LocalizedError, CustomNSError {
	// LocalizedError
	let errorDescription: String?
	let recoverySuggestion: String?
	let helpAnchor: String?

	// CustomNSError
	let errorUserInfo: [String: Any]

	init(
		_ description: String,
		recoverySuggestion: String? = nil,
		userInfo: [String: Any] = [:],
		url: URL? = nil,
		underlyingErrors: [Error] = [],
		helpAnchor: String? = nil
	) {
		self.errorDescription = description
		self.recoverySuggestion = recoverySuggestion
		self.helpAnchor = helpAnchor

		self.errorUserInfo = {
			var userInfo = userInfo

			if !underlyingErrors.isEmpty {
				userInfo[NSMultipleUnderlyingErrorsKey] = underlyingErrors
			}

			if let url {
				userInfo[NSURLErrorKey] = url
			}

			return userInfo
		}()
	}
}


// Required for error messages to be shown in App Intents.
extension GeneralError: CustomLocalizedStringResourceConvertible {
	var localizedStringResource: LocalizedStringResource { "\(presentableMessage)" }
}


extension String {
	/**
	Convert a string into an error.
	*/
	var toError: some LocalizedError { GeneralError(self) }
}


enum Bluetooth {
	private static var noAccessError: GeneralError {
		let recoverySuggestion = OS.current == .macOS
			? "You can grant access in “System Settings › Privacy & Security › Bluetooth”."
			: "You can grant access in “Settings › \(SSApp.name)”."

		return GeneralError("No access to Bluetooth.", recoverySuggestion: recoverySuggestion)
	}

	static func ensureAccess() throws {
		// Make sure we try to prompt first.
		_ = CBCentralManager(delegate: nil, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])

		guard CBCentralManager.authorization == .allowedAlways else {
			throw noAccessError
		}
	}

	private final class BluetoothManager: NSObject, CBCentralManagerDelegate {
		private let continuation: CheckedContinuation<Bool, Error>
		private var manager: CBCentralManager?
		private var hasCalled = false

		init(continuation: CheckedContinuation<Bool, Error>) {
			self.continuation = continuation
			super.init()
			self.manager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])

			checkAccess()
		}

		private func checkAccess() {
			guard
				!hasCalled,
				CBCentralManager.authorization != .allowedAlways
			else {
				return
			}

			continuation.resume(throwing: Bluetooth.noAccessError)
			hasCalled = true
		}

		func centralManagerDidUpdateState(_ central: CBCentralManager) {
			defer {
				hasCalled = true
			}

			checkAccess()

			guard !hasCalled else {
				return
			}

			continuation.resume(returning: central.state == .poweredOn)
		}
	}

	private static var bluetoothManagers = [UUID: BluetoothManager]()

	/**
	Check whether Bluetooth is turned on.

	- Note: You need to have `NSBluetoothAlwaysUsageDescription` in Info.plist. On macOS, you also need `com.apple.security.device.bluetooth` in your entitlements file.

	- Throws: An error if the app has no access to Bluetooth with a message on how to grant it.
	*/
	@MainActor // We use this to prevent any thread issues.
	static func isOn() async throws -> Bool {
		let key = UUID()

		let result = try await withCheckedThrowingContinuation { continuation in
			Self.bluetoothManagers[key] = BluetoothManager(continuation: continuation)
		}

		// This delay is required to give the system time to present the permission prompt if needed.
		if CBCentralManager.authorization == .notDetermined {
			try? await Task.sleep(for: .seconds(0.1))
		}

		Self.bluetoothManagers[key] = nil

		return result
	}
}


extension String {
	/**
	- Parameter currentHostOnly: The pasteboard contents are available only on the current device, and not on any other devices. This parameter is only used on macOS.
	*/
	func copyToPasteboard(currentHostOnly: Bool = false) {
		#if os(macOS)
		NSPasteboard.general.prepareForNewContents(with: currentHostOnly ? .currentHostOnly : [])
		NSPasteboard.general.setString(self, forType: .string)
		#else
		UIPasteboard.general.string = self
		#endif
	}
}


#if canImport(UIKit)
extension UIPasteboard {
	/**
	AppKit polyfill.
	*/
	func prepareForNewContents() {
		string = ""
	}
}
#endif


extension XPasteboard {
	/**
	Universal version.
	*/
	func prepareForNewContents(currentHostOnly: Bool) {
		#if os(macOS)
		prepareForNewContents(with: currentHostOnly ? .currentHostOnly : [])
		#else
		string = ""
		#endif
	}
}


extension View {
	/**
	Embed the view in a `NavigationStack`.

	- Note: Modifiers before this apply to the contents and modifiers after apply to the `NavigationStack`.
	*/
	@ViewBuilder
	func embedInNavigationStack(_ shouldEmbed: Bool = true) -> some View {
		if shouldEmbed {
			NavigationStack {
				self
			}
		} else {
			self
		}
	}
}


extension View {
	/**
	Present a fullscreen cover on iOS and a sheet on macOS.
	*/
	func fullScreenCoverOrSheetIfMacOS<Item: Identifiable>(
		item: Binding<Item?>,
		onDismiss: (() -> Void)? = nil,
		@ViewBuilder content: @escaping (Item) -> some View
	) -> some View {
		#if os(macOS)
		sheet(item: item, onDismiss: onDismiss, content: content)
		#else
		fullScreenCover(item: item, onDismiss: onDismiss, content: content)
		#endif
	}
}


#if os(macOS)
extension CGEventType {
	/**
	Any event.

	This case is missing from Swift and `kCGAnyInputEventType` is not available in Swift either.
	*/
	static let any = Self(rawValue: ~0)!
}
#endif


enum User {
	#if os(macOS)
	/**
	Th current user's username.

	For example: `sindresorhus`
	*/
	static let username = ProcessInfo.processInfo.userName
	#endif

	#if os(macOS)
	/**
	The current user's name.

	For example: `Sindre Sorhus`
	*/
	static let nameString = ProcessInfo.processInfo.fullUserName
	#else
	/**
	The current user's name.

	For example: `Sindre Sorhus`

	- Note: The name may not be available, it may only be the given name, or it may be empty.
	*/
	static let nameString: String = {
		let name = UIDevice.current.name

		if name.hasSuffix("’s iPhone") {
			return name.replacingSuffix("’s iPhone", with: "")
		}

		if name.hasSuffix("’s iPad") {
			return name.replacingSuffix("’s iPad", with: "")
		}

		if name.hasSuffix("’s Apple Watch") {
			return name.replacingSuffix("’s Apple Watch", with: "")
		}

		return ""
	}()
	#endif

	/**
	The current user's name.

	- Note: The name might not be available on iOS.
	*/
	static let name = try? PersonNameComponents(nameString)

	/**
	The current user's language code.
	*/
	static var languageCode: Locale.LanguageCode { Locale.current.language.languageCode ?? .english }

	/**
	The current user's shell.
	*/
	static let shell: String = {
		guard
			let shell = getpwuid(getuid())?.pointee.pw_shell
		else {
			return "/bin/zsh"
		}

		return String(cString: shell)
	}()

	#if os(macOS)
	/**
	The duration since the user was last active on the computer.
	*/
	static var idleTime: Duration {
		.seconds(CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: .any))
	}
	#endif
}


extension CNContact {
	static var personNameComponentsFetchKeys = [
		CNContactNamePrefixKey,
		CNContactGivenNameKey,
		CNContactMiddleNameKey,
		CNContactFamilyNameKey,
		CNContactNameSuffixKey,
		CNContactNicknameKey,
		CNContactPhoneticGivenNameKey,
		CNContactPhoneticMiddleNameKey,
		CNContactPhoneticFamilyNameKey
	] as [CNKeyDescriptor]

	/**
	Convert a `CNContact` to a `PersonNameComponents`.

	- Important: Ensure you have fetched the needed keys. You can use `CNContact.personNameComponentsFetchKeys` to get the keys.
	*/
	var toPersonNameComponents: PersonNameComponents {
		.init(
			namePrefix: isKeyAvailable(CNContactNamePrefixKey) ? namePrefix : nil,
			givenName: isKeyAvailable(CNContactGivenNameKey) ? givenName : nil,
			middleName: isKeyAvailable(CNContactMiddleNameKey) ? middleName : nil,
			familyName: isKeyAvailable(CNContactFamilyNameKey) ? familyName : nil,
			nameSuffix: isKeyAvailable(CNContactNameSuffixKey) ? nameSuffix : nil,
			nickname: isKeyAvailable(CNContactNicknameKey) ? nickname : nil,
			phoneticRepresentation: .init(
				givenName: isKeyAvailable(CNContactPhoneticGivenNameKey) ? phoneticGivenName : nil,
				middleName: isKeyAvailable(CNContactPhoneticMiddleNameKey) ? phoneticMiddleName : nil,
				familyName: isKeyAvailable(CNContactPhoneticFamilyNameKey) ? phoneticFamilyName : nil
			)
		)
	}
}


extension CNContactStore {
	private var legacyMeIdentifier: Int? {
		guard let containers = try? containers(matching: nil) else {
			return nil
		}

		// "meIdentifier"
		let key = String("reifitnedIem".reversed())

		return containers.firstNonNil {
			guard
				$0.description.contains(key), // Safeguard
				let identifier = $0.value(forKey: key) as? String,
				let number = Int(identifier),
				number != -1 // It returns `-1` if it has no "me" contact.
			else {
				return nil
			}

			return number
		}
	}

	// Cache
	private static var meContactIdentifier: String?

	/**
	The “me” contact identifier, if any.
	*/
	func meContactIdentifier() -> String? {
		if let meContactIdentifier = Self.meContactIdentifier {
			return meContactIdentifier
		}

		guard let legacyMeIdentifier else {
			return nil
		}

		// "iOSLegacyIdentifier"
		let key = String("reifitnedIycageLSOi".reversed())

		var meIdentifier: String?

		// TODO: Should I do `[key as NSString]` in keys to fetch?

		try? enumerateContacts(with: .init(keysToFetch: [])) { contact, stop in
			guard
				contact.responds(to: .init(key)),
				let legacyIdentifier = contact.value(forKey: key) as? Int
			else {
				return
			}

			if legacyIdentifier == legacyMeIdentifier {
				meIdentifier = contact.identifier
				stop.pointee = true
			}
		}

		Self.meContactIdentifier = meIdentifier

		return meIdentifier
	}
}

extension CNContactStore {
	/**
	The “me” contact, if any, as person name components.
	*/
	func meContactPerson() -> PersonNameComponents? {
		guard
			let identifier = meContactIdentifier(),
			let contact = try? unifiedContact(withIdentifier: identifier, keysToFetch: CNContact.personNameComponentsFetchKeys)
		else {
			return nil
		}

		return contact.toPersonNameComponents
	}
}


extension View {
	/**
	Conditionally modify the view. For example, apply modifiers, wrap the view, etc.

	```
	Text("Foo")
		.padding()
		.if(someCondition) {
			$0.foregroundColor(.pink)
		}
	```

	```
	VStack() {
		Text("Line 1")
		Text("Line 2")
	}
		.if(someCondition) { content in
			ScrollView(.vertical) { content }
		}
	```
	*/
	@ViewBuilder
	func `if`(
		_ condition: @autoclosure () -> Bool,
		modify: (Self) -> some View
	) -> some View {
		if condition() {
			modify(self)
		} else {
			self
		}
	}

	/**
	This overload makes it possible to preserve the type. For example, doing an `if` in a chain of `Text`-only modifiers.

	```
	Text("🦄")
		.if(isOn) {
			$0.fontWeight(.bold)
		}
		.kerning(10)
	```
	*/
	func `if`(
		_ condition: @autoclosure () -> Bool,
		modify: (Self) -> Self
	) -> Self {
		condition() ? modify(self) : self
	}
}


extension View {
	/**
	Conditionally modify the view. For example, apply modifiers, wrap the view, etc.
	*/
	@ViewBuilder
	func `if`(
		_ condition: @autoclosure () -> Bool,
		if modifyIf: (Self) -> some View,
		else modifyElse: (Self) -> some View
	) -> some View {
		if condition() {
			modifyIf(self)
		} else {
			modifyElse(self)
		}
	}

	/**
	Conditionally modify the view. For example, apply modifiers, wrap the view, etc.

	This overload makes it possible to preserve the type. For example, doing an `if` in a chain of `Text`-only modifiers.
	*/
	func `if`(
		_ condition: @autoclosure () -> Bool,
		if modifyIf: (Self) -> Self,
		else modifyElse: (Self) -> Self
	) -> Self {
		condition() ? modifyIf(self) : modifyElse(self)
	}
}

extension Font {
	/**
	Conditionally modify the font. For example, apply modifiers.

	```
	Text("Foo")
		.font(
			Font.system(size: 10, weight: .regular)
				.if(someBool) {
					$0.monospacedDigit()
				}
		)
	```
	*/
	func `if`(
		_ condition: @autoclosure () -> Bool,
		modify: (Self) -> Self
	) -> Self {
		condition() ? modify(self) : self
	}
}


#if canImport(UIKit)
extension UIFont.TextStyle {
	var font: UIFont { .preferredFont(forTextStyle: self) }

	var weight: UIFont.Weight { font.weight }
}

extension UIFont.Weight {
	var toSwiftUIFontWeight: Font.Weight {
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
		default:
			.regular
		}
	}
}

extension Font.TextStyle {
	var weight: Font.Weight { toUIFontTextStyle.weight.toSwiftUIFontWeight }

	var toUIFontTextStyle: UIFont.TextStyle {
		switch self {
		case .largeTitle:
			.largeTitle
		case .title:
			.title1
		case .title2:
			.title2
		case .title3:
			.title3
		case .headline:
			.headline
		case .body:
			.body
		case .callout:
			.callout
		case .subheadline:
			.subheadline
		case .footnote:
			.footnote
		case .caption:
			.caption1
		case .caption2:
			.caption2
		@unknown default:
			.body
		}
	}
}

extension UIFont {
	var traits: [UIFontDescriptor.TraitKey: Any] {
		fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any] ?? [:]
	}

	var weight: Weight { traits[.weight] as? Weight ?? .regular }
}
#endif

extension Font {
	/**
	Specifies a system font where the given size scales relative to the given text style.

	It respects the weight of the text style if no `weight` is specified.

	On macOS, there is no Dynamic Type, so the `relativeTo` parameter has no effect.
	*/
	static func system(
		size: Double,
		relativeTo textStyle: TextStyle,
		weight: Weight? = nil,
		design: Design = .default
	) -> Self {
		#if os(macOS)
		.system(size: size, weight: weight ?? .regular, design: design)
		#else
		let style = textStyle.toUIFontTextStyle

		return .system(
			size: style.metrics.scaledValue(for: size),
			weight: weight ?? style.weight.toSwiftUIFontWeight,
			design: design
		)
		#endif
	}
}

extension Font {
	/**
	A font with a large body text style.
	*/
	static var largeBody: Self {
		.system(size: OS.current == .macOS ? 16 : 20, relativeTo: .body)
	}
}


extension String {
	/**
	Removes characters without a display width, often referred to as invisible or non-printable characters.

	This does not include normal whitespace characters.
	*/
	func removingCharactersWithoutDisplayWidth() -> Self {
		replacing(/[\p{Control}\p{Format}\p{Nonspacing_Mark}\p{Enclosing_Mark}\p{Line_Separator}\p{Paragraph_Separator}\p{Private_Use}\p{Unassigned}]/.matchingSemantics(.unicodeScalar), with: "") // swiftlint:disable:this opening_brace
	}
}


extension Sequence {
	/**
	Sort a sequence by a key path.

	```
	["ab", "a", "abc"].sorted(by: \.count)
	//=> ["a", "ab", "abc"]
	```
	*/
	public func sorted(
		by keyPath: KeyPath<Element, some Comparable>,
		order: SortOrder = .forward
	) -> [Element] {
		switch order {
		case .forward:
			sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
		case .reverse:
			sorted { $0[keyPath: keyPath] > $1[keyPath: keyPath] }
		}
	}

	public func sortedByReturnValue(
		order: SortOrder = .forward,
		getValue: (Element) throws -> some Comparable
	) rethrows -> [Element] {
		switch order {
		case .forward:
			try sorted { (try getValue($0)) < (try getValue($1)) }
		case .reverse:
			try sorted { (try getValue($0)) > (try getValue($1)) }
		}
	}
}


extension Sequence {
	/**
	```
	[(1, "a"), (nil, "b")].toDictionary { ($1, $0) }
	//=> ["a": 1, "b": nil]
	```
	*/
	func toDictionary<Key: Hashable, Value>(withKey pickKeyValue: (Element) -> (Key, Value?)) -> [Key: Value?] {
		var dictionary = [Key: Value?]()

		for element in self {
			let newElement = pickKeyValue(element)
			dictionary[newElement.0] = newElement.1
		}

		return dictionary
	}
}


extension Sequence {
	/**
	Convert a sequence to a dictionary by mapping over the values and using the returned key as the key and the current sequence element as value.

	If the returned key is `nil`, the element is skipped.

	```
	[1, 2, 3].toDictionary { $0 }
	//=> [1: 1, 2: 2, 3: 3]

	[1, 2, 3].toDictionary(withKey: \.self)
	//=> [1: 1, 2: 2, 3: 3]
	```
	*/
	func toDictionaryCompact<Key: Hashable>(withKey pickKey: (Element) -> Key?) -> [Key: Element] {
		var dictionary = [Key: Element]()

		for element in self {
			guard let key = pickKey(element) else {
				continue
			}

			dictionary[key] = element
		}

		return dictionary
	}
}


extension Locale {
	static let all = availableIdentifiers.map { Self(identifier: $0) }

	/**
	A dictionary with available currency codes as keys and their locale as value.
	*/
	static let currencyWithLocale = all
		.removingDuplicates(by: \.currency)
		.toDictionaryCompact(withKey: \.currency)

	/**
	An array of tuples with currency code and its localized currency name and localized region name.
	*/
	static let currencyWithLocalizedNameAndRegionName: [(currency: Currency, localizedCurrencyName: String, localizedRegionName: String)] = currencyWithLocale
		 .compactMap { currency, locale in
			 guard
				let region = locale.language.region,
				let localizedCurrencyName = locale.localizedString(forCurrencyCode: currency.identifier),
				let localizedRegionName = locale.localizedString(forRegionCode: region.identifier)
			 else {
				 return nil
			 }

			 return (currency, localizedCurrencyName, localizedRegionName)
		 }
		 .sorted(by: \.currency.identifier)
}


extension Locale {
	var localizedName: String { Self.current.localizedString(forIdentifier: identifier) ?? identifier }
}


#if os(macOS)
extension NSWorkspace {
	/**
	Running GUI apps. Excludes menu bar apps and daemons.
	*/
	var runningGUIApps: [NSRunningApplication] {
		runningApplications.filter { $0.activationPolicy == .regular }
	}
}

extension NSWorkspace {
	func appName(for url: URL) -> String {
		url.localizedName.replacingSuffix(".app", with: "").toString
	}
}
#endif


struct SystemSound: Hashable, Identifiable {
	let id: SystemSoundID

	func play(alert: Bool = false) async {
		let method = alert ? AudioServicesPlayAlertSoundWithCompletion : AudioServicesPlaySystemSoundWithCompletion

		await withCheckedContinuation { continuation in
			method(id) {
				continuation.resume()
			}
		}
	}
}

extension SystemSound {
	/**
	Create a system sound from a URL pointing to an audio file.
	*/
	init?(_ url: URL) {
		var id: SystemSoundID = 0
		guard AudioServicesCreateSystemSoundID(url as NSURL, &id) == kAudioServicesNoError else {
			return nil
		}

		self.id = id
	}

	/**
	Create a system sound from a Base64-encoded audio file.
	*/
	init?(base64EncodedFile: String, ofType contentType: UTType) {
		guard
			let url = try? Data(base64Encoded: base64EncodedFile)?
				.writeToUniqueTemporaryFile(contentType: contentType)
		else {
			return nil
		}

		self.init(url)
	}
}

extension Device {
	private static let silentAudio: SystemSound? = {
		// Smallest valid MP3 file.
		let audio = "/+MYxAAAAANIAAAAAExBTUUzLjk4LjIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

		return SystemSound(base64EncodedFile: audio, ofType: .mp3)
	}()

	/**
	Whether the silent switch on the device is enabled.

	- Note: This will report true even if silent mode is not enabled if run while Voice Memos is recording.
	*/
	@available(macOS, unavailable)
	static var isSilentModeEnabled: Bool {
		get async {
			guard let silentAudio else {
				assertionFailure()
				return false
			}

			// When silent mode is enabled, the system skips playing the audio file and the function takes less than a millisecond to execute. We check for this to determine whether silent mode is enabled.

			let duration = await ContinuousClock().measure {
				await silentAudio.play()
			}

			return duration < .milliseconds(50) // 10ms works on modern phones, but 50ms is required for older phones like iPhone 8.
		}
	}
}


#if canImport(UIKit)
extension Device {
	enum HapticFeedback {
		case success
		case warning
		case error
		case selection
		case soft
		case light
		case medium
		case heavy
		case rigid
		case legacy

		fileprivate func generate() {
			switch self {
			case .success:
				UINotificationFeedbackGenerator().notificationOccurred(.success)
			case .warning:
				UINotificationFeedbackGenerator().notificationOccurred(.warning)
			case .error:
				UINotificationFeedbackGenerator().notificationOccurred(.error)
			case .selection:
				UISelectionFeedbackGenerator().selectionChanged()
			case .soft:
				UIImpactFeedbackGenerator(style: .soft).impactOccurred()
			case .light:
				UIImpactFeedbackGenerator(style: .light).impactOccurred()
			case .medium:
				UIImpactFeedbackGenerator(style: .medium).impactOccurred()
			case .heavy:
				UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
			case .rigid:
				UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
			case .legacy:
				AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, nil)
			}
		}
	}

	static func hapticFeedback(_ type: HapticFeedback) {
		type.generate()
	}
}
#endif


#if os(macOS)
extension Device {
	/**
	Flash the screen like when taking a screenshot.
	*/
	static func flashScreen() async {
		await SystemSound(id: kSystemSoundID_FlashScreen).play(alert: true)
	}
}
#endif


extension String {
	var trimmed: String {
		trimmingCharacters(in: .whitespacesAndNewlines)
	}

	var trimmedLeading: String {
		replacing(/^\s+/, with: "")
	}

	var trimmedTrailing: String {
		replacing(/\s+$/, with: "")
	}
}


extension CharacterSet {
	func contains(_ character: Character) -> Bool {
		guard
			character.unicodeScalars.count == 1,
			let firstUnicodeScalar = character.unicodeScalars.first
		else {
			return false
		}

		return contains(firstUnicodeScalar)
	}
}


extension CharacterSet {
	static let lowercaseASCIILetters = Self(charactersIn: "a"..."z")
	static let uppercaseASCIILetters = Self(charactersIn: "A"..."Z")
	static let asciiLetters = lowercaseLetters.union(uppercaseLetters)
	static let asciiNumbers = Self(charactersIn: "0"..."9")
	static let asciiLettersAndNumbers = asciiLetters.union(asciiNumbers)

	// https://stackoverflow.com/a/3641782/64949
	static let urlSchemeAllowed = Self(charactersIn: "+-.")
		.union(asciiLettersAndNumbers)
}


extension StringProtocol {
	/**
	Check that the string only contains characters in the given `CharacterSet`.
	*/
	func hasOnlyCharacters(in characterSet: CharacterSet) -> Bool {
		rangeOfCharacter(from: characterSet.inverted) == nil
	}
}


extension Character {
	var isASCIILetter: Bool { isASCII && isLetter }
	var isLowercaseASCIILetter: Bool { isASCIILetter && isLowercase }
	var isUppercaseASCIILetter: Bool { isASCIILetter && isUppercase }
	var isASCIINumber: Bool { isASCII && isNumber }
	var isASCIILetterOrNumber: Bool { isASCII && (isASCIILetter || isASCIINumber) }
}


extension StringProtocol {
	/**
	Truncate the string to the given maximum length including the truncation indicator.

	- Note: The resulting string might be shorter than the given number depending on whitespace and punctation.

	```
	"Unicorn".truncating(to: 4)
	//=> "Uni…"
	```
	*/
	func truncating(
		to maxLength: Int,
		truncationIndicator: String = "…"
	) -> String {
		assert(maxLength >= 0, "maxLength should not be negative")

		guard maxLength > 0 else {
			return ""
		}

		guard count > maxLength else {
			return String(self)
		}

		// Edge-case
		guard maxLength > truncationIndicator.count else {
			return String(truncationIndicator.prefix(maxLength))
		}

		var truncatedString = prefix(maxLength - truncationIndicator.count)

		// If the truncated string ends with a punctation character, we strip it to make it look better.
		if
			let lastCharacter = truncatedString.last,
			CharacterSet.punctuationCharacters.contains(lastCharacter)
		{
			truncatedString = truncatedString.dropLast()
		}

		return "\(truncatedString.toString.trimmedTrailing)\(truncationIndicator)"
	}
}


extension FloatingPoint {
	/**
	Round the number to the nearest multiple of the given number.

	```
	23.4.roundedToMultiple(of: 5)
	//=> 5
	```
	*/
	func roundedToMultiple(
		of value: some BinaryInteger,
		roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero
	) -> Self {
		let value = Self(value)
		return (self / value).rounded(roundingRule) * value
	}
}


extension BinaryFloatingPoint {
	func truncated(
		toDecimalPlaces decimalPlaces: Int
	) -> Self {
		guard decimalPlaces >= 0 else {
			return self
		}

		var divisor: Self = 1
		for _ in 0..<decimalPlaces {
			divisor *= 10
		}

		return floor(divisor * self) / divisor
	}
}


extension Float {
	var toDouble: Double { .init(self) }
}

extension Double {
	var toFloat: Float { .init(self) }
}


enum Reachability {
	/**
	Checks whether we're currently online.
	*/
	static func isOnline(host: String = "apple.com") -> Bool {
		guard let ref = SCNetworkReachabilityCreateWithName(nil, host) else {
			return false
		}

		var flags = SCNetworkReachabilityFlags.connectionAutomatic
		if !SCNetworkReachabilityGetFlags(ref, &flags) {
			return false
		}

		return flags.contains(.reachable) && !flags.contains(.connectionRequired)
	}

	/**
	Checks multiple sources of whether we're currently online.
	*/
	static func isOnlineExtensive() -> Bool {
		let hosts = [
			"apple.com",
			"google.com",
			"cloudflare.com",
			"baidu.com",
			"yandex.ru"
		]

		return hosts.contains { isOnline(host: $0) }
	}
}


extension CLLocationCoordinate2D {
	/**
	Get the [geo URI](https://en.wikipedia.org/wiki/Geo_URI_scheme) for the coordiate.
	*/
	var geoURI: URL { URL(string: "geo:\(latitude),\(longitude)")! }
}

extension CLLocation {
	/**
	Get the [geo URI](https://en.wikipedia.org/wiki/Geo_URI_scheme) for the location, including accuracy.
	*/
	func geoURI(includeAccuracy: Bool) -> URL {
		let geoURI = coordinate.geoURI

		guard
			includeAccuracy,
			horizontalAccuracy >= 0
		else {
			return geoURI
		}

		return URL(string: "\(geoURI);u=\(Int(horizontalAccuracy))")!
	}
}


extension CGImage {
	var toXImage: XImage { XImage(cgImage: self) }
}


extension XImage {
	func resized(to newSize: CGSize) -> XImage {
		#if os(macOS)
		Self(size: newSize, flipped: false) {
			self.draw(in: $0)
			return true
		}
			.isTemplate(isTemplate)
		#else
		UIGraphicsImageRenderer(size: newSize).image { _ in
			draw(in: CGRect(origin: .zero, size: newSize))
		}
			.withRenderingMode(renderingMode)
		#endif
	}
}


#if os(macOS)
extension NSImage {
	/**
	`UIImage` polyfill.
	*/
	var cgImage: CGImage? { cgImage(forProposedRect: nil, context: nil, hints: nil) }

	/**
	`UIImage` polyfill.
	*/
	convenience init(cgImage: CGImage) {
		self.init(cgImage: cgImage, size: .zero)
	}
}

extension NSImage {
	/**
	UIKit polyfill.
	*/
	convenience init?(systemName name: String) {
		self.init(systemSymbolName: name, accessibilityDescription: nil)
	}

	/**
	UIKit polyfill.

	Makes it easier to pass in symbol configuration in a cross-platform manner.
	*/
	func withConfiguration(_ configuration: SymbolConfiguration) -> NSImage {
		withSymbolConfiguration(configuration)! // Unclear how it can fail.
	}
}

extension NSImage {
	func normalizingImage() -> NSImage {
		guard let image = cgImage?.toXImage else {
			return resized(to: size)
		}

		return image
	}
}

extension NSImage {
	/**
	Toggle `.isTemplate` on the image.
	*/
	func isTemplate(_ isTemplate: Bool = true) -> Self {
		self.isTemplate = isTemplate
		return self
	}
}
#endif


enum Validators {
	static func isIPv4(_ string: String) -> Bool {
		IPv4Address(string) != nil
	}

	static func isIPv6(_ string: String) -> Bool {
		IPv6Address(string) != nil
	}

	static func isIP(_ string: String) -> Bool {
		isIPv4(string) || isIPv6(string)
	}
}


extension URL {
	/**
	Create a URL from a human string, gracefully.

	```
	URL(humanString: "sindresorhus.com")?.absoluteString
	//=> "https://sindresorhus.com"
	```
	*/
	init?(humanString: String) {
		let string = humanString.trimmed

		guard
			!string.isEmpty,
			!string.hasPrefix("."),
			!string.hasSuffix("."),
			string != "https://",
			string != "http://",
			string != "file://"
		else {
			return nil
		}

		let hasScheme = string.starts(with: /[a-z\d-]+:/) && !string.hasPrefix("localhost")

		let isValid = string.contains(".")
			|| string.hasPrefix("localhost")
			|| hasScheme

		guard isValid else {
			return nil
		}

		let scheme = Validators.isIP(string) ? "http" : "https"
		let url = hasScheme ? string : "\(scheme)://\(string)"

		self.init(string: url)
	}
}


extension URLSession {
	/**
	Throws an error if the given URL is not reachable.
	*/
	func checkIfReachable(
		_ url: URL,
		method: URLRequest.Method = .head,
		timeout: Duration = .seconds(10),
		requireSuccessStatusCode: Bool = true
	) async throws {
		var urlRequest = URLRequest(
			method: method,
			url: url,
			timeout: timeout
		)

		urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

		let (_, response) = try await URLSession.shared.data(for: urlRequest)

		if requireSuccessStatusCode {
			try response.throwIfHTTPResponseButNotSuccessStatusCode()
		}
	}

	/**
	Returns a boolean for whether the given URL is reachable.
	*/
	func isReachable(
		_ url: URL,
		method: URLRequest.Method = .head,
		timeout: Duration = .seconds(10),
		requireSuccessStatusCode: Bool = true
	) async -> Bool {
		do {
			try await checkIfReachable(
				url,
				method: method,
				timeout: timeout,
				requireSuccessStatusCode: requireSuccessStatusCode
			)

			return true
		} catch {
			return false
		}
	}
}


extension DataFrame.Row {
	func toDictionary() -> [String: Any] {
		var dictionary = [String: Any]()

		for column in base.columns {
			dictionary[column.name] = self[column.name]
		}

		return dictionary
	}
}

extension DataFrame {
	func toArray() -> [[String: Any]] {
		rows.map { $0.toDictionary() }
	}
}


extension Sequence {
	func firstNonNil<Result>(
		_ transform: (Element) throws -> Result?
	) rethrows -> Result? {
		for value in self {
			if let value = try transform(value) {
				return value
			}
		}

		return nil
	}
}


extension CIImage {
	/**
	Read QR codes in the image.

	It's sorted by confidence, highest confidence first.
	*/
	func readQRCodes() -> [CIQRCodeFeature] {
		guard
			let detector = CIDetector(
				ofType: CIDetectorTypeQRCode,
				context: nil,
				options: [
					CIDetectorAccuracy: CIDetectorAccuracyHigh
				]
			)
		else {
			return []
		}

		var features = detector.features(in: self)

		// If the image has transparency, the detector will replace the transparency with black, which means the black QR code will disappear. So if we have no matches, we try again with the colors inverted.
		// Fixture: https://user-images.githubusercontent.com/713559/181952750-91804ebf-bc62-4346-8b60-a341c6d37c7e.png
		if features.isEmpty {
			let filter = CIFilter.colorInvert()
			filter.inputImage = self

			guard let outputImage = filter.outputImage else {
				return []
			}

			features = detector.features(in: outputImage)
		}

		return features.compactMap { $0 as? CIQRCodeFeature }
	}

	/**
	Read QR codes in the image and return their message.

	It's sorted by confidence, highest confidence first.
	*/
	func readMessageForQRCodes() -> [String] {
		readQRCodes().compactMap(\.messageString?.nilIfEmptyOrWhitespace)
	}
}


extension Data {
	var toString: String? { String(data: self, encoding: .utf8) }
}

extension String {
	var toData: Data { Data(utf8) }
}

extension [Character] {
	var toString: String { .init(self) }
}


extension Data {
	/**
	Pretty formats the JSON.
	*/
	func prettyFormatJSON() throws -> String {
		let json = try JSONSerialization.jsonObject(with: self)
		return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted).toString ?? ""
	}
}

extension String {
	/**
	Pretty formats the JSON.
	*/
	func prettyFormatJSON() throws -> Self {
		try toData.prettyFormatJSON()
	}
}


extension StringProtocol {
	/**
	Removes the file extension from a filename.
	*/
	func removingFileExtension() -> String {
		replacingOccurrences(of: #"\..*$"#, with: "", options: .regularExpression)
	}
}


extension Data {
	struct ParseJSONNonObjectError: LocalizedError {
		let errorDescription: String? = "The JSON must have a top-level object."
	}

	/**
	Parses the JSON data into a dictionary.

	- Throws: If the data is not valid JSON.
	- Throws: If the JSON does not have a top-level object.
	*/
	func jsonToDictionary() throws -> [String: Any] {
		let json = try JSONSerialization.jsonObject(with: self)

		guard let dictionary = json as? [String: Any] else {
			throw ParseJSONNonObjectError()
		}

		return dictionary
	}
}


extension Dictionary {
	/**
	Convert the dictionary to an `IntentFile` which will end up as a "Dictionary" type in Shortcuts.
	*/
	func toIntentFile(filename: String? = nil) throws -> IntentFile {
		try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
			.toIntentFile(contentType: .json, filename: filename)
	}
}


extension Dictionary {
	static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
		var result = lhs
		result += rhs
		return result
	}

	static func += (lhs: inout [Key: Value], rhs: [Key: Value]) {
		for (key, value) in rhs {
			lhs[key] = value
		}
	}
}


extension Dictionary {
	/**
	Returns a new dictionary containing only the key-value pairs that have non-nil keys as the result of transformation by the given closure.
	*/
	func compactMapKeys<T>(_ transform: (Key) throws -> T?) rethrows -> [T: Value] {
		try reduce(into: [T: Value]()) { result, x in
			if let key = try transform(x.key) {
				result[key] = x.value
			}
		}
	}
}


#if canImport(UIKit)
struct DocumentScannerView: UIViewControllerRepresentable {
	final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
		private let view: DocumentScannerView

		init(_ view: DocumentScannerView) {
			self.view = view
		}

		func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
			let pages = (0..<scan.pageCount).map { scan.imageOfPage(at: $0) }

			view.onCompletion(.success(pages))
		}

		func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
			view.onCancel()
		}

		func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
			view.onCompletion(.failure(error))
		}
	}

	var onCompletion: (Result<[UIImage], Error>) -> Void
	var onCancel: () -> Void

	func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
		let scannerViewController = VNDocumentCameraViewController()
		scannerViewController.delegate = context.coordinator
		return scannerViewController
	}

	func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

	func makeCoordinator() -> Coordinator { .init(self) }
}

extension View {
	/**
	Presents the system document scanner.

	When the operation is finished, `isPresented` will be set to `false` before `onCompletion` is called. If the user cancels the operation, `isPresented` will be set to `false` and `onCompletion` will be called with an empty array.
	*/
	func documentScanner(
		isPresented: Binding<Bool>,
		onCompletion: @escaping (Result<[UIImage], Error>) -> Void
	) -> some View {
		fullScreenCover(isPresented: isPresented) {
			DocumentScannerView {
				isPresented.wrappedValue = false
				onCompletion($0)
			} onCancel: {
				isPresented.wrappedValue = false
				onCompletion(.success([]))
			}
				.ignoresSafeArea()
		}
	}
}
#endif


extension Binding {
	func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
		.init(
			get: { wrappedValue != nil },
			set: { isPresented in
				if !isPresented {
					wrappedValue = nil
				}
			}
		)
	}
}


extension Binding where Value: SetAlgebra, Value.Element: Hashable {
	func contains(_ element: Value.Element) -> Binding<Bool> {
		.init(
			get: { wrappedValue.contains(element) },
			set: {
				if $0 {
					wrappedValue.insert(element)
				} else {
					wrappedValue.remove(element)
				}
			}
		)
	}
}


extension View {
	func alert2(
		_ title: Text,
		isPresented: Binding<Bool>,
		@ViewBuilder actions: () -> some View,
		@ViewBuilder message: () -> some View
	) -> some View {
		background(
			EmptyView()
				.alert(
					title,
					isPresented: isPresented,
					actions: actions,
					message: message
				)
		)
	}

	func alert2(
		_ title: String,
		isPresented: Binding<Bool>,
		@ViewBuilder actions: () -> some View,
		@ViewBuilder message: () -> some View
	) -> some View {
		alert2(
			Text(title),
			isPresented: isPresented,
			actions: actions,
			message: message
		)
	}

	func alert2(
		_ title: Text,
		message: String? = nil,
		isPresented: Binding<Bool>,
		@ViewBuilder actions: () -> some View
	) -> some View {
		// swiftlint:disable:next trailing_closure
		alert2(
			title,
			isPresented: isPresented,
			actions: actions,
			message: {
				if let message {
					Text(message)
				}
			}
		)
	}

	func alert2(
		_ title: String,
		message: String? = nil,
		isPresented: Binding<Bool>,
		@ViewBuilder actions: () -> some View
	) -> some View {
		// swiftlint:disable:next trailing_closure
		alert2(
			title,
			isPresented: isPresented,
			actions: actions,
			message: {
				if let message {
					Text(message)
				}
			}
		)
	}

	func alert2(
		_ title: Text,
		message: String? = nil,
		isPresented: Binding<Bool>
	) -> some View {
		// swiftlint:disable:next trailing_closure
		alert2(
			title,
			message: message,
			isPresented: isPresented,
			actions: {}
		)
	}

	func alert2(
		_ title: String,
		message: String? = nil,
		isPresented: Binding<Bool>
	) -> some View {
		// swiftlint:disable:next trailing_closure
		alert2(
			title,
			message: message,
			isPresented: isPresented,
			actions: {}
		)
	}
}


extension View {
	func alert2<T>(
		title: (T) -> Text,
		presenting data: Binding<T?>,
		@ViewBuilder actions: (T) -> some View,
		@ViewBuilder message: (T) -> some View
	) -> some View {
		background(
			EmptyView()
				.alert(
					data.wrappedValue.map(title) ?? Text(""),
					isPresented: data.isPresent(),
					presenting: data.wrappedValue,
					actions: actions,
					message: message
				)
		)
	}

	func alert2<T>(
		title: (T) -> Text,
		message: ((T) -> String?)? = nil,
		presenting data: Binding<T?>,
		@ViewBuilder actions: (T) -> some View
	) -> some View {
		alert2(
			title: { title($0) },
			presenting: data,
			actions: actions,
			message: {
				if let message = message?($0) {
					Text(message)
				}
			}
		)
	}

	func alert2<T>(
		title: (T) -> String,
		message: ((T) -> String?)? = nil,
		presenting data: Binding<T?>,
		@ViewBuilder actions: (T) -> some View
	) -> some View {
		alert2(
			title: { Text(title($0)) },
			message: message,
			presenting: data,
			actions: actions
		)
	}

	func alert2<T>(
		title: (T) -> Text,
		message: ((T) -> String?)? = nil,
		presenting data: Binding<T?>
	) -> some View {
		// swiftlint:disable:next trailing_closure
		alert2(
			title: title,
			message: message,
			presenting: data,
			actions: { _ in }
		)
	}

	func alert2<T>(
		title: (T) -> String,
		message: ((T) -> String?)? = nil,
		presenting data: Binding<T?>
	) -> some View {
		alert2(
			title: { Text(title($0)) },
			message: message,
			presenting: data
		)
	}
}


extension View {
	func alert(error: Binding<Error?>) -> some View {
		alert2(
			title: { ($0 as NSError).localizedDescription },
			message: { ($0 as NSError).localizedRecoverySuggestion },
			presenting: error
		)
	}
}


extension SFSpeechRecognizer {
	func recognitionTask(with request: SFSpeechRecognitionRequest) async throws -> SFSpeechRecognitionResult {
		request.shouldReportPartialResults = false

		var task: SFSpeechRecognitionTask?
		var hasResumed = false

		return try await withTaskCancellationHandler {
			try await withCheckedThrowingContinuation { continuation in
				task = recognitionTask(with: request) { result, error in
					// It's possible that this closure can be called with a cancel error even after it has finished, so we have to protect it.
					guard !hasResumed else {
						return
					}

					if let error {
						hasResumed = true
						continuation.resume(throwing: error)
						return
					}

					guard let result else {
						assertionFailure()
						return
					}

					// `.isFinal` can be `false` even when `.shouldReportPartialResults = false`.
					guard result.isFinal else {
						return
					}

					hasResumed = true
					continuation.resume(returning: result)
				}
			}
		} onCancel: { [task] in
			task?.cancel()
		}
	}
}


extension SFSpeechRecognizer {
	static func requestAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
		await withCheckedContinuation { continuation in
			requestAuthorization {
				continuation.resume(returning: $0)
			}
		}
	}
}


extension URL {
	var filename: String {
		get { lastPathComponent }
		set {
			deleteLastPathComponent()
			appendPathComponent(newValue, isDirectory: false)
		}
	}

	var filenameWithoutExtension: String {
		get { deletingPathExtension().lastPathComponent }
		set {
			let fileExtension = pathExtension
			deleteLastPathComponent()
			appendPathComponent(newValue, isDirectory: false)
			appendPathExtension(fileExtension)
		}
	}
}


extension XScreen {
	/**
	The size of the screen multiplied by its scale factor.
	*/
	var nativeSize: CGSize {
		#if os(macOS)
		frame.size * backingScaleFactor
		#else
		nativeBounds.size
		#endif
	}
}


extension URLSession {
	/**
	Improvements over `.download()`:
	- Throws on non-2XX responses
	- Downloads to unique location
	- Uses the suggested filename instead of the default `CFNetwork_4234.tmp` filename
	- Retries
	*/
	func betterDownload(
		for request: URLRequest,
		maximumRetryCount: Int = 3
	) async throws -> (url: URL, response: URLResponse) {
		var retryCount = 0

		func run() async throws -> (URL, URLResponse) {
			let (fileURL, response) = try await download(for: request)

			do {
				try response.throwIfHTTPResponseButNotSuccessStatusCode()
			} catch {
				if retryCount < maximumRetryCount {
					retryCount += 1
					return try await run()
				}

				throw error
			}

			return (fileURL, response)
		}

		let (fileURL, response) = try await run()

		let newFileURL = try fileURL.copyToUniqueTemporaryDirectory(filename: response.suggestedFilename)

		return (newFileURL, response)
	}

	func betterDownload(
		from url: URL,
		maximumRetryCount: Int = 3
	) async throws -> (url: URL, response: URLResponse) {
		try await betterDownload(
			for: .init(url: url),
			maximumRetryCount: maximumRetryCount
		)
	}
}


#if os(macOS)
extension NSPasteboard {
	/**
	UIKit polyfill.
	*/
	var string: String? {
		get { string(forType: .string) }
		set {
			prepareForNewContents()

			guard let newValue else {
				return
			}

			setString(newValue, forType: .string)
		}
	}

	/**
	UIKit polyfill.
	*/
	var strings: [String]? { // swiftlint:disable:this discouraged_optional_collection
		get {
			pasteboardItems?.compactMap { $0.string(forType: .string) }
		}
		set {
			prepareForNewContents()

			guard let newValue else {
				return
			}

			let items = newValue.map { string in
				let item = NSPasteboardItem()
				item.setString(string, forType: .string)
				return item
			}

			writeObjects(items)
		}
	}
}
#endif


extension XPasteboard {
	/**
	On macOS, the pasteboard contents are available only on the current device, and not on any other devices.
	On iOS, there's no way to prevent sharing with Universal Clipboard.
	*/
	var stringForCurrentHostOnly: String? {
		get { string }
		set {
			#if os(macOS)
			prepareForNewContents(with: .currentHostOnly)

			guard let newValue else {
				return
			}

			setString(newValue, forType: .string)
			#else
			string = newValue
			#endif
		}
	}

	/**
	On macOS, the pasteboard contents are available only on the current device, and not on any other devices.
	On iOS, there's no way to prevent sharing with Universal Clipboard.
	*/
	var stringsForCurrentHostOnly: [String] {
		get { strings ?? [] }
		set {
			#if os(macOS)
			prepareForNewContents(with: .currentHostOnly)

			guard let strings = newValue.nilIfEmpty else {
				return
			}

			let items = strings.map { string in
				let item = NSPasteboardItem()
				item.setString(string, forType: .string)
				return item
			}

			writeObjects(items)
			#else
			strings = newValue
			#endif
		}
	}
}


#if os(macOS)
struct SearchField: NSViewRepresentable {
	typealias NSViewType = CocoaSearchField

	final class CocoaSearchField: NSSearchField {
		override func viewDidMoveToWindow() {
			window?.makeFirstResponder(self)
		}
	}

	final class Coordinator: NSObject, NSSearchFieldDelegate {
		var view: SearchField

		init(_ view: SearchField) {
			self.view = view
		}

		func controlTextDidChange(_ notification: Notification) {
			guard let textField = notification.object as? CocoaSearchField else {
				return
			}

			view.text = textField.stringValue
		}
	}

	@Binding var text: String
	var drawsBackground = true
	var placeholder: String?
	var fontSize: Double?

	func makeCoordinator() -> Coordinator { .init(self) }

	func makeNSView(context: Context) -> NSViewType {
		let nsView = CocoaSearchField()
		nsView.wantsLayer = true
		nsView.translatesAutoresizingMaskIntoConstraints = false
		nsView.setContentHuggingPriority(.defaultHigh, for: .vertical)
		nsView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		nsView.delegate = context.coordinator
		return nsView
	}

	func updateNSView(_ nsView: NSViewType, context: Context) {
		nsView.drawsBackground = drawsBackground
		nsView.placeholderString = placeholder

		if text != nsView.stringValue {
			nsView.stringValue = text
		}

		if let fontSize {
			nsView.font = .systemFont(ofSize: fontSize)
		}
	}
}
#endif


struct NavigationLinkButtonStyle: PrimitiveButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		ZStack {
			NavigationLink(value: true) {
				configuration.label
			}
			Button("") {
				configuration.trigger()
			}
		}
	}
}

extension PrimitiveButtonStyle where Self == NavigationLinkButtonStyle {
	/**
	Make the button look like a `NavigationLink`.
	*/
	static var navigationLink: Self { .init() }
}


extension Button<Label<Text, Image>> {
	init(
		_ title: String,
		systemImage: String,
		role: ButtonRole? = nil,
		action: @escaping () -> Void
	) {
		self.init(
			role: role,
			action: action
		) {
			Label(title, systemImage: systemImage)
		}
	}
}


extension NLLanguage: CaseIterable {
	public static let allCases: [Self] = [
		.amharic,
		.arabic,
		.armenian,
		.bengali,
		.bulgarian,
		.burmese,
		.catalan,
		.cherokee,
		.croatian,
		.czech,
		.danish,
		.dutch,
		.english,
		.finnish,
		.french,
		.georgian,
		.german,
		.greek,
		.gujarati,
		.hebrew,
		.hindi,
		.hungarian,
		.icelandic,
		.indonesian,
		.italian,
		.japanese,
		.kannada,
		.khmer,
		.korean,
		.lao,
		.malay,
		.malayalam,
		.marathi,
		.mongolian,
		.norwegian,
		.oriya,
		.persian,
		.polish,
		.portuguese,
		.punjabi,
		.romanian,
		.russian,
		.simplifiedChinese,
		.sinhalese,
		.slovak,
		.spanish,
		.swedish,
		.tamil,
		.telugu,
		.thai,
		.tibetan,
		.traditionalChinese,
		.turkish,
		.ukrainian,
		.urdu,
		.vietnamese
	]
}


extension NLLanguage {
	var localizedName: String {
		Locale.current.localizedString(forIdentifier: rawValue) ?? ""
	}
}


extension NLEmbedding {
	static var supportedLanguage = NLLanguage.allCases
		.filter { !supportedRevisions(for: $0).isEmpty }
}


extension Collection {
	/**
	Get unique random indices in the collection.

	- Parameter maxCount: Must be 0 or larger.
	*/
	func uniqueRandomIndices(maxCount: Int, using generator: inout some RandomNumberGenerator) -> [Index] {
		assert(maxCount >= 0)

		// Remove the `Array` wrapper and return `some Collection<Index>` when targeting Swift 5.7.
		return Array(indices.shuffled(using: &generator).prefix(maxCount))
	}

	/**
	Get unique random indices in the collection.

	- Parameter maxCount: Must be 0 or larger.
	*/
	func uniqueRandomIndices(maxCount: Int) -> [Index] {
		uniqueRandomIndices(maxCount: maxCount, using: &.system)
	}
}


#if canImport(UIKit)
extension Device {
	static func accelerometerUpdates(interval: Duration) -> AsyncThrowingStream<CMAccelerometerData, Error> {
		.init { continuation in
			let motionManager = CMMotionManager()

			guard motionManager.isAccelerometerAvailable else {
				continuation.finish(throwing: "This device does not provide accelerometer data.".toError)
				return
			}

			motionManager.accelerometerUpdateInterval = interval.toTimeInterval

			motionManager.startAccelerometerUpdates(to: OperationQueue()) { data, error in
				if let error {
					continuation.finish(throwing: error)
					return
				}

				guard let data else {
					return
				}

				continuation.yield(data)
			}

			continuation.onTermination = { [motionManager] _ in
				motionManager.stopAccelerometerUpdates()
			}
		}
	}
}

extension Device {
	static func motionUpdates(interval: Duration) -> AsyncThrowingStream<CMDeviceMotion, Error> {
		.init { continuation in
			let motionManager = CMMotionManager()

			guard motionManager.isDeviceMotionAvailable else {
				continuation.finish(throwing: "This device does not provide motion data.".toError)
				return
			}

			motionManager.deviceMotionUpdateInterval = interval.toTimeInterval

			motionManager.startDeviceMotionUpdates(to: OperationQueue()) { data, error in
				if let error {
					continuation.finish(throwing: error)
					return
				}

				guard let data else {
					return
				}

				continuation.yield(data)
			}

			continuation.onTermination = { [motionManager] _ in
				motionManager.stopDeviceMotionUpdates()
			}
		}
	}
}

extension Device {
	private static func getOrientation(for data: CMAccelerometerData) -> UIDeviceOrientation {
		let absAccelerationX = abs(data.acceleration.x)
		let absAccelerationY = abs(data.acceleration.y)
		let absAccelerationZ = abs(data.acceleration.z)

		if absAccelerationZ > max(absAccelerationX, absAccelerationY) {
			return data.acceleration.z < 0 ? .faceUp : .faceDown
		}

		if absAccelerationX > absAccelerationY {
			return data.acceleration.x > 0 ? .landscapeRight : .landscapeLeft
		}

		if absAccelerationX < absAccelerationY {
			return data.acceleration.y < 0 ? .portrait : .portraitUpsideDown
		}

		return .unknown
	}

	static func orientationUpdates(interval: Duration) -> AsyncThrowingStream<UIDeviceOrientation, Error> {
		accelerometerUpdates(interval: interval)
			.map { Self.getOrientation(for: $0) }
			.eraseToAsyncThrowingStream()
	}

	static var orientation: UIDeviceOrientation {
		get async throws {
			(try await orientationUpdates(interval: .seconds(0.001)).first { _ in true }) ?? .unknown
		}
	}
}

extension UIDeviceOrientation: CustomStringConvertible {
	public var description: String {
		switch self {
		case .faceDown:
			return "faceDown"
		case .faceUp:
			return "faceUp"
		case .landscapeLeft:
			return "landscapeLeft"
		case .landscapeRight:
			return "landscapeRight"
		case .portrait:
			return "portrait"
		case .portraitUpsideDown:
			return "portraitUpsideDown"
		case .unknown:
			return "unknown"
		@unknown default:
			assertionFailure()
			return "unknown"
		}
	}
}
#endif


extension Locale {
	/**
	The identifier browsers use.

	This differs from `.identifier` by using a dash instead of underscore.

	https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl#locale_identification_and_negotiation
	*/
	var bcp47Identifier: String {
		identifier.replacingOccurrences(of: "_", with: "-")
	}
}


extension Double {
	/**
	Formats the number with compact style.

	```
	let number = 12345591313.0

	print(number.formatWithCompactStyle())
	//=> "12 billion"
	```
	*/
	func formatWithCompactStyle(
		abbreviatedUnit: Bool = false,
		locale: Locale = .current
	) -> String? {
		guard let context = JSContext() else {
			return nil
		}

		context.exceptionHandler = { _, exception in
			assertionFailure(exception?.toString() ?? "")
		}

		// TODO: Setting `minimumFractionDigits: 1, maximumFractionDigits: 1,` seems to have no effect and does not preserve one fraction digit. (macOS 12.3.1)
		// I can set `roundingPriority: 'morePrecision'`, but then it shows all the fraction digits.

		context.evaluateScript(
			"""
			function format(number, abbreviatedUnit, locale) {
			   return new Intl.NumberFormat(locale, {
				   notation: 'compact',
				   compactDisplay: abbreviatedUnit ? 'short' : 'long'
			   }).format(number);
			}
			"""
		)

		let format = context.objectForKeyedSubscript("format")

		return format?.call(withArguments: [self, abbreviatedUnit, locale.bcp47Identifier]).toString()
	}
}


extension XImage {
	// swiftlint:disable:next discouraged_optional_boolean
	func toDisplayRepresentationImage(isTemplate: Bool? = nil) -> DisplayRepresentation.Image? {
		guard let data = pngData() else {
			return nil
		}

		return .init(data: data, isTemplate: isTemplate)
	}
}


extension View {
	/**
	Fills the frame.
	*/
	func fillFrame(
		_ axis: Axis.Set = [.horizontal, .vertical],
		alignment: Alignment = .center
	) -> some View {
		frame(
			maxWidth: axis.contains(.horizontal) ? .infinity : nil,
			maxHeight: axis.contains(.vertical) ? .infinity : nil,
			alignment: alignment
		)
	}
}

// TODO: Use strongly-typed category names when Swift has "const" features for enum cases.
//enum IntentCategory: String {
//	case list = "List"
//	case dictionary = "Dictionary"
//	case text = "Text"
//	case image = "Image"
//	case audio = "Audio"
//	case device = "Device"
//	case web = "Web"
//}
//
//extension IntentDescription {
//	init(
//		_ descriptionText: LocalizedStringResource,
//		category: IntentCategory,
//		searchKeywords: [LocalizedStringResource] = []
//	) {
//		self.init(
//			descriptionText,
//			categoryName: "\(category.rawValue)",
//			searchKeywords: searchKeywords
//		)
//	}
//}


extension [XImage] {
	func createPDF() -> Data? {
		let pdfDocument = PDFDocument()

		for (index, image) in indexed() {
			guard let pdfPage = PDFPage(image: image) else {
				return nil
			}

			pdfDocument.insert(pdfPage, at: index)
		}

		return pdfDocument.dataRepresentation()
	}
}


extension CGRect {
	var shortestSide: Double { min(width, height) }
}


extension CGColorSpace {
	static let typed_extendedSRGB = CGColorSpace(name: CGColorSpace.extendedSRGB)!
}


extension CIImage {
	func pngData() -> Data? {
		CIContext().pngRepresentation(
			of: self,
			format: .RGBA8,
			colorSpace: colorSpace ?? .typed_extendedSRGB
		)
	}
}


extension CIImage {
	/**
	A better way to load a `CIImage` from `Data`:
	1. Throws on failure.
	2. Normalizes orientation.
	*/
	static func from(_ data: Data) throws -> Self {
		guard let ciImage = Self(data: data, options: [.applyOrientationProperty: true]) else {
			throw "Invalid image or unsupported image format.".toError
		}

		return ciImage
	}
}


extension CIImage {
	/**
	Apply a gaussian blur effect to the image.

	- Parameter radius: The blur radius in pixels. The required amount will vary depending on image dimensions.
	*/
	func gaussianBlurred(radius: Double) -> CIImage {
		clampedToExtent() // This ensures it won't get softened edges.
			.applyingGaussianBlur(sigma: radius)
			.cropped(to: extent)
	}

	/**
	Apply a gaussian blur effect to the image.

	- Parameter fractionalAmount: The blur amount in the range `0...1`. For example, `0.5` blur will look the same regardless of the dimensions of the image.
	*/
	func gaussianBlurred(fractionalAmount: Double) -> CIImage {
		// Make the slider exponential.
		// The 400 constant is just the visually optimal one from doing lots of experimentation. This favors more control over low blur values.
		let finalAmount = pow(400, fractionalAmount) / 400

		// TODO: This should probably use the pixel count, not just the shortest side length.
		// The max amount is the whole length, but there is no visible difference between the whole and half.
		let multiplier = extent.shortestSide / 2

		return gaussianBlurred(radius: finalAmount * multiplier)
	}
}


extension StringTransform {
	static let toLatinASCIILowercase = Self("Any-Latin; Latin-ASCII; Lower;")
}


extension String {
	func slugified(separator: Character = "-") -> Self {
		let allowedCharacters = CharacterSet(charactersIn: "\(separator)")
			.union(.asciiLettersAndNumbers)

		return (applyingTransform(.toLatinASCIILowercase, reverse: false) ?? self)
			.replacing(/\p{Punct}/, with: "")
			.components(separatedBy: allowedCharacters.inverted)
			.filter { !$0.isEmpty }
			.joined(separator: Self(separator))
	}
}


extension Color {
	#if os(macOS)
	/**
	- Important: Prefer `ShapeStyle.background` whenever possible.
	*/
	static let legacyBackground = Self(NSColor.windowBackgroundColor)
	#else
	/**
	- Important: Prefer `ShapeStyle.background` whenever possible.
	*/
	static let legacyBackground = Self(UIColor.systemBackground)
	#endif
}


extension AsyncSequence {
	func first() async rethrows -> Element? {
		try await first { _ in true }
	}
}


extension AsyncSequence {
	/**
	Convert an async sequence to an array.

	This can be useful if you just want to await all the elements in the async sequence instead of iterating over it.
	*/
	func toArray() async rethrows -> [Element] {
		try await reduce(into: [Element]()) { $0.append($1) }
	}
}


struct TimeoutError: Error, Equatable {}

func withTimeout<T: Sendable>(
	_ timeout: Duration?,
	operation: @Sendable () async throws -> T
) async throws -> T {
	guard let timeout else {
		return try await operation()
	}

	let start = ContinuousClock.now

	// `withoutActuallyEscaping` should be safe as the operation is called before the function returns.
	return try await withoutActuallyEscaping(operation) { escapableOperation in
		try await withThrowingTaskGroup(of: T.self) { group in
			group.addTask {
				try await escapableOperation()
			}

			group.addTask(priority: .high) {
				try await Task.sleep(until: start + timeout, clock: .continuous)
				throw TimeoutError()
			}

			defer {
				group.cancelAll()
			}

			return try await group.next()!
		}
	}
}


extension NWPathMonitor {
	/**
	Observe network changes for a specific interface type.
	*/
	static func changes(requiredInterfaceType: NWInterface.InterfaceType) -> AsyncStream<NWPath> {
		.init { continuation in
			let monitor = NWPathMonitor(requiredInterfaceType: requiredInterfaceType)

			monitor.pathUpdateHandler = {
				continuation.yield($0)
			}

			monitor.start(queue: .global())

			continuation.onTermination = { [monitor] _ in
				monitor.cancel()
			}
		}
	}

	static var currentCellularPath: NWPath? {
		get async {
			await NWPathMonitor.changes(requiredInterfaceType: .cellular).first()
		}
	}
}


extension NWConnection {
	/**
	Connect to the endpoint and wait for the connection to be established.
	*/
	func connect(timeout: Duration? = nil) async throws {
		try await withTimeout(timeout) {
			try await withTaskCancellationHandler {
				try await withCheckedThrowingContinuation { continuation in
					let hasResumedBox = LockedValueBox(false)

					stateUpdateHandler = { state in
						hasResumedBox.withLockedValue { [weak self] hasResumed in
							guard
								let self,
								!hasResumed
							else {
								return
							}

							switch state {
							case .setup, .preparing:
								break
							case .ready:
								stateUpdateHandler = nil
								hasResumed = true
								continuation.resume()
							case .waiting(let error), .failed(let error):
								stateUpdateHandler = nil
								hasResumed = true
								continuation.resume(throwing: error)
							case .cancelled:
								stateUpdateHandler = nil
								hasResumed = true
								continuation.resume(throwing: CancellationError())
							@unknown default:
								assertionFailure("Unhandled enum case.")
								stateUpdateHandler = nil
								hasResumed = true
								continuation.resume(throwing: CancellationError())
							}
						}
					}

					start(queue: .global())
				}
			} onCancel: {
				cancel()
			}
		}
	}
}


extension Device {
	static var isCellularDataEnabled: Bool {
		get async {
			let path = await NWPathMonitor.currentCellularPath
			return path?.status == .satisfied
		}
	}

	static var isCellularLowDataModeEnabled: Bool {
		get async {
			let path = await NWPathMonitor.currentCellularPath
			return path?.isConstrained ?? false
		}
	}
}


extension Data {
	func hexEncodedString() -> String {
		let utf8Digits = Array("0123456789abcdef".utf8)

		return String(unsafeUninitializedCapacity: count * 2) { pointer in
			var string = pointer.baseAddress!

			for byte in self {
				string[0] = utf8Digits[Int(byte / 16)]
				string[1] = utf8Digits[Int(byte % 16)]
				string += 2
			}

			return count * 2
		}
	}
}


extension String {
	func hexDecodedData() -> Data {
		lazy
			.dropFirst(hasPrefix("0x") ? 2 : 0)
			.compactMap {
				$0.hexDigitValue.map { UInt8($0) }
			}
			.reduce(
				into: (
					data: Data(capacity: count / 2),
					byte: nil as UInt8?
				)
			) { partialResult, nibble in
				if let byte = partialResult.byte {
					partialResult.data.append(byte + nibble)
					partialResult.byte = nil
				} else {
					partialResult.byte = nibble << 4
				}
			}
			.data
	}
}


#if canImport(UIKit)
private protocol SilenceDeprecationForUIScreenWindows {
	var screens: [UIScreen] { get }
}

private final class SilenceDeprecationForUIScreenWindowsImplementation: SilenceDeprecationForUIScreenWindows {
	@available(iOS, deprecated: 16)
	var screens: [UIScreen] { UIScreen.screens }
}

extension UIScreen {
	static var screens2: [UIScreen] {
		(SilenceDeprecationForUIScreenWindowsImplementation() as SilenceDeprecationForUIScreenWindows).screens
	}
}
#else
extension XScreen {
	static var screens2: [XScreen] { screens }
}
#endif


extension URL {
	@discardableResult
	func accessSecurityScopedResource<Value>(_ accessor: (URL) throws -> Value) rethrows -> Value {
		let didStartAccessing = startAccessingSecurityScopedResource()

		defer {
			if didStartAccessing {
				stopAccessingSecurityScopedResource()
			}
		}

		return try accessor(self)
	}
}


extension Data {
	/**
	Returns cryptographically secure random data.
	*/
	static func random(length: Int) -> Data {
		Data((0..<length).map { _ in UInt8.random(in: .min...(.max)) })
	}
}


extension Image {
	/**
	Create a SwiftUI `Image` from either `NSImage` or `UIImage`.
	*/
	init(xImage: XImage) {
		#if os(macOS)
		self.init(nsImage: xImage)
		#else
		self.init(uiImage: xImage)
		#endif
	}
}


extension XImage {
	var toSwiftUIImage: Image { Image(xImage: self) }
}


extension ImageRenderer {
	@MainActor
	var xImage: XImage? {
		#if os(macOS)
		nsImage
		#else
		uiImage
		#endif
	}

	@MainActor
	var image: Image? { xImage?.toSwiftUIImage }
}


/**
This exists as `CLLocationCoordinate2D` is an imported C struct and can potentially contain invalid values. This one validates on creation.
*/
struct LocationCoordinate2D: Hashable, Codable {
	let latitude: Double
	let longitude: Double

	init?(latitude: Double, longitude: Double) {
		guard
			CLLocationCoordinate2DIsValid(.init(latitude: latitude, longitude: longitude)),
			!(latitude == 0 && longitude == 0)
		else {
			return nil
		}

		self.latitude = latitude
		self.longitude = longitude
	}
}

extension LocationCoordinate2D {
	/**
	Parse from user input in the format “-77.0364, 38.8951” (latitude, longitude).
	*/
	static func parse(_ string: String) -> Self? {
		let components = string.split(separator: ",", maxSplits: 1)

		guard
			let latitudeString = components.first?.toString.trimmed,
			let longitudeString = components.last?.toString.trimmed,
			let latitude = Double(latitudeString),
			let longitude = Double(longitudeString)
		else {
			return nil
		}

		return .init(latitude: latitude, longitude: longitude)
	}

	var formatted: String { "\(latitude), \(longitude)" }
}


extension CLLocationCoordinate2D {
	var isValid: Bool {
		CLLocationCoordinate2DIsValid(self) && !(latitude == 0 && longitude == 0)
	}

	var nilIfInvalid: Self? {
		isValid ? self : nil
	}

	func validate() throws {
		if !isValid {
			throw "Invalid coordinate: \(formatted)".toError
		}
	}

	var formatted: String { "\(latitude), \(longitude)" }
}


/**
Access a state value inline in a view.

```
withState("") { stringBinding in
	TextEditor(text: stringBinding)
}
```

- Note: Use this sparingly.
- Note: `initialValue` will be set once. Changes to it will not be reflected.
*/
func withState<Value>(
	_ initialValue: Value,
	@ViewBuilder content: @escaping (Binding<Value>) -> some View
) -> some View {
	StateAccessView(
		initialValue: initialValue,
		content: content
	)
}

private struct StateAccessView<Value, Content: View>: View {
	private let content: (Binding<Value>) -> Content
	@State private var state: Value

	init(
		initialValue: Value,
		@ViewBuilder content: @escaping (Binding<Value>) -> Content
	) {
		self.content = content
		self._state = .init(wrappedValue: initialValue)
	}

	var body: some View {
		content($state)
	}
}


extension MKCoordinateRegion {
	init(
		center centerCoordinate: CLLocationCoordinate2D,
		radius: Measurement<UnitLength>
	) {
		self.init(
			center: centerCoordinate,
			radiusMeters: radius.converted(to: .meters).value
		)
	}
}

extension MKCoordinateRegion {
	init(
		center centerCoordinate: CLLocationCoordinate2D,
		radiusMeters: CLLocationDistance
	) {
		self.init(
			center: centerCoordinate,
			latitudinalMeters: radiusMeters,
			longitudinalMeters: radiusMeters
		)
	}
}

extension MKCoordinateRegion {
	/**
	Clamp to closest valid value.
	*/
	mutating func normalize() {
		center.normalize()
		span.normalize()
	}
}

extension CLLocationCoordinate2D {
	/**
	Clamp to closest valid value.
	*/
	mutating func normalize() {
		latitude = latitude.clamped(to: -90...90)
		longitude = longitude.clamped(to: -180...180)
	}
}

extension MKCoordinateSpan {
	/**
	Clamp to closest valid value.
	*/
	mutating func normalize() {
		latitudeDelta = latitudeDelta.clamped(to: 0...180)
		longitudeDelta = longitudeDelta.clamped(to: 0...360)
	}
}


extension CFArray {
	/**
	Convert a `CFArray` to an `Array`.

	Usually, you would just do `cfArray as NSArray as? [Foo]`, but sometimes that does not work.

	- Important: Make sure to specify the correct type, including optionality.
	*/
	func toArray<T>(ofType: T.Type) -> [T] {
		(0..<CFArrayGetCount(self)).map {
			unsafeBitCast(
				CFArrayGetValueAtIndex(self, $0),
				to: T.self
			)
		}
	}
}


#if os(macOS)
/**
- Important: Requires the `com.apple.security.print` entitlement.
*/
struct Printer: Identifiable {
	private let pmPrinter: PMPrinter

	fileprivate init(printer: PMPrinter) {
		self.pmPrinter = printer
	}

	fileprivate var _id: String? { PMPrinterGetID(pmPrinter)?.takeUnretainedValue() as String? }

	var id: String { _id ?? UUID().uuidString } // The fallback should in theory never be hit.

	var name: String? { PMPrinterGetName(pmPrinter)?.takeUnretainedValue() as String? }

	var isDefault: Bool { PMPrinterIsDefault(pmPrinter) }

	var isFavorite: Bool { PMPrinterIsFavorite(pmPrinter) }

	var isRemote: Bool {
		var isRemote: DarwinBoolean = false
		PMPrinterIsRemote(pmPrinter, &isRemote)
		return isRemote.boolValue
	}

	var location: String? { PMPrinterGetLocation(pmPrinter)?.takeUnretainedValue() as String? }

	var state: State {
		var state: PMPrinterState = 0
		PMPrinterGetState(pmPrinter, &state)

		switch Int(state) {
		case kPMPrinterIdle:
			return .idle
		case kPMPrinterProcessing:
			return .processing
		case kPMPrinterStopped:
			return .stopped
		default:
			return .idle
		}
	}

	var makeAndModel: String? {
		var makeAndModel: Unmanaged<CFString>?
		PMPrinterGetMakeAndModelName(pmPrinter, &makeAndModel)
		return makeAndModel?.takeUnretainedValue() as String?
	}

	var deviceURL: URL? {
		var url: Unmanaged<CFURL>?
		PMPrinterCopyDeviceURI(pmPrinter, &url)
		return url?.takeUnretainedValue() as URL?
	}

	func setAsDefault() {
		PMPrinterSetDefault(pmPrinter)
	}
}

extension Printer {
	enum State {
		case idle
		case processing
		case stopped

		var title: String {
			switch self {
			case .idle:
				"Idle"
			case .processing:
				"Processing"
			case .stopped:
				"Stopped"
			}
		}
	}
}

extension Printer {
	static func all() -> [Self] {
		allPMPrinters()
			.map { .init(printer: $0) }
			.filter { $0._id != nil }
	}

	static var defaultPrinter: Self? {
		all().first(where: \.isDefault)
	}

	private static func allPMPrinters() -> [PMPrinter] {
		var unmanagedArray: Unmanaged<CFArray>?
		PMServerCreatePrinterList(nil, &unmanagedArray)

		// `return unmanagedArray?.takeUnretainedValue() as NSArray? as? [PMPrinter]` crashes Swift.

		return unmanagedArray?.takeUnretainedValue().toArray(ofType: PMPrinter.self) ?? []
	}
}

#endif


extension Duration {
	enum ConversionUnit: Double {
		case days = 86_400_000_000_000
		case hours = 3_600_000_000_000
		case minutes = 60_000_000_000
		case seconds = 1_000_000_000
		case milliseconds = 1_000_000
		case microseconds = 1000
	}

	/**
	Nanoseconds representation.
	*/
	var nanoseconds: Int64 {
		let (seconds, attoseconds) = components
		let secondsNanos = seconds * 1_000_000_000
		let attosecondsNanons = attoseconds / 1_000_000_000
		let (totalNanos, isOverflow) = secondsNanos.addingReportingOverflow(attosecondsNanons)
		return isOverflow ? .max : totalNanos
	}

	func `in`(_ unit: ConversionUnit) -> Double {
		Double(nanoseconds) / unit.rawValue
	}

	var toTimeInterval: TimeInterval { self.in(.seconds) }
}

extension Double {
	var timeIntervalToDuration: Duration { .seconds(self) }
}


extension NSUbiquitousKeyValueStore {
	/**
	Strictly ensures the value is a boolean and not a number.

	`NSUbiquitousKeyValueStore` is pretty loose about types.
	*/
	@nonobjc
	func strictBool(forKey key: String) -> Bool? { // swiftlint:disable:this discouraged_optional_boolean
		guard
			let nsNumber = object(forKey: key) as? NSNumber,
			nsNumber.isBool
		else {
			return nil
		}

		return nsNumber.boolValue
	}

	/**
	Strictly ensures the value is a double and not an integer or bool.
	*/
	@nonobjc
	func strictDouble(forKey key: String) -> Double? {
		guard
			let nsNumber = object(forKey: key) as? NSNumber,
			nsNumber.isFloat,
			!nsNumber.isBool
		else {
			return nil
		}

		return nsNumber.doubleValue
	}

	/**
	Strictly ensures the value is an integer and not a double or bool.
	*/
	@nonobjc
	func strictInt(forKey key: String) -> Int? {
		guard
			let nsNumber = object(forKey: key) as? NSNumber,
			!nsNumber.isFloat,
			!nsNumber.isBool
		else {
			return nil
		}

		return nsNumber.intValue
	}

	/**
	Strictly ensures the value is a number and not a bool, but does not care whether the underlying type is a float or integer.
	*/
	@nonobjc
	func strictNumber(forKey key: String) -> Double? {
		guard
			let nsNumber = object(forKey: key) as? NSNumber,
			!nsNumber.isBool
		else {
			return nil
		}

		return nsNumber.doubleValue
	}
}


extension NSNumber {
	/**
	Whether the underlying number is a boolean.
	*/
	@nonobjc
	var isBool: Bool { CFGetTypeID(self) == CFBooleanGetTypeID() }

	/**
	Whether the underlying number is a float.
	*/
	@nonobjc
	var isFloat: Bool {
		guard !isBool else {
			return false
		}

		switch CFNumberGetType(self) {
		case .doubleType, .float32Type, .float64Type, .floatType, .cgFloatType:
			return true
		default:
			return false
		}
	}
}


extension CIImage {
	func averageColor() throws -> Color.Resolved {
		let inputImage = self

		let filter = CIFilter.areaAverage()
		filter.inputImage = inputImage
		filter.extent = inputImage.extent

		guard let outputImage = filter.outputImage else {
			throw "Failed to get average color from the image.".toError
		}

		var bitmap = [UInt8](repeating: 0, count: 4)
		let context = CIContext(options: [.workingColorSpace: NSNull()])
		context.render(
			outputImage,
			toBitmap: &bitmap,
			rowBytes: bitmap.count,
			bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
			format: .RGBA8,
			colorSpace: .typed_extendedSRGB
		)

		return .init(
			red: bitmap.colorValue(at: 0).toFloat,
			green: bitmap.colorValue(at: 1).toFloat,
			blue: bitmap.colorValue(at: 2).toFloat,
			opacity: bitmap.colorValue(at: 3).toFloat
		)
	}
}


extension CIImage {
	/**
	Extracts the dominant colors from the image.

	- Parameter count: Must be in the range `0...128`.
	*/
	func dominantColors(count: Int) throws -> [Color.Resolved] {
		assert((0...128).contains(count), "`count` must be in the range 0...128")

		let inputImage = self

		let filter = CIFilter.kMeans()
		filter.inputImage = inputImage
		filter.extent = inputImage.extent
		filter.count = count
		filter.passes = 20 // This is the max.
		filter.perceptual = true

		guard var outputImage = filter.outputImage else {
			throw "Failed to get dominant color from the image.".toError
		}

		outputImage = outputImage.settingAlphaOne(in: outputImage.extent)

		let context = CIContext(options: [.workingColorSpace: NSNull()])
		var bitmap = [UInt8](repeating: 0, count: 4 * count)

		context.render(
			outputImage,
			toBitmap: &bitmap,
			rowBytes: 4 * count,
			bounds: outputImage.extent,
			format: .RGBA8,
			colorSpace: .typed_extendedSRGB
		)

		return (0..<count).map { index in
			Color.Resolved(
				red: bitmap.colorValue(at: index * 4).toFloat,
				green: bitmap.colorValue(at: index * 4 + 1).toFloat,
				blue: bitmap.colorValue(at: index * 4 + 2).toFloat,
				opacity: bitmap.colorValue(at: index * 4 + 3).toFloat
			)
		}
	}
}


extension [UInt8] {
	fileprivate func colorValue(at index: Int) -> Double {
		guard index < count else {
			return 0
		}

		return Double(self[index]) / 255.0
	}
}


// The inverse of `withAnimation()`.
func withoutAnimation<Result>(@_inheritActorContext _ body: () throws -> Result) rethrows -> Result {
	var transaction = Transaction()
	transaction.disablesAnimations = true
	return try withTransaction(transaction, body)
}


extension CIImage {
	/**
	Inverts the colors.
	*/
	var inverted: CIImage? {
		let filter = CIFilter.colorInvert()
		filter.inputImage = self
		return filter.outputImage
	}
}


extension View {
	/**
	`.task()` with debouncing.
	*/
	func debouncingTask(
		id: some Equatable,
		priority: TaskPriority = .userInitiated,
		interval: Duration,
		@_inheritActorContext @_implicitSelfCapture _ action: @escaping @Sendable () async -> Void
	) -> some View {
		task(id: id, priority: priority) {
			do {
				try await Task.sleep(for: interval)
				await action()
			} catch {}
		}
	}
}


struct LockedValueBox<Value>: Sendable {
	private final class Storage: @unchecked Sendable {
		let lock = OSAllocatedUnfairLock()

		var value: Value

		init(value: Value) {
			self.value = value
		}
	}

	private let storage: Storage

	init(_ value: Value) {
		self.storage = Storage(value: value)
	}

	func withLockedValue<T>(_ mutate: (inout Value) throws -> T) rethrows -> T {
		try storage.lock.withLock {
			try mutate(&storage.value)
		}
	}
}


extension Duration {
	var toMeasurement: Measurement<UnitDuration> {
		.init(value: toTimeInterval, unit: .seconds)
	}
}

extension Measurement<UnitDuration> {
	var toDuration: Duration {
		converted(to: .seconds).value.timeIntervalToDuration
	}
}


extension Locale.Weekday: CaseIterable {
	/**
	Does not respect locale for the order.
	*/
	public static let allCases: [Self] = [
		.monday,
		.tuesday,
		.wednesday,
		.thursday,
		.friday,
		.saturday,
		.sunday
	]
}


extension Calendar {
	/**
	Returns the weekday for the day at the given date.
	*/
	func weekday(for date: Date) -> Locale.Weekday {
		let index = (component(.weekday, from: date) + 5) % 7
		return .allCases[index]
	}
}


extension Sequence {
	func descriptionAsKeyValue<Key, Value>() -> String where Element == (key: Key, value: Value) {
		Array(self).map { "\($0.key): \($0.value)" }.joined(separator: "\n")
	}
}


// UIKit polyfills.
#if os(macOS)
extension XAccessibility {
	// Does not exist on macOS.
	static let isAssistiveTouchRunning = false
	static let isBoldTextEnabled = false
	static let isClosedCaptioningEnabled = false
	static let isGuidedAccessEnabled = false
	static let isOnOffSwitchLabelsEnabled = false
	static let isShakeToUndoEnabled = false
	static let isVideoAutoplayEnabled = false
	static let buttonShapesEnabled = false
	static let prefersCrossFadeTransitions = false

	// macOS supports these, but does not expose a way to check.
	static let isGrayscaleEnabled = false
	static let isMonoAudioEnabled = false
	static let isSpeakScreenEnabled = false
	static let isSpeakSelectionEnabled = false

	static var isReduceMotionEnabled: Bool {
		NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
	}

	static var isInvertColorsEnabled: Bool {
		NSWorkspace.shared.accessibilityDisplayShouldInvertColors
	}

	static var isReduceTransparencyEnabled: Bool {
		NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
	}

	static var isSwitchControlRunning: Bool {
		NSWorkspace.shared.isSwitchControlEnabled
	}

	static var isVoiceOverRunning: Bool {
		NSWorkspace.shared.isVoiceOverEnabled
	}

	static var shouldDifferentiateWithoutColor: Bool {
		NSWorkspace.shared.accessibilityDisplayShouldDifferentiateWithoutColor
	}

	static var isDarkerSystemColorsEnabled: Bool {
		NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
	}
}
#endif

extension XAccessibility {
	// Better name for `isDarkerSystemColorsEnabled`.
	static var isIncreaseContrastEnabled: Bool { isDarkerSystemColorsEnabled }
}


extension Sequence where Element: BinaryFloatingPoint {
	func average() -> Element {
		var count: Element = 0
		var total: Element = 0

		for value in self {
			total += value
			count += 1
		}

		// swiftlint:disable:next empty_count
		guard count > 0 else {
			return 0
		}

		return total / count
	}
}


extension [Color.Resolved] {
	func averageColor() -> Element? {
		guard !isEmpty else {
			return nil
		}

		return .init(
			red: map(\.red).average(),
			green: map(\.green).average(),
			blue: map(\.blue).average(),
			opacity: map(\.opacity).average()
		)
	}
}


// TODO: Support unlimited operations when targeting Swift 6.
func firstOf<R>(
	_ operation1: @Sendable () async throws -> R,
	or operation2: @Sendable () async throws -> R
) async throws -> R {
	// `withoutActuallyEscaping` should be safe as the operation is called before the function returns.
	try await withoutActuallyEscaping(operation1) { escapableOperation1 in
		try await withoutActuallyEscaping(operation2) { escapableOperation2 in
			try await withThrowingTaskGroup(of: R.self) { group in
				try Task.checkCancellation()

				guard
					(group.addTaskUnlessCancelled { try await escapableOperation1() }),
					(group.addTaskUnlessCancelled { try await escapableOperation2() })
				else {
					throw CancellationError()
				}

				defer {
					group.cancelAll()
				}

				return try await group.next()!
			}
		}
	}
}


private var CLLocationManager_headingUpdates_delegateKey: UInt8 = 0

extension CLLocationManager {
	/**
	Provides an asynchronous stream of compass heading updates.

	- Note: It does not require any authorization by default, but the `.trueHeading` property will only be accurate if you request location access.
	*/
	@available(macOS, unavailable)
	@nonobjc
	static func headingUpdates() -> AsyncThrowingStream<CLHeading, Error> {
		let locationManager = CLLocationManager()
		locationManager.desiredAccuracy = kCLLocationAccuracyBest

		let hasLocationAuthorization = locationManager.authorizationStatus == .authorizedAlways
			|| locationManager.authorizationStatus == .authorizedWhenInUse

		return .init { continuation in
			guard CLLocationManager.headingAvailable() else {
				continuation.finish(throwing: "Device does not support heading updates.".toError)
				return
			}

			let delegate = HeadingDelegate(continuation: continuation)
			locationManager.delegate = delegate

			continuation.onTermination = { _ in
				locationManager.stopUpdatingHeading()

				if hasLocationAuthorization {
					locationManager.stopUpdatingLocation()
				}
			}

			locationManager.startUpdatingHeading()

			if hasLocationAuthorization {
				locationManager.startUpdatingLocation()
			}

			// Retain the delegate to keep it alive as long as needed.
			objc_setAssociatedObject(locationManager, &CLLocationManager_headingUpdates_delegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}

	private final class HeadingDelegate: NSObject, CLLocationManagerDelegate {
		private let continuation: AsyncThrowingStream<CLHeading, Error>.Continuation

		init(continuation: AsyncThrowingStream<CLHeading, Error>.Continuation) {
			self.continuation = continuation
		}

		func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
			continuation.yield(newHeading)
		}

		func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
			continuation.finish(throwing: error)
		}
	}
}


// TODO: Remove when targeting Swift 6.
extension AsyncSequence {
	func eraseToAsyncStream() -> AsyncStream<Element> {
		.init { continuation in
			let task = Task {
				do {
					for try await element in self {
						try Task.checkCancellation()
						continuation.yield(element)
					}
				} catch {}

				continuation.finish()
			}

			continuation.onTermination = { _ in
				task.cancel()
			}
		}
	}

	func eraseToAsyncThrowingStream() -> AsyncThrowingStream<Element, Error> {
		.init { continuation in
			let task = Task {
				do {
					for try await element in self {
						try Task.checkCancellation()
						continuation.yield(element)
					}

					continuation.finish()
				} catch {
					continuation.finish(throwing: error)
				}
			}

			continuation.onTermination = { _ in
				task.cancel()
			}
		}
	}
}


extension FloatingPointFormatStyle.Percent {
	/**
	Do not show fraction.
	*/
	var noFraction: Self { precision(.fractionLength(0)) }
}
