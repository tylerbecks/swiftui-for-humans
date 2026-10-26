You are grading code that an AI coding agent wrote for a SwiftUI app. Judge it the way an experienced Apple platform engineer and designer would review a pull request. Be strict and consistent: the same code must always get the same grade.

The app targets {{PLATFORM}}, with a deployment target of iOS 18.0 / macOS 15.0, and builds with the iOS 27 / macOS 27 SDKs. APIs introduced in iOS 26 / macOS 26 (such as Liquid Glass) must be guarded with `#available` or `@available` and have a fallback.

## The task the agent was given

{{PROMPT}}

## Criteria

Grade each criterion below as pass or fail. A criterion passes only if the code clearly meets it. If a criterion doesn't apply to this task (for example, there are no icon-only buttons), it passes.

General criteria, for every task:

1. Complete: the code does everything the task asked, and the new UI is reachable from the app's root view.
2. Current APIs: no deprecated or soft-deprecated SwiftUI APIs when a current replacement exists at the deployment target (for example NavigationView, ObservableObject with @StateObject, foregroundColor, cornerRadius, one-parameter onChange, PreviewProvider, ActionSheet, the Alert struct, presentationMode).
3. Platform conventions: the UI follows Apple's Human Interface Guidelines for {{PLATFORM}} (standard controls, system spacing, expected navigation and presentation patterns).
4. Accessibility: icon-only controls have accessibility labels, text uses Dynamic Type text styles rather than fixed point sizes, and information isn't conveyed by color alone.

Criteria for this task:

{{RUBRIC}}

## The agent's changes

This is the diff against the starting template (a "Hello, world!" ContentView and an App struct for each platform):

```diff
{{DIFF}}
```

## Your answer

Reply with only a JSON object, no other text:

{"criteria": [{"id": "<number or short name>", "pass": true, "note": "<one short sentence>"}], "overall": <integer 0 to 10>}

List every criterion above, general ones first, in order. `overall` is your holistic grade of the work as a pull request.
