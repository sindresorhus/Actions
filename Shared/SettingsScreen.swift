import SwiftUI

struct SettingsScreen: View {
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationStack {
			Form {
				// ...
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

#Preview {
	SettingsScreen()
}
