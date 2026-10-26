---
id: welcome-window
title: Welcome window
platforms: [macOS]
availability: macOS 15.0+
docs: https://developer.apple.com/documentation/swiftui/scene/defaultlaunchbehavior(_:).md
hig: https://developer.apple.com/design/human-interface-guidelines/launching.md
---

# Welcome window

The window a document app shows at launch, with New, Open, and recent files.

## Built from

Window("Welcome to Notes", id:)
├── .windowStyle(.hiddenTitleBar)
├── .defaultLaunchBehavior(.presented)
└── WelcomeView
    ├── icon, name, version
    ├── New and Open buttons
    └── List (recent documents)

## Rules

- **Put people back where they were.** If documents were open when people quit, reopen them instead of greeting them again. With `.presented`, the welcome window shows only when nothing comes back.
- **Offer recent files next to Open.** Most of the time people want what they had yesterday. A list of recent documents saves a trip through the open panel.
- **Get out of the way fast.** People want to start right away. Keep the window to a few ways in, so they can pick one and get to work.

## Pitfalls

- **It appears only when nothing is restored.** With `.defaultLaunchBehavior(.presented)`, the welcome window shows at launch when no document windows come back, and when people click the Dock icon with no windows open.
- **Recent files come from AppKit.** SwiftUI has no list of recent documents, so the block reads AppKit's `NSDocumentController.shared.recentDocumentURLs`.

## Key APIs

`Window(_:id:)`, `.defaultLaunchBehavior(.presented)`, `.restorationBehavior(.disabled)`, `.windowStyle(.hiddenTitleBar)`, `.windowBackgroundDragBehavior`, `\.newDocument`, `\.openDocument`, `\.dismissWindow`

More variants, left out to keep this file short: Icon, actions, and recent files. Apple's docs: https://developer.apple.com/documentation/swiftui/scene/defaultlaunchbehavior(_:).md

## Related

[document-editor](document-editor.md), [window](window.md), [window-style](window-style.md), [opening-windows](opening-windows.md), [onboarding](onboarding.md)
