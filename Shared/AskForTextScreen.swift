import SwiftUI

struct AskForTextScreen: View {
	struct Data {
		var text: String
		var title: String
		var message: String?
		var timeout: Double?
		var timeoutReturnValue: String
		var showCancelButton = true
	}

	@Environment(\.dismiss) private var dismiss
	@State private var text = ""
	@State private var isTimeoutCancelled = false
	private let data: Data

	init(data: Data) {
		self.data = data
		self._text = .init(wrappedValue: data.text)
	}

	var body: some View {
		VStack {
			TextField("", text: $text)
				.lineLimit(4, reservesSpace: true) // Has no effect. (iOS 16.0)
			Button("Done") {
				XPasteboard.general.stringForCurrentHostOnly = text
				ShortcutsApp.open()
			}
			if data.showCancelButton {
				Button("Cancel", role: .cancel) {
					ShortcutsApp.open()
				}
			}
		}
			.onChange(of: text) { _ in
				isTimeoutCancelled = true
			}
			.task {
				guard let timeout = data.timeout else {
					return
				}

				try? await Task.sleep(seconds: timeout)

				guard !isTimeoutCancelled else {
					return
				}

				timeoutAction()
			}
	}

	@MainActor
	private func timeoutAction() {
		// TODO: Report to Apple: Dismiss should work inside an alert.
		dismiss()

		XPasteboard.general.stringForCurrentHostOnly = data.timeoutReturnValue

		// TODO: Handle macOS.
		ShortcutsApp.open()

		AppState.shared.askForTextData = nil
	}
}

//struct AskForTextScreen_Previews: PreviewProvider {
//	static var previews: some View {
//		AskForTextScreen()
//	}
//}
