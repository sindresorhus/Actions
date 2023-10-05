import SwiftUI

struct WriteTextScreen: View {
	struct Data: Identifiable {
		var title: String?
		let text: String

		var id: String { text }
	}

	@Environment(\.dismiss) private var dismiss
	@State private var text: String
	@FocusState private var isTextEditorFocused: Bool
	private let data: Data

	init(data: Data) {
		self.data = data
		self._text = .init(wrappedValue: data.text)
	}

	var body: some View {
		NavigationStack {
			TextEditor(text: $text)
				.font(.largeBody)
				.lineSpacing(6)
				.focused($isTextEditorFocused)
				.padding() // TODO: Use `.safeAreaInset()` when it works with `TextEditor`. (macOS 12.0.1)
				.navigationTitle(data.title ?? "Text Editor")
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				#if canImport(UIKit)
				.navigationBarTitleDisplayMode(.inline)
				#endif
				.toolbar {
					ToolbarItem(placement: .confirmationAction) {
						Button("Done") {
							text.copyToPasteboard(currentHostOnly: true)
							openShortcuts()
						}
							// We disable it if it's the "Write" type and there is no text.
							.disabled(data.text.isEmpty && text.isEmptyOrWhitespace)
					}
					ToolbarItem(placement: .cancellationAction) {
						Button("Cancel") {
							if let text = data.text.nilIfEmptyOrWhitespace {
								text.copyToPasteboard(currentHostOnly: true)
							} else {
								XPasteboard.general.prepareForNewContents(currentHostOnly: true)
							}

							openShortcuts()
						}
					}
				}
				#if os(macOS)
				.frame(minWidth: 600, minHeight: 420)
				#endif
				.task {
					isTextEditorFocused = true
				}
		}
	}

	@MainActor
	private func openShortcuts() {
		ShortcutsApp.open()
		dismiss()

		#if os(macOS)
		DispatchQueue.main.async {
			SSApp.quit()
		}
		#endif
	}
}
