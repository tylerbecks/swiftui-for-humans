---
id: outline
title: Outline lists
platforms: [macOS]
availability: macOS 11.0+, Outline Table macOS 14.0+
docs: https://developer.apple.com/documentation/swiftui/outlinegroup.md
hig: https://developer.apple.com/design/human-interface-guidelines/outline-views.md
---

# Outline lists

Folders inside folders: rows with disclosure triangles that open to show their children.

Also called: OutlineGroup, outline view, NSOutlineView, tree, tree view, hierarchy, nested list, children, List children, disclosure triangle.

## Contents

- Use when
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- Give a `List` tree-shaped data and a key path to each item's children, and it draws a disclosure triangle on every row that has some.
- People open and close branches, like folders in Finder's list view.
- Use `List(_:children:)` for a whole outline, `OutlineGroup` to put a tree inside one section of a list, and `Table(_:children:)` when each row also needs columns.

## Built from

List(files, children: \.children)
└── Label(file.name)
    └── (children, when expanded)

## Rules

- **Show the hierarchy in the first column only.** Indent and put triangles in the first column. The other columns hold details about each item, like its size or date.
- **Use a table when nothing nests.** Triangles on data that has no children only add clutter. A flat collection belongs in a [table](table.md) or list.
- **Remember what people expanded.** If someone opened three folders to reach a file, show it that way next time instead of making them dig again.
- **Give every column of a multicolumn outline a heading.** Use short nouns without punctuation, so people know what each value is.
- **Consider a search field for a long outline.** When the outline is the main part of the window, a search field in the toolbar helps people find a value fast.

## Pitfalls

- **`children` decides which rows get a triangle.** A row whose children are `nil` is a leaf. An empty array still shows a triangle, like an empty folder.
- **Branches start closed.** Every branch `OutlineGroup` builds begins collapsed. To reopen what people had open last time, track expansion yourself, as in the last example.

**Important:** `children` must be optional. Leaves return `nil`; returning `[]` for them shows a triangle that opens to nothing.

## Key APIs

- `List(_:children:rowContent:)`: A whole list built from a tree.
- `OutlineGroup(_:children:)`: A tree inside a list or section.
- `Table(_:children:columns:)`: An outline with columns, like Finder.
- `DisclosureGroup(isExpanded:)`: One branch whose state you control.
- `DisclosureTableRow`: A table row that opens to more rows.

## Variants

### Usage

```swift
struct FileNode: Identifiable {
    let name: String
    var children: [FileNode]? = nil
    var id: String { name }
}

let files = [
    FileNode(name: "Documents", children: [
        FileNode(name: "Report.pdf"),
    ]),
    FileNode(name: "Notes.txt"),
]

List(files, children: \.children) { file in
    Label(file.name, systemImage: file.children == nil ? "doc" : "folder")
}
```

### A file tree with List(children:)

Pass the tree and the key path to each item's children, and add `selection:` so people can click a row at any depth.

```swift
@State private var selection: FileNode.ID?

List(FileNode.samples, children: \.children, selection: $selection) { file in
    Label(file.name, systemImage: file.symbol)
}
.frame(width: 280, height: 220)
```

**Note:** The examples on this page use the `FileNode` from Usage, plus a `symbol` name, a `totalSize`, and some `samples`.

### A tree inside one sidebar section

`OutlineGroup` builds the same triangles inside a `Section`, so a sidebar can mix flat rows with a tree.

```swift
@State private var selection: FileNode.ID?

List(selection: $selection) {
    Section("Favorites") {
        Label("Recents", systemImage: "clock")
        Label("Shared", systemImage: "person.2")
    }
    Section("Locations") {
        OutlineGroup(FileNode.samples, children: \.children) { file in
            Label(file.name, systemImage: file.symbol)
        }
    }
}
.listStyle(.sidebar)
.frame(width: 240, height: 260)
```

### Finder-style: an outline with columns

`Table(_:children:)` puts the tree in the first column and details in the others, like Finder's list view.

```swift
@State private var selection = Set<FileNode.ID>()

Table(FileNode.samples, children: \.children, selection: $selection) {
    TableColumn("Name") { file in
        Label(file.name, systemImage: file.symbol)
    }
    TableColumn("Size") { file in
        Text(file.totalSize, format: .byteCount(style: .file))
            .foregroundStyle(.secondary)
    }
    .width(90)
}
.frame(width: 420, height: 220)
```

### Expansion you keep track of

Build the tree from `DisclosureGroup(isExpanded:)` rows and keep the open ids in a `Set` you can save, to reopen the outline as people left it.

```swift
struct FileTree: View {
    let nodes: [FileNode]
    @Binding var expanded: Set<FileNode.ID>

    var body: some View {
        ForEach(nodes) { node in
            if let children = node.children {
                DisclosureGroup(isExpanded: Binding {
                    expanded.contains(node.id)
                } set: { isOpen in
                    if isOpen { expanded.insert(node.id) } else { expanded.remove(node.id) }
                }) {
                    FileTree(nodes: children, expanded: $expanded)
                } label: {
                    Label(node.name, systemImage: node.symbol)
                }
            } else {
                Label(node.name, systemImage: node.symbol)
            }
        }
    }
}

@State private var expanded: Set<FileNode.ID> = ["Documents"]

List {
    FileTree(nodes: FileNode.samples, expanded: $expanded)
}
```

## Related

[list-styles](list-styles.md), [table](table.md), [group-box](group-box.md)
