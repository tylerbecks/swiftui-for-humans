# EvalApp

A SwiftUI app with an iOS target and a macOS target. XcodeGen generates the
Xcode project from `project.yml`.

- `Shared/`: code compiled into both targets. `ContentView` is the root view.
- `iOS/`: the iOS app entry point.
- `macOS/`: the macOS app entry point.

New `.swift` files in these folders are picked up automatically, with no
need to edit `project.yml` or regenerate.

Deployment targets: iOS 18.0 and macOS 15.0. The app builds with Xcode 27
(iOS 27 and macOS 27 SDKs).

To check that your work compiles, run `./build.sh ios` or `./build.sh mac`.
