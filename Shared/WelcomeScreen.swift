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
			#if canImport(AppKit)
			Link("Want even more actions?", destination: "https://github.com/sindresorhus/Actions#looking-for-more")
				.controlSize(.small)
			#endif
			Button("Send Feedback") {
				SSApp.openSendFeedbackPage()
			}
				#if canImport(AppKit)
				.buttonStyle(.link)
				#endif
				// TODO: Make it small again when the app is more mature.
//				.controlSize(.small)
				.controlSize(.large)
				.padding(.bottom, 10) // TODO: Remove this at some point.
				.dynamicTypeSize(...(.accessibility4))
		}
			.padding()
			#if canImport(AppKit)
			.padding()
			.padding(.vertical)
			#elseif canImport(UIKit)
			.frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : 540)
			.if(Device.hasSmallScreen) {
				$0.embedInScrollView()
			} else: {
				$0.embedInScrollViewIfAccessibilitySize()
			}
			#endif
			.task {
				#if DEBUG
					#if canImport(AppKit)
					// Don't quit app when using in-app intent.
					if NSApp.activationPolicy() == .regular {
						openShortcutsApp()
					}
					#elseif canImport(UIKit)
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

		#if canImport(AppKit)
		SSApp.quit()
		#endif
	}
}

struct WelcomeScreen_Previews: PreviewProvider {
	static var previews: some View {
		WelcomeScreen()
	}
}
