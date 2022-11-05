import AppIntents

@main
struct ExtensionMain: AppIntentsExtension {
	init() {
		initSentry()
	}
}
