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

- [Dive into App Intents - WWDC2022](https://developer.apple.com/videos/play/wwdc2022/10032/)
- [Shortcuts - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/technologies/siri/shortcuts-and-suggestions)

### Creating the action

- Open the Xcode project.
- Decide whether the action should reside in the intents extension or the app. Prefer the intents extension. Generally, only actions requiring significant memory or ones that open the main app should be in the app target.
- Create a new file in the `Actions` folder (in the correct target) named after the intent you are creating.
	+ The file should be alphabetically sorted in Xcode.
- Keep the naming, description, and code style consistent with existing actions.
- Implement the logic. Try to create reusable extensions whenever it makes sense.
- Run the “Actions” target, which will open the app and then open the Shortcuts app. You can then test out your work.
- Add the action to `readme.md` and `app-store-description.txt`.

### General

- Make sure you test on both macOS and iOS before submitting a pull request.
- Make sure linting passes.
- Use tab-indentation.

### Pull request

- The pull request should be titled ``Add `Get Foo` action`` where `Get Foo` is the name of the action.
- Include a `Fixes #12` notation in the pull request description referencing the related issue.
