import Foundation
import Intents

extension AppDelegate {
	func application(_ application: XApplication, handlerFor intent: INIntent) -> Any? {
		switch intent {
		case is CreateColorImageIntent:
			return CreateColorImageIntentHandler()
		default:
			assertionFailure("No handler for this intent")
			return nil
		}
	}
}
