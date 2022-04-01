import SwiftUI
import FuzzyFind

struct ChooseFromListScreen: View {
	struct Data: Identifiable {
		var list: [String]
		var title: String?
		var selectMultiple: Bool
		var selectAllInitially: Bool
		var allowCustomItems: Bool
		var timeout: TimeInterval?
		var timeoutReturnValue: ChooseFromListTimeoutValue

		var id: String { "ChooseFromListExtended" }
	}

	@Environment(\.dismiss) private var dismiss
	@State private var searchText = ""
	@State private var singleSelection: String?
	@State private var multipleSelection = Set<String>()
	@State private var customElements = [String]()
	@State private var isAddItemScreenPresented = false

	let data: Data

	var body: some View {
		VStack(spacing: 0) {
			#if canImport(AppKit)
			header
			#endif
			list
				#if canImport(AppKit)
				.listStyle(.inset(alternatesRowBackgrounds: true))
				#endif
		}
			.navigationTitle(title)
			#if canImport(UIKit)
			.navigationBarTitleDisplayMode(.inline)
			.environment(\.editMode, .constant(data.selectMultiple ? .active : .inactive))
			#endif
			.sheet(isPresented: $isAddItemScreenPresented) {
				AddItemScreen(isMultiple: data.selectMultiple) {
					if data.selectMultiple {
						customElements.prepend($0)
						multipleSelection.insert($0)
					} else {
						finishSingleSelection($0)
					}
				}
			}
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					if data.selectMultiple {
						Button("Done") {
							guard let selection = multipleSelection.nilIfEmpty else {
								return
							}

							XPasteboard.general.stringsForCurrentHostOnly = elements.filter { selection.contains($0) }
							openShortcuts()
						}
							.disabled(multipleSelection.isEmpty)
					}
				}
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						XPasteboard.general.prepareForNewContents(currentHostOnly: true)
						openShortcuts()
					}
				}
				ToolbarItem {
					if data.allowCustomItems {
						if OS.current == .macOS, !data.selectMultiple {
							Button("Use Custom Item") {
								isAddItemScreenPresented = true
							}
						}
						if data.selectMultiple {
							Button("Add Item", systemImage: "plus") {
								isAddItemScreenPresented = true
							}
								.labelStyle(.iconOnly)
								.keyboardShortcut("n")
						}
					}
				}
			}
			.embedInNavigationViewIfNotMacOS()
			#if canImport(AppKit)
			.frame(width: 440, height: 560)
			.windowLevel(.floating)
			#else
			.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
			#endif
			.onChange(of: singleSelection) {
				guard let selection = $0 else {
					return
				}

				finishSingleSelection(selection)
			}
			.task {
				if data.selectMultiple, data.selectAllInitially {
					multipleSelection = Set(elements)
				}

				#if canImport(UIKit)
				UIView.setAnimationsEnabled(true)
				#endif
			}
			.task {
				guard let timeout = data.timeout else {
					return
				}

				// TODO: Use `Task.sleep` when it accepts a duration.
				delay(seconds: timeout) {
					timeoutAction()
				}
			}
	}

	@ViewBuilder
	private var list: some View {
		if data.selectMultiple {
			#if canImport(AppKit)
			List(searchResults, id: \.self) {
				Toggle($0.trimmed.firstLine, isOn: $multipleSelection.contains($0))
					.lineLimit(1)
					.padding()
					.help($0)
			}
			#else
			List(searchResults, id: \.self, selection: $multipleSelection) {
				Text($0.trimmed.firstLine)
					.lineLimit(2)
					.tag($0)
			}
			#endif
		} else {
			#if canImport(AppKit)
			List(searchResults, id: \.self, selection: $singleSelection) {
				Text($0.trimmed.firstLine)
					.tag($0)
					.lineLimit(1)
					.padding()
					.help($0)
			}
			#else
			Form {
				if data.allowCustomItems {
					Section {
						NavigationLink("Custom Item") {
							AddItemScreen(
								isMultiple: false,
								isUsingNavigationLink: true
							) {
								finishSingleSelection($0)
							}
						}
					}
				}
				// Note to self: I am not using a `Picker` with inline style as I want the navigation link style for the items.
				List(searchResults, id: \.self) { element in
					Button(element.trimmed.firstLine) {
						singleSelection = element
					}
						// We cannot do this on macOS as macOS cannot have a `NavigationView` with a single column. (macOS 12.3)
						.buttonStyle(.navigationLink)
						.lineLimit(2)
				}
			}
			#endif
		}
	}

	#if canImport(AppKit)
	private var header: some View {
		VStack(spacing: 0) {
			Text(title)
				.font(.headline)
				.padding()
				.padding(.bottom, -8)
			// TODO: `.searchable` does not work on macOS when used in a sheet. Open FB about this if not if not fixed in macOS 13.
			SearchField(text: $searchText, placeholder: "Search")
				.padding()
				.onExitCommand {
					searchText = ""
				}
		}
	}
	#endif

	private var title: String {
		data.title
			?? (data.selectMultiple ? "Select Multiple Items" : "Select One Item")
	}

	private var elements: [String] {
		(customElements + data.list)
			.removingDuplicates()
			.filter { !$0.isEmptyOrWhitespace }
	}

	private var searchResults: [String] {
		fuzzyFind(
			queries: [searchText],
			inputs: elements.map { $0.trimmed.firstLine }
		)
			.map(\.asString)
	}

	@MainActor
	private func finishSingleSelection(_ selection: String) {
		XPasteboard.general.stringForCurrentHostOnly = selection
		openShortcuts()
	}

	@MainActor
	private func timeoutAction() {
		let item = { () -> String? in
			switch data.timeoutReturnValue {
			case .unknown, .nothing:
				return nil
			case .firstItem:
				return elements.first
			case .lastItem:
				return elements.last
			case .randomItem:
				return elements.randomElement()
			}
		}()

		XPasteboard.general.stringForCurrentHostOnly = item
		openShortcuts()
	}

	@MainActor
	private func openShortcuts() {
		ShortcutsApp.open()
		dismiss()

		#if canImport(AppKit)
		DispatchQueue.main.async {
			SSApp.quit()
		}
		#endif
	}
}

private struct AddItemScreen: View {
	@Environment(\.dismiss) private var dismiss
	@State private var text = ""
	@FocusState private var isTextFieldFocused: Bool

	let isMultiple: Bool
	var isUsingNavigationLink = false
	let onComplete: @MainActor (String) -> Void

	var body: some View {
		Form {
			TextField("", text: $text)
				.controlSize(.large)
				.focused($isTextFieldFocused)
				.padding()
		}
			.navigationTitle(isMultiple ? "Add Item" : "Custom Item")
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button(isMultiple ? "Add" : "Done") {
						add()
					}
						.disabled(text.isEmpty)
				}
				ToolbarItem(placement: .cancellationAction) {
					if !isUsingNavigationLink {
						Button("Cancel") {
							dismiss()
						}
					}
				}
			}
			.onSubmit {
				guard !text.isEmpty else {
					return
				}

				add()
			}
			.submitLabel(.done)
			.if(!isUsingNavigationLink) {
				$0.embedInNavigationViewIfNotMacOS()
			}
			#if canImport(AppKit)
			.frame(width: 300, height: 100)
			#endif
			.task {
				// It does not focus with this. (iOS 15.4)
				delay(seconds: 0.5) {
					isTextFieldFocused = true
				}
			}
	}

	@MainActor
	private func add() {
		dismiss()
		onComplete(text)
	}
}
