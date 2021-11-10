import Foundation
import JavaScriptCore

@MainActor
final class TransformTextWithJavaScriptIntentHandler: NSObject, TransformTextWithJavaScriptIntentHandling {
	func handle(intent: TransformTextWithJavaScriptIntent) async -> TransformTextWithJavaScriptIntentResponse {
		let text = intent.text ?? ""
		let javaScriptCode = intent.javaScriptCode ?? ""
		let response = TransformTextWithJavaScriptIntentResponse(code: .success, userActivity: nil)

		guard let jsContext = JSContext() else {
			return .init(code: .failure, userActivity: nil)
		}

		jsContext.setObject(text as NSString, forKeyedSubscript: "$text" as NSString)

		let script = "(() => {\n\(javaScriptCode)\n})()"

		guard let result = jsContext.evaluateScript(script)?.toString() else {
			return .init(code: .failure, userActivity: nil)
		}

		if let exception = jsContext.exception?.toString() {
			return .failure(failure: exception)
		}

		response.result = result

		return response
	}
}
