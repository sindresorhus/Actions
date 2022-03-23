import Foundation
import Intents

extension AppDelegate {
	func application(_ application: XApplication, handlerFor intent: INIntent) -> Any? {
		switch intent {
		case is CreateColorImageIntent:
			return CreateColorImageIntentHandler()
		case is SymbolImageIntent:
			return SymbolImageIntentHandler()
		case is ParseCSVIntent:
			return ParseCSVIntentHandler()
		case is ScanQRCodesInImageIntent:
			return ScanQRCodesInImageIntentHandler()
		case is ParseJSON5Intent:
			return ParseJSON5IntentHandler()
		case is TranscribeAudioIntent:
			return TranscribeAudioIntentHandler()
		case is GenerateCSVIntent:
			return GenerateCSVIntentHandler()
		#if canImport(AppKit)
		case is IsScreenLockedIntent:
			return IsScreenLockedIntentHandler()
		#endif
		default:
			assertionFailure("No handler for this intent")
			return nil
		}
	}
}
