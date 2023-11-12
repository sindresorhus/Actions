import SwiftUI

struct SettingsScreen: View {
	@Environment(\.dismiss) private var dismiss
	@AppStorage(Constants.defaultsKey_sendCrashReports, store: Constants.sharedDefaults) private var sendCrashReports = true

	var body: some View {
		NavigationStack {
			Form {
				Toggle("Send anonymized crash reports to the developer", isOn: $sendCrashReports)
			}
				.navigationTitle("Settings")
				.formStyle(.grouped)
				#if os(macOS)
				.frame(width: 400, height: 200)
				.windowLevel(.modalPanel)
				#else
				.contentMargins(.top, 16)
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
