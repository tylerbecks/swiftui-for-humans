---
id: ipad-app-in-window
title: Not an iPad App in a Window
platforms: [macOS]
docs: https://developer.apple.com/documentation/swiftui/navigationsplitview.md
hig: https://developer.apple.com/design/human-interface-guidelines/mac-catalyst.md
reviewed: October 2026
---

# Not an iPad App in a Window

The signs of a port that wasn't adapted to the Mac, and what to do instead.

Also called: port, iPad port, Catalyst app, tab bar on Mac, bottom toolbar, page control, page dots, popover, inspector, sidebar.

## Rules

- **Swap the tab bar for a sidebar.** A split view with a sidebar follows Mac conventions. Each tab becomes a sidebar row, and using a sidebar on iPad too keeps the layout familiar.
- **Move bottom-edge buttons to the toolbar.** Buttons at the bottom of an iPad screen are easy to reach with a thumb. On a Mac, the most important actions belong at the top of the window.
- **Show details in an inspector, not a popover.** There's room beside the content on a Mac, so details can sit next to it instead of covering it.
- **Give paged content Previous and Next buttons.** Swiping between pages needs a trackpad. Buttons also work with a mouse and from the keyboard.
- **Let windows resize.** An iPad app that skips multitasking runs in a fixed-size window on the Mac. Build layouts that grow and shrink with the window.
- **Fix text and artwork size.** In Catalyst's iPad idiom, everything scales down to 77%. In the Mac idiom, text shows at full size and can look too big. Use text styles, not fixed font sizes.

## Pitfalls

- **Gestures still work, but they can't be the only way.** Taps become clicks and pinch still works on a trackpad, but many people use a mouse or the keyboard.
- **The Mac version needs its own icon.** Apple asks for a macOS version of your app icon, in the Mac's rendering style.

## Guide

Whether you start from Mac Catalyst, run your iPad app as is, or rebuild in SwiftUI, the same habits from the iPad give a port away. Apple's advice for Catalyst apps applies to every Mac app: go beyond showing the iPad layout in a Mac window.

The pairs below show several of them. Each Do differs from its Don't in one thing.

## Variants

### Replace a TabView with a split view

On the Mac, `NavigationSplitView` with a `List` in the sidebar does the job a tab bar does on iPad.

```swift
enum TripSection: String, CaseIterable, Identifiable {
    case upcoming, past, shared
    var id: Self { self }
}

struct TripsView: View {
    @State private var section: TripSection? = .upcoming

    var body: some View {
        NavigationSplitView {
            List(TripSection.allCases, selection: $section) { section in
                Label(section.rawValue.capitalized, systemImage: "suitcase")
            }
        } detail: {
            Text(section?.rawValue.capitalized ?? "Choose a section")
        }
    }
}
```

**Note:** Also list the sections in the View menu, so people can switch with the keyboard. A real split view here would take over this window, so the preview is a drawing.

## Related

[native-vs-catalyst](native-vs-catalyst.md), [mac-native-checklist](mac-native-checklist.md), `navigation-split-view` (swiftui-build skill), `toolbar` (swiftui-build skill), `inspector` (swiftui-build skill), `toggle` (swiftui-build skill)
