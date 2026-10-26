---
description: Review SwiftUI changes with the SwiftUI for Humans linter and checklist, and fix what it finds
argument-hint: "[paths or deployment target, e.g. Sources/ iOS 17]"
---

Review the SwiftUI code in $ARGUMENTS. With no arguments, review the Swift files changed on this branch (`git diff --name-only` against the default branch, plus uncommitted changes).

Follow the `swiftui-review` skill:

1. Find the deployment target in the project (the Xcode project's `IPHONEOS_DEPLOYMENT_TARGET` / `MACOSX_DEPLOYMENT_TARGET`, or `Package.swift` platforms) unless the arguments name one.
2. Run the linter on those files:

   ```sh
   python3 "${CLAUDE_PLUGIN_ROOT}/skills/swiftui-review/scripts/check_swift.py" --target "<platform> <version>" <paths>
   ```

3. Fix every `error` and `warning`, and judge each `info` and `hig` finding. Use `// check-swift:ignore <id>` with a reason only for deliberate exceptions.
4. Work through `${CLAUDE_PLUGIN_ROOT}/skills/swiftui-review/references/review-checklist.md` for what the linter can't see.
5. Build, and run the linter again until it's clean.
6. Finish with a short report: what you fixed, what you left on purpose and why, and anything a person should decide.

For a design-only critique of a screen, hand it to the `hig-reviewer` subagent.
