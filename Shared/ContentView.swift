import SwiftUI

struct ContentView: View {
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	var body: some View {
		VStack(spacing: 16) {
			Spacer()
			VStack(spacing: 0) {
				Image("AppIconForView")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(height: 200)
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
				Task {
					await openShortcutsApp()
				}
			}
				.buttonStyle(.borderedProminent)
				.controlSize(.large)
				.keyboardShortcut(.defaultAction)
				.padding()
			Spacer()
			Button("Send Feedback") {
				SSApp.openSendFeedbackPage()
			}
				#if canImport(AppKit)
				.buttonStyle(.link)
				#endif
				// TODO: Make it small again when the app is more mature.
//				.controlSize(.small)
				.controlSize(.large)
		}
			.padding()
			#if canImport(AppKit)
			.padding()
			.padding(.vertical)
			.frame(width: 440)
			.windowLevel(.floating)
			#elseif canImport(UIKit)
			.frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : 540)
			.embedInScrollViewIfAccessibilitySize()
			#endif
			.task {
				#if DEBUG
				await openShortcutsApp()
				#endif
			}
	}

	private func openShortcutsApp() async {
		#if DEBUG
		await ShortcutsApp.open()
		#else
		await ShortcutsApp.createShortcut()
		#endif

		#if canImport(AppKit)
		await SSApp.quit()
		#endif
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
