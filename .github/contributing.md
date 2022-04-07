# Contributing guidelines

## Suggesting a new action

[Submit an idea here.](https://github.com/sindresorhus/Actions/issues/new/choose)

## Submitting a new action

*Submitting an action requires advanced Swift knowledge. I don't have time for low-quality pull requests.*

### Prerequisite

- [Open an issue](https://github.com/sindresorhus/Actions/issues/new/choose) for discussion first.
- The action name must start with a verb.
- One action addition per pull request, unless they are connected.
- Please help review the other open pull requests and action proposals.

#### Resources

- [Meet Shortcuts for macOS - WWDC2021](https://developer.apple.com/videos/play/wwdc2021/10232/)
- [Design great actions for Shortcuts, Siri, and Suggestions - WWDC2021](https://developer.apple.com/videos/play/wwdc2021/10283/)
- [Shortcuts - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/siri/overview/shortcuts-and-suggestions/)
- [Adding User Interactivity with Siri Shortcuts and the Shortcuts App](https://developer.apple.com/documentation/sirikit/adding_user_interactivity_with_siri_shortcuts_and_the_shortcuts_app)
- [Demystifying Siri, Part 2: Creating a Custom Intent](https://andrewgraham.dev/demystifying-siri-part-2-creating-a-custom-intent/)

### Creating the action

- Open the Xcode project, select the `Intents` file, and click the `+` button in the intents editor.
- Keep the naming, description, and checkboxes consistent with existing actions.
- Create a new Swift file in the `IntentsExtension/Actions` directory named the same as the intent title. Make sure it's included in both the macOS and iOS extension targets.
- Add the intent to the `IntentHandler` file.
- Implement the logic. Try to create reusable extensions whenever it makes sense.
- Run the “Actions (macOS)” target, which will open the app and then open the Shortcuts app. You can then test out your work. If you need to debug, run the `IntentsExtension (macOS)` target instead and use `Shortuts` as the target app.
- Add the action to `readme.md` and `app-store-description.txt`.

### General

- Make sure you test on both macOS and iOS before submitting a pull request.
- Make sure linting passes.
- Use tab-indentation.

### Pull request

- The pull request should be titled ``Add `Get Foo` action`` where `Get Foo` is the name of the action.
- Include a `Fixes #12` notation in the pull request description referencing the related issue.
