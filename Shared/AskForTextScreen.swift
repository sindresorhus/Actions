import SwiftUI

struct AskForTextScreen: View {
	struct Data {
		var text: String
		var title: String
		var message: String?
		var timeout: Double?
		var timeoutReturnValue: String
		var showCancelButton = true
		var type: InputTypeAppEnum
	}

	@Environment(\.dismiss) private var dismiss
	@State private var text = ""
	@State private var isTimeoutCancelled = false
	@FocusState private var isFocused: Bool
	private let data: Data

	init(data: Data) {
		self.data = data
		self._text = .init(wrappedValue: data.text)
	}

	var body: some View {
		VStack {
			Button("Done") {
				XPasteboard.general.stringForCurrentHostOnly = text
				openShortcuts()
			}
				// TODO: If we disable the button and then enable it, it loses its action. (iOS 17.1)
				// TODO: Disable the button if not valid email, URL, etc, when using the types.
//				.disabled(text.isEmptyOrWhitespace)
			if data.showCancelButton {
				Button("Cancel", role: .cancel) {
					openShortcuts()
				}
			}
			// It's important that this is last as otherwise it shows only two "Done" buttons. (macOS 13.0)
			TextField("", text: $text)
				.lineLimit(4, reservesSpace: true) // Has no effect. (iOS 17.1)
				.focused($isFocused)
				.textContentType(data.type.toContentType)
				.autocorrectionDisabled(data.type.shouldDisableAutocorrectionAndAutocapitalization)
				#if canImport(UIKit)
				.keyboardType(data.type.toKeyboardType ?? .default)
				.textInputAutocapitalization(data.type.shouldDisableAutocorrectionAndAutocapitalization ? .never : nil)
				#endif
		}
			.onChange(of: text) {
				isTimeoutCancelled = true
			}
			.task {
				#if os(macOS)
				NSApp.activate(ignoringOtherApps: true)
				#endif

				// TODO: Does not work. (macoS 14.1)
				isFocused = true

				guard let timeout = data.timeout else {
					return
				}

				try? await Task.sleep(for: .seconds(timeout))

				guard !isTimeoutCancelled else {
					return
				}

				timeoutAction()
			}
	}

	@MainActor
	private func timeoutAction() {
		XPasteboard.general.stringForCurrentHostOnly = data.timeoutReturnValue
		openShortcuts()
	}

	@MainActor
	private func openShortcuts() {
		dismiss()
		ShortcutsApp.open()

		#if os(macOS)
		DispatchQueue.main.async {
			SSApp.quit()
		}
		#endif
	}
}

//#Preview {
//	AskForTextScreen()
//}
