---
id: navigation-split-view
title: NavigationSplitView
platforms: [iOS, iPadOS, macOS]
availability: iOS 16.0+, macOS 13.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/navigationsplitview.md
hig: https://developer.apple.com/design/human-interface-guidelines/sidebars.md
---

# NavigationSplitView

A sidebar and detail side by side on iPad that collapses into a stack on iPhone.

## Contents

- Use when
- Don't use when
- Default code
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- On macOS
- Related

## Use when

- `NavigationSplitView` owns two or three columns: a sidebar, an optional content list, and a detail.
- On iPad they sit side by side; on iPhone they collapse into one `NavigationStack`, where the sidebar is the first screen and picking a row pushes the detail.
- Use it when your app is organized around a list of sources, like Mail or Notes.

## Don't use when

- For a few top-level sections on iPhone, use [TabView](tab-view.md) instead.

## Default code

```swift
@State private var folder: String?

NavigationSplitView {
    List(["Inbox", "Sent"], id: \.self, selection: $folder) { folder in
        Label(folder, systemImage: "folder")
    }
    .navigationTitle("Mail")
} detail: {
    Text(folder ?? "Pick a folder")
}
```

**Note:** Drive the detail with `List(selection:)`; you don't need `NavigationLink`s. On iPhone, picking a row pushes the detail for you.

## Built from

NavigationSplitView
├── sidebar
│   └── List(selection:)
├── content (optional)
│   └── List(selection:)
└── detail
    └── View for the selection

## Rules

- **Give sidebar items familiar symbols.** An SF Symbol beside each label makes the list faster to scan, and it matches the system apps.
- **Keep the sidebar to two levels.** Deeper hierarchies get hard to follow in one column. Add a content column between the sidebar and the detail instead.
- **Show the sidebar by default.** A hidden sidebar is easy to miss. Let people hide it themselves; iPad already supports the edge swipe.

## Pitfalls

- **Test on both iPhone and iPad.** One piece of code gives you two layouts, and an empty detail state only shows up on iPad.
- **Show an empty state in the detail.** On iPad the detail is visible before anything is selected, so give it a `ContentUnavailableView`.

## Key APIs

`NavigationSplitView { } detail: { }`, `content: { }`, `List(_:selection:)`, `columnVisibility:`, `.navigationSplitViewStyle(_:)`, `.navigationSplitViewColumnWidth(_:)`

## Variants

### Sidebar from an enum

Model the sidebar as an enum, bind `List(selection:)` to it, and `switch` in the detail.

```swift
enum Folder: String, CaseIterable, Identifiable {
    case inbox = "Inbox", drafts = "Drafts", sent = "Sent"
    var id: Self { self }
}

@State private var folder: Folder? = .inbox

NavigationSplitView {
    List(Folder.allCases, selection: $folder) { folder in
        Label(folder.rawValue, systemImage: "folder")
    }
    .navigationTitle("Mail")
} detail: {
    switch folder {
    case .inbox: Text("Inbox")
    case .drafts: Text("Drafts")
    case .sent: Text("Sent")
    case nil: ContentUnavailableView("No Folder", systemImage: "folder")
    }
}
```

**Note:** Starting with a selection, like `.inbox`, fills the detail on iPad. On iPhone the sidebar still shows first.

## On macOS

Two or three columns, where a selection in the sidebar fills the detail.

### Rules

- **Keep the selection highlighted.** The highlight in each column shows how it leads to the detail, so people always know where they are.
- **Let people hide the sidebar, but show it at first.** Offer a toolbar button and View menu commands to hide and show it. Hiding it by default makes it hard to discover.
- **Show at most two levels in a sidebar.** For deeper hierarchies, add a content column between the sidebar and the detail.
- **Keep important things away from the sidebar's bottom.** People often move windows so the bottom edge is off screen.

### Pitfalls

- **The Mac always shows the content column.** In a three-column view, visibility settings can hide the sidebar, but the middle column stays.
- **This app is built on one.** The sidebar beside this page is a `NavigationSplitView` sidebar, with its search field at the top.

### Key APIs

`init(sidebar:detail:)`, `init(sidebar:content:detail:)`, `.navigationSplitViewColumnWidth`, `.toolbar(removing: .sidebarToggle)`

### Variants

#### Usage

```swift
@State private var selection: String?
let mailboxes = ["Inbox", "Drafts", "Sent"]

NavigationSplitView {
    List(mailboxes, id: \.self, selection: $selection) { mailbox in
        Text(mailbox)
    }
} detail: {
    Text(selection ?? "Select a mailbox")
}
```

More variants, left out to keep this file short: Drill down in the detail, Sidebar and detail (macOS), Three columns (macOS), Hide and show the sidebar (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/navigationsplitview.md

## Related

[navigation-stack](navigation-stack.md), [list](list.md), [tab-view](tab-view.md), [split-views](split-views.md), [list-styles](list-styles.md), [outline](outline.md), [toolbar](toolbar.md), [search](search.md), [inspector](inspector.md)
