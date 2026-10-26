---
id: list-styles
title: List styles
platforms: [macOS]
availability: macOS 10.15+, Collapsible sections macOS 14.0+
docs: https://developer.apple.com/documentation/swiftui/liststyle.md
hig: https://developer.apple.com/design/human-interface-guidelines/lists-and-tables.md
---

# List styles

Sidebar, inset, and bordered lists, with rows people click to select, one or many.

Also called: List, listStyle, sidebar, inset, bordered, plain, NSTableView, source list, alternatingRowBackgrounds, zebra stripes.

## Contents

- Use when
- Don't use when
- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- A `List` shows rows in one column and handles selection and scrolling for you.
- Its style decides the look: `.sidebar` for the source list on the leading edge of a window, `.inset` for content with rounded selection, and `.bordered` for a boxed list inside a form or settings pane.

## Don't use when

- For several columns of data, use a [Table](table.md).
- For a hierarchy, see [Outline lists](outline.md).

## Default code

```swift
@State private var selection: String?
private let fruits = ["Apple", "Banana", "Cherry"]

List(fruits, id: \.self, selection: $selection) { fruit in
    Text(fruit)
}
```

**Note:** `selection:` takes an optional for one row at a time, or a `Set` for several. Without it, rows don't highlight when clicked.

## Rules

- **Keep row text short.** Rows are for scanning. Show a title, and put the long text in a detail view people open from the row.
- **Keep the selected row highlighted when it drives a detail view.** A lasting highlight shows people where they are. A list of options can instead flash the row and show a checkmark.
- **Show at most two levels in a sidebar.** Deeper hierarchies are hard to follow there. Add a content column between the sidebar and the detail instead.
- **Let the sidebar's icons follow the accent color.** People pick an accent color for every app. Save fixed colors for the few icons that need to stand out.

## Pitfalls

- **Selection on the Mac needs no edit mode.** Bind `selection:` to a `Set` and people can select several rows right away, with no Edit button.
- **Sidebar section headers can collapse.** In the `.sidebar` style, people can hide a section from its header.

## Key APIs

- `List(_:selection:rowContent:)`: Rows from data, optionally selectable.
- `.listStyle(.sidebar)`: A source list with collapsible sections.
- `.listStyle(.inset)`: Content rows with inset selection.
- `.listStyle(.bordered)`: A boxed list for forms and panes.
- `.alternatingRowBackgrounds()`: Stripes every other row.
- `.onDeleteCommand(perform:)`: Runs on the Delete key or Delete command.
- `.contextMenu(forSelectionType:)`: A menu and double-click for selected rows.

## Variants

### A sidebar with collapsible sections

`.listStyle(.sidebar)` gives the source list look, `Section(isExpanded:)` lets people fold a section, and `.badge` shows a count.

```swift
@State private var selection: String? = "Inbox"
@State private var showsFavorites = true
@State private var showsTags = true

List(selection: $selection) {
    Section("Favorites", isExpanded: $showsFavorites) {
        Label("Inbox", systemImage: "tray")
            .badge(12)
            .tag("Inbox")
        Label("Flagged", systemImage: "flag")
            .tag("Flagged")
    }
    Section("Tags", isExpanded: $showsTags) {
        Label("Work", systemImage: "tag")
            .tag("Work")
        Label("Family", systemImage: "tag")
            .tag("Family")
    }
}
.listStyle(.sidebar)
.frame(width: 220, height: 240)
```

### A bordered list with add and remove buttons

Use `.listStyle(.bordered)` for a short list in a settings pane, with `+` and `−` buttons below and `.onDeleteCommand` for the Delete key.

```swift
struct BlockedSenders: View {
    @State private var blocked = ["spam@example.com", "deals@example.net"]
    @State private var selection: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List(blocked, id: \.self, selection: $selection) { Text($0) }
                .listStyle(.bordered)
                .alternatingRowBackgrounds()
                .onDeleteCommand { removeSelected() }
            HStack(spacing: 0) {
                Button("Add", systemImage: "plus") {
                    blocked.append("new@example.com")
                }
                Button("Remove", systemImage: "minus") { removeSelected() }
                    .disabled(selection == nil)
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .padding(4)
        }
        .frame(width: 280, height: 180)
    }

    private func removeSelected() {
        blocked.removeAll { $0 == selection }
        selection = nil
    }
}
```

### Select several, and double-click to open

Bind `selection:` to a `Set` for multiple selection, and `.contextMenu(forSelectionType:)` adds a menu plus a `primaryAction` for double-click.

```swift
@State private var notes = ["Groceries", "Packing list", "Book ideas"]
@State private var selection: Set<String> = []
@Environment(\.openWindow) private var openWindow

List(notes, id: \.self, selection: $selection) { note in
    Text(note)
}
.contextMenu(forSelectionType: String.self) { items in
    Button("Open") { }
    Button("Delete", role: .destructive) {
        notes.removeAll { items.contains($0) }
    }
} primaryAction: { items in
    for item in items {
        openWindow(value: item)
    }
}
```

**Note:** On the Mac, a single click selects a row and a double click runs the primary action. Opening a window this way needs a `WindowGroup(for: String.self)` scene in your app.

## Related

[table](table.md), [outline](outline.md), [navigation-split-view](navigation-split-view.md), [context-menu](context-menu.md)
