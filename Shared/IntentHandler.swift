import Foundation
import Intents

extension AppDelegate {
	func application(_ application: XApplication, handlerFor intent: INIntent) -> Any? {
		switch intent {
		case is CreateColorImageIntent:
			return CreateColorImageIntentHandler()
		case is SymbolImageIntent:
			return SymbolImageIntentHandler()
		default:
			assertionFailure("No handler for this intent")
			return nil
		}
	}
}
