import SwiftUI

struct WelcomeScreen: View {
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	var body: some View {
		VStack(spacing: 16) {
			Spacer()
			VStack(spacing: 0) {
				AppIcon()
					.frame(height: Device.hasSmallScreen ? 140 : 200)
				Text(SSApp.name)
					.font(.system(size: 40, weight: .heavy))
					.actuallyHiddenIfAccessibilitySize()
			}
				.accessibilityHidden(true)
				.padding(.top, OS.current == .macOS ? -50 : -28)
			VStack {
				Text("This app has no user-interface. It provides a bunch of useful actions that you can use when creating shortcuts.")
					.multilineText()
					.padding()
				Text("You \(SSApp.isFirstLaunch ? "" : "may ")have to restart your device for the actions to show up in the Shortcuts app.")
					.font(.system(SSApp.isFirstLaunch ? .title2 : .body))
					.bold()
					.padding(.bottom)
				Text(OS.current == .iOS ? "Open the Shortcuts app, tap the “Apps” tab in the action picker, and then tap the “Actions” app." : "Open the Shortcuts app, click the “Apps” tab in the right sidebar, and then click the “Actions” app.")
					.multilineText()
					.secondaryTextStyle()
					.padding(.horizontal)
			}
				.lineSpacing(1.5)
				.multilineTextAlignment(.center)
				.padding(.top, -8)
			Button(dynamicTypeSize.isAccessibilitySize ? "Shortcuts" : "Open Shortcuts") {
				openShortcutsApp()
			}
				.buttonStyle(.borderedProminent)
				.controlSize(.large)
				.keyboardShortcut(.defaultAction)
				.padding()
				.dynamicTypeSize(...(Device.hasSmallScreen ? .accessibility3 : .accessibility4))
			Spacer()
			#if os(macOS)
			Link("Want even more actions?", destination: "https://github.com/sindresorhus/Actions#looking-for-more")
				.controlSize(.small)
			#endif
			Button("Send Feedback") {
				SSApp.openSendFeedbackPage()
			}
				#if os(macOS)
				.buttonStyle(.link)
				#endif
				.controlSize(.small)
				.dynamicTypeSize(...(.accessibility4))
		}
			.padding()
			#if os(macOS)
			.padding()
			.padding(.vertical)
			#else
			.frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : 540)
			.if(Device.hasSmallScreen) {
				$0.embedInScrollView()
			} else: {
				$0.embedInScrollViewIfAccessibilitySize()
			}
			#endif
			.task {
				#if DEBUG
					#if os(macOS)
					// Don't quit app when using in-app intent.
					if NSApp.activationPolicy() == .regular {
						openShortcutsApp()
					}
					#else
					openShortcutsApp()
					#endif
				#endif
			}
	}

	@MainActor
	private func openShortcutsApp() {
		#if DEBUG
		ShortcutsApp.open()
		#else
		ShortcutsApp.createShortcut()
		#endif

		#if os(macOS)
		SSApp.quit()
		#endif
	}
}

#Preview {
	WelcomeScreen()
}
