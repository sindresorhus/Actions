import Foundation

#if canImport(UIKit)
import Contacts
#endif

@MainActor
final class GetUserDetailsIntentHandler: NSObject, GetUserDetailsIntentHandling {
	func handle(intent: GetUserDetailsIntent) async -> GetUserDetailsIntentResponse {
		let response = GetUserDetailsIntentResponse(code: .success, userActivity: nil)

		#if canImport(AppKit)
		let name = User.name
		let nameString = User.nameString
		#elseif canImport(UIKit)
		let name = CNContactStore().meContactPerson() ?? User.name
		let nameString = name?.formatted()
		#endif

		switch intent.type {
		case .unknown:
			break
		case .username:
			#if canImport(AppKit)
			response.result = User.username
			#endif
		case .name:
			response.result = nameString
		case .givenName:
			response.result = name?.givenName
		case .familyName:
			response.result = name?.familyName
		case .initials:
			response.result = name?.formatted(.name(style: .abbreviated))
		case .shell:
			response.result = User.shell
		case .languageCode:
			response.result = User.languageCode
		case .idleTime:
			#if canImport(AppKit)
			response.result = Int(User.idleTime).formatted()
			#endif
		}

		return response
	}
}
