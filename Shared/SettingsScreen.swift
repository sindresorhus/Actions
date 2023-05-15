import SwiftUI
import SimpleKeychain

struct SettingsScreen: View {
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationStack {
			Form {
				OpenAIAPITokenSetting()
			}
				.formStyle(.grouped)
				#if os(macOS)
				.frame(width: 400, height: 200)
				.windowLevel(.modalPanel)
				#else
				.toolbar {
					ToolbarItem(placement: .confirmationAction) {
						Button("Done") {
							dismiss()
						}
					}
				}
				#endif
		}
			.presentationDetents([.medium])
	}
}

struct SettingsScreen_Previews: PreviewProvider {
	static var previews: some View {
		SettingsScreen()
	}
}

private struct OpenAIAPITokenSetting: View {
	@State private var token = ""
	@State private var error: Error?
	@State private var keychain = SimpleKeychain(synchronizable: true)
	@FocusState private var isFocused

	var body: some View {
		Section {
			HStack {
				TextField("Key", text: $token)
					.focused($isFocused)
					.alert(error: $error)
					.task {
						do {
							guard try keychain.hasItem(forKey: Constants.keychainKey_openAI) else {
								return
							}

							token = try keychain.string(forKey: Constants.keychainKey_openAI)
						} catch {
							self.error = error
						}
					}
					// Neither `onChange` or `onDisappear` are called on macOS because the settings window views never disappears. (macOS 13.3)
					.onChange(of: isFocused) {
						guard !$0 else {
							return
						}

						save()
					}
					.onDisappear {
						save()
					}
					.debouncingTask(id: token, interval: .seconds(1)) {
						save()
					}
				PasteButton(payloadType: String.self) {
					guard let string = $0.first else {
						return
					}

					token = string
				}
					.labelStyle(.iconOnly)
					.controlSize(.small)
			}
		} header: {
			Text("OpenAI API Key")
		} footer: {
			HStack(spacing: 16) {
				Link("Get API Key", destination: "https://platform.openai.com/account/api-keys")
				Link("API Usage", destination: "https://platform.openai.com/account/usage")
			}
				.controlSize(.small)
		}
	}

	private func save() {
		do {
			try keychain.set(token.trimmed, forKey: Constants.keychainKey_openAI)
		} catch {
			self.error = error
		}
	}
}
