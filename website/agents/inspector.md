---
id: inspector
title: Inspector
platforms: [macOS]
availability: macOS 14.0+
docs: https://developer.apple.com/documentation/swiftui/view/inspector(ispresented:content:).md
hig: https://developer.apple.com/design/human-interface-guidelines/panels.md
---

# Inspector

A trailing column that shows and edits the details of whatever is selected.

## Contents

- Use when
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- `.inspector(isPresented:content:)` adds a column on the trailing edge of the window, beside your content.
- It shows the details of the current selection and updates as the selection changes, like the inspector in Keynote.
- Put the button that shows and hides it in the toolbar, and add `InspectorCommands` so the menu bar has a command and ⌃⌘I for it too.

## Built from

NavigationStack
└── Editor
    ├── .toolbar
    │   └── Button("Inspector")
    └── .inspector
        └── Form

## Rules

- **Show the details of the current selection.** An inspector follows the selection: pick another item and it updates. For details that shouldn't change, open a separate window instead.
- **Keep it on the trailing side, with its button at the trailing end of the toolbar.** That's where people expect to find both. Toolbar items at the trailing end stay visible at every window size.
- **Prefer controls that adjust in one step.** Sliders and steppers change a value right away. Typing in a text field, or picking an item from a list, takes more steps.

## Pitfalls

- **SwiftUI remembers whether the inspector was open.** When it's a trailing column, its shown or hidden state is restored with the window.

**Note:** A real inspector in this page would open in this app's own window, so the examples below draw the window. The demo window has the real thing.

## Key APIs

`.inspector(isPresented:content:)`, `.inspectorColumnWidth(min:ideal:max:)`, `.inspectorColumnWidth(_:)`, `InspectorCommands()`, `.interactiveDismissDisabled()`

## Variants

### Usage

```swift
@State private var showsInspector = true

NavigationStack {
    Text("Canvas")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .inspector(isPresented: $showsInspector) {
            Form {
                Text("Details of the selection")
            }
            .inspectorColumnWidth(min: 200, ideal: 240, max: 320)
        }
        .toolbar {
            Button("Inspector", systemImage: "sidebar.trailing") {
                showsInspector.toggle()
            }
        }
}
```

### Toggle it from the toolbar

Bind `isPresented` to a `Bool` and flip it from a button at the trailing end of the toolbar; try it in the drawn toolbar.

```swift
@State private var showsInspector = true

Text("Canvas")
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .inspector(isPresented: $showsInspector) {
        Text("Inspector")
    }
    .toolbar {
        Button("Inspector", systemImage: "sidebar.trailing") {
            showsInspector.toggle()
        }
    }
```

### Details that follow the selection

Pass a binding to the selected item into the inspector, so picking another shape switches what it edits.

```swift
@State private var shapes = ShapeItem.samples
@State private var selection: ShapeItem.ID? = 1
@State private var showsInspector = true

List(shapes, selection: $selection) { shape in
    Label(shape.name, systemImage: "square.fill")
        .foregroundStyle(shape.color)
}
.inspector(isPresented: $showsInspector) {
    if let index = shapes.firstIndex(where: { $0.id == selection }) {
        Form {
            TextField("Name", text: $shapes[index].name)
            Slider(value: $shapes[index].opacity, in: 0...1) {
                Text("Opacity")
            }
            Slider(value: $shapes[index].cornerRadius, in: 0...40) {
                Text("Corners")
            }
        }
    } else {
        ContentUnavailableView("No Selection", systemImage: "square.dashed")
    }
}
```

**Note:** `ShapeItem` is a small `Identifiable` struct with a name, color, opacity, and corner radius.

### A width people can drag, or a fixed one

`.inspectorColumnWidth` with `min`, `ideal`, and `max` lets people resize the column within limits, and one number fixes the width.

```swift
@State private var showsInspector = true

Text("Canvas")
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .inspector(isPresented: $showsInspector) {
        Form {
            Text("Details")
        }
        .inspectorColumnWidth(min: 200, ideal: 240, max: 320)
        // Or a fixed width that people can't drag shut:
        // .inspectorColumnWidth(240)
        // .interactiveDismissDisabled()
    }
```

**Important:** On the Mac, people can drag an inspector closed even at a fixed width. Add `.interactiveDismissDisabled()` to prevent it.

### Add the menu command

```swift
@main
struct ShapesApp: App {
    var body: some Scene {
        WindowGroup {
            EditorView()
        }
        .commands {
            InspectorCommands()
        }
    }
}
```

## Related

[split-views](split-views.md), [toolbar](toolbar.md), [navigation-split-view](navigation-split-view.md), [form](form.md)
