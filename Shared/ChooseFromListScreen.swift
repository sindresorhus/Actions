import SwiftUI
import FuzzyFind

// TODO: Move this to a new `Window`.
struct ChooseFromListScreen: View {
	struct Data: Identifiable {
		var list: [String]
		var title: String?
		var message: String?
		var selectMultiple: Bool
		var selectAllInitially: Bool
		var allowCustomItems: Bool
		var timeout: Duration?
		var timeoutReturnValue: ChooseFromListTimeoutValueAppEnum

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
		NavigationStack {
			VStack(spacing: 0) {
				#if os(macOS)
				header
				#endif
				list
					#if os(macOS)
					.listStyle(.inset(alternatesRowBackgrounds: true))
					#endif
					.safeAreaInset(edge: .top) {
						if let message = data.message {
							Text(message)
								.foregroundStyle(.secondary)
								.fillFrame(.horizontal)
								.padding(.horizontal)
								.padding(.bottom)
								.background(.bar)
						}
					}
			}
				.navigationTitle(title)
				#if canImport(UIKit)
				.navigationBarTitleDisplayMode(.inline)
				.environment(\.editMode, .constant(data.selectMultiple ? .active : .inactive))
				// TODO: I can use this for macOS too, but as of macOS 13.0, there's a bug where the alert get's two buttons called "Add".
				.alert2(
					data.selectMultiple ? "Add Item" : "Custom Item",
					isPresented: $isAddItemScreenPresented
				) {
					AddItemScreen2 { item in
						if data.selectMultiple {
							customElements.prepend(item)
							// TODO: We don't select as it selects two elements instead of just this one. (iOS 16.0)
//							multipleSelection.insert(item)
						} else {
							finishSingleSelection(item)
						}
					}
				}
				#else
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
				#endif
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
				#if os(macOS)
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
				}
				.task {
					guard let timeout = data.timeout else {
						return
					}

					do {
						try await Task.sleep(for: timeout)
						timeoutAction()
					} catch {}
				}
		}
	}

	@ViewBuilder
	private var list: some View {
		if data.selectMultiple {
			#if os(macOS)
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
			// TODO: Use the iOS solution on macOS too. Use `.formStyle(.grouped)`.
			#if os(macOS)
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
						// TODO: Check if I can do this on macOS 13.
						// We cannot do this on macOS as macOS cannot have a `NavigationView` with a single column. (macOS 12.3)
						.buttonStyle(.navigationLink)
						.lineLimit(2)
				}
			}
			#endif
		}
	}

	#if os(macOS)
	private var header: some View {
		// TODO: `.searchable` does not work on macOS when used in a sheet. Open FB about this if not if not fixed in macOS 13.
		SearchField(text: $searchText, placeholder: "Search")
			.padding()
			.onExitCommand {
				searchText = ""
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
			inputs: elements.map(\.trimmed.firstLine)
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
		let item: String? = switch data.timeoutReturnValue {
			case .nothing:
				nil
			case .firstItem:
				elements.first
			case .lastItem:
				elements.last
			case .randomItem:
				elements.randomElement()
			}

		XPasteboard.general.stringForCurrentHostOnly = item
		openShortcuts()
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

private struct AddItemScreen: View {
	@Environment(\.dismiss) private var dismiss
	@State private var text = ""
	@FocusState private var isTextFieldFocused: Bool

	let isMultiple: Bool
	var isUsingNavigationLink = false
	let onCompletion: @MainActor (String) -> Void

	var body: some View {
		NavigationStack {
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
	//			.if(!isUsingNavigationLink) {
	//				$0.embedInNavigationViewIfNotMacOS()
	//			}
				#if os(macOS)
				.frame(width: 300, height: 100)
				#endif
				.task {
					isTextFieldFocused = true
				}
		}
	}

	@MainActor
	private func add() {
		dismiss()
		onCompletion(text)
	}
}

private struct AddItemScreen2: View {
	@State private var text = ""

	let onCompletion: (String) -> Void

	var body: some View {
		TextField("", text: $text)
		Button("Add") {
			onCompletion(text)
			clear()
		}
		Button("Cancel", role: .cancel) {
			clear()
		}
	}

	private func clear() {
		text = "" // TODO: Text is not cleared. It should be. (iOS 16.0)
	}
}
