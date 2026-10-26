---
name: swiftui-build
description: Writes current SwiftUI for iOS, iPadOS, and macOS, using the iOS and macOS 26–27 APIs (Liquid Glass, @Observable, NavigationStack, Tab) instead of the deprecated ones models tend to write. Gives default code, variants, pitfalls, and availability fallbacks for each component, plus Mac windows, menus, and settings. Use when creating or changing SwiftUI views, screens, or components, such as buttons, lists, forms, text fields, pickers, navigation, tabs, sheets, alerts, toolbars, search, layout, grids, scroll views, state and data flow, animation, or Mac windows, menus, and settings. Trigger keywords include SwiftUI, SwiftUI view, iOS app, iPad app, macOS app, Xcode, NavigationStack, NavigationSplitView, TabView, List, Form, sheet, toolbar, @State, @Observable, @Binding, Liquid Glass, glassEffect, animation, and Xcode previews.
---

# SwiftUI build

Current SwiftUI for iOS, iPadOS, and macOS 26 and 27 (Xcode 27 SDKs). Your training data likely predates these APIs and is full of deprecated patterns. **Read the matching reference before writing code** rather than relying on memory.

This skill holds judgment: which API, which default, and what goes wrong. For full API detail, use Xcode's `DocumentationSearch` tool when it's available, or fetch Apple's docs as Markdown by adding `.md` to any developer.apple.com documentation URL. Each reference links its page.

## Workflow

1. Find the component in the index below and read `references/<id>.md`. For a Mac app, also read its **On macOS** section; Mac-only topics say `platforms: [macOS]`.
2. Check the deployment target. Anything newer than it goes behind `if #available` with a real fallback. See `references/liquid-glass.md`, `references/whats-new-26.md`, and `references/whats-new-27.md`.
3. Start from the reference's **Default code**, adapt a **Variant** if one fits, and follow its **Rules** and **Pitfalls**.
4. Build with zero new warnings. If the `swiftui-review` skill is installed, run its linter on the files you changed.

## Top rules

1. `NavigationStack` (or `NavigationSplitView` for sidebars and columns), never `NavigationView`. Navigate by value with `.navigationDestination(for:)`.
2. New models are `@Observable` classes held in `@State`, passed as plain properties, `@Bindable` for bindings, or `@Environment(Model.self)`. Don't write `ObservableObject`, `@Published`, `@StateObject`, or `@EnvironmentObject` in new code.
3. Async work goes in `.task { }`, which cancels with the view. Not `DispatchQueue.main.async`, and not `Task { }` in `onAppear`.
4. Icon buttons are `Button("Share", systemImage: "square.and.arrow.up") { }`, with `.labelStyle(.iconOnly)` when the title should be hidden. VoiceOver reads the title.
5. Text uses text styles (`.body`, `.headline`), never `.font(.system(size:))`. Use `@ScaledMetric` for custom sizes.
6. Lay out by available space (`ViewThatFits`, size classes, `containerRelativeFrame`, `onGeometryChange`), never `UIScreen.main` or device checks.
7. System bars, sheets, menus, and button styles adopt Liquid Glass when built with the 26+ SDK. Use `.glassEffect` only on floating controls, never on content, and remove custom bar backgrounds.
8. `ForEach` needs stable identity: make elements `Identifiable`. Avoid `id: \.self` on values that can repeat, and avoid `.indices`.
9. Prefer `@ViewBuilder` and `some View` over `AnyView`. Use one `.animation(_:value:)` per change, or `withAnimation`.
10. Every new view gets a `#Preview`, with `@Previewable @State` for bindings.

## Top corrections

Old → new. Every one, with its minimum OS: `references/deprecated-apis.md`.

- `NavigationLink(isActive:)` / `(tag:selection:)` → `.navigationDestination(isPresented:)` / `NavigationLink(value:)`
- `.onChange(of:) { new in }` → `{ old, new in }` or `{ }`
- `Text + Text` → `Text("a \(Text(b).bold())")`
- `.animation(_:)` → `.animation(_:value:)` / `withAnimation`
- `UIScreen.main.bounds` → `.containerRelativeFrame` / size classes
- `NavigationView` → `NavigationStack` / `NavigationSplitView`
- `.navigationViewStyle(_:)` → delete; pick the container
- `.navigationBarTitle` → `.navigationTitle` + `.navigationBarTitleDisplayMode`
- `.navigationBarItems` → `.toolbar { ToolbarItem }`
- `.navigationBarLeading/Trailing` → `.topBarLeading/Trailing`
- `.navigationBarHidden(true)` → `.toolbarVisibility(.hidden, for: .navigationBar)`
- `.tabItem { }` → `Tab("Title", systemImage:) { }`
- `\.presentationMode` → `\.dismiss`
- `ActionSheet` / `.actionSheet` → `.confirmationDialog`
- `Alert(title:)` → `.alert(_:isPresented:actions:message:)`
- `ObservableObject` → `@Observable`

## Index

Each id is a file, `references/<id>.md`. (macOS) marks Mac-only topics.

### Start here

- `deprecated-apis` — Every outdated SwiftUI API models still write
- `liquid-glass` — Liquid Glass rules, default code
- `whats-new-26` — SwiftUI APIs new in iOS and macOS 26
- `whats-new-27` — SwiftUI APIs new in iOS and macOS 27

### Controls

- `button` — A control that runs an action when tapped
- `toggle` — A control that switches between on and off
- `picker` — A control for choosing one value
- `menu` — A button that reveals a list of actions
- `slider` — A control for picking a number
- `stepper` — A pair of minus and plus buttons
- `date-picker` — A control for choosing a date
- `color-picker` — A swatch that opens the system color picker
- `progress-view` — Shows that work is happening
- `gauge` — Shows where a value sits within a range
- `link` — A control that opens a URL
- `share-link` — A button that opens the share sheet
- `gauge-progress` (macOS) — Progress bars and spinners for work under way
- `control-group` (macOS) — Related buttons joined into one control
- `labeled-content` (macOS) — A label and a value in one row

### Text Input

- `text-field` — A box people type a short piece
- `secure-field` — A text field that hides what people type
- `text-editor` — A scrolling, multi-line area for long text
- `focus-state` — Choose which field is active
- `focus-keyboard` (macOS) — Decide which view gets typed keys

### Text & Images

- `text` — Shows read-only text
- `label` — An icon and a title together
- `image` — Shows a picture or an SF Symbol
- `async-image` — Downloads and shows an image from a URL
- `text-label` (macOS) — Shows read-only text
- `image-symbols` (macOS) — Show pictures from your app

### Layout

- `layout-basics` — A parent offers its child a size
- `stacks` — Arrange views in a column, a row
- `spacer-divider` — Spacer pushes views apart in a stack
- `grid` — Lines views up in rows and columns
- `lazy-grids` — Scrolling grids of many items
- `scroll-view` — Lets content that's bigger than the screen scroll
- `view-that-fits` — Give it a few versions of a view
- `geometry-reader` — Three ways to size a view relative
- `safe-area` — The part of the screen clear
- `stacks-grid` (macOS) — Line views up in rows, columns, layers
- `group-box` (macOS) — Box related controls together
- `split-views` (macOS) — Panes people resize by dragging the divider

### Lists & Navigation

- `list` — A scrolling column of rows
- `form` — A container that lays out controls as grouped
- `navigation-stack` — Pushes screens on top of each other
- `navigation-split-view` — A sidebar and detail side by side
- `tab-view` — Switches between top-level sections with a tab bar
- `toolbar` — Puts buttons and menus in the bar
- `searchable` — Adds a system search field to a screen
- `swipe-actions` — Lets people swipe rows for actions

### Presentation

- `sheet` — Slides a view up over the current screen
- `alert` — Interrupts with an important message and asks
- `confirmation-dialog` — Asks people to pick from a few actions
- `popover` — Shows extra content in a bubble that points
- `context-menu` — A menu of actions that appears when people
- `tooltips` (macOS) — A short phrase that appears when the pointer

### Modifiers

- `modifier-order` — Each modifier wraps the view before it
- `padding` — Adds space around a view
- `frame` — Sets a view's size
- `background-overlay` — Layers a color, shape
- `clip-shape` — Cuts a view to a shape
- `shadow` — Draws a soft shadow behind a view
- `foreground-style` — Colors text, symbols, and shapes
- `font` — Sets the size, weight
- `visual-effects` — Fade, blur, scale, rotate, move
- `custom-modifier` — Bundles a set of modifiers under one name

### Data Flow

- `choosing-wrappers` — Answer two questions to pick the right property
- `state` — Stores a value that one view owns
- `binding` — Lets a child view read and write
- `observable` — Turns a class into a shared model
- `environment` — Reads values the system or an ancestor passes
- `lifecycle` — Run code when a view appears
- `view-updates` — See which views run their body again
- `state-binding` (macOS) — @State keeps a value a view owns

### Animation & Effects

- `animation-curves` — Animate any state change
- `spring` — A natural, physics-based animation set by how long
- `transitions` — Control how a view animates in when it's
- `matched-geometry` — Morph one view into another
- `phase-animator` — Steps a view through a list of states
- `keyframe-animator` — Animates several properties on their own timelines
- `symbol-effects` — Built-in SF Symbol animations, like bounce, pulse
- `content-transition` — Animate content changing in place
- `haptics` — Play a tap, buzz

### Shapes & Gradients

- `shapes` — Rectangles, circles, capsules, and your own paths
- `gradients` — Smooth blends between colors

### Charts & Maps

- `charts` — Bar, line, area, point
- `map` — An interactive Apple Map with markers
- `charts-maps` (macOS) — Swift Charts with a selectable plot

### Blocks

- `login-form` — An email and password sign-in screen with AutoFill
- `settings-screen` — A grouped settings form with toggles
- `inbox-list` — A mail-style list with unread dots
- `empty-state` — What to show when a screen has no
- `onboarding` — A paged welcome flow with Continue and Skip
- `profile` — A social profile with an avatar, stats
- `detail-screen` — A listing page with a full-bleed hero
- `library-window` (macOS) — A sidebar, a sortable table, and an inspector
- `settings-window` (macOS) — A Settings window with a toolbar of panes
- `menu-bar-utility` (macOS) — A small app that lives in the menu
- `document-editor` (macOS) — A text editor that opens, saves
- `welcome-window` (macOS) — The window a document app shows at launch
- `empty-states` (macOS) — What a sidebar, table

### Lists & Tables

- `list-styles` (macOS) — Sidebar, inset, and bordered lists
- `table` (macOS) — Rows of data in columns that people sort
- `outline` (macOS) — Folders inside folders

### Navigation

- `inspector` (macOS) — A trailing column that shows and edits
- `search` (macOS) — A search field in the toolbar or sidebar

### Windows & Scenes

- `window-group` (macOS) — The scene for your app's main windows
- `window` (macOS) — A single, unique window
- `settings-scene` (macOS) — The app's Settings window
- `menu-bar-extra` (macOS) — A menu bar icon that opens a menu
- `document-group` (macOS) — The scene for document-based apps, with New
- `window-style` (macOS) — Scene modifiers for a window's title bar
- `opening-windows` (macOS) — Open, bring forward

### Menus & Commands

- `commands` (macOS) — Add your own menus and menu items
- `keyboard-shortcuts` (macOS) — Run a button or menu item

### Pointer & Input

- `hover` (macOS) — React when the pointer moves over a view
- `drag-drop` (macOS) — Let people drag content within a window
- `copy-paste` (macOS) — Connect the Edit menu's Cut, Copy, Paste
- `trackpad-gestures` (macOS) — Zoom and rotate with trackpad gestures

### Files & Sharing

- `file-import-export` (macOS) — Show the Mac's open and save panels

### Animation

- `animation` (macOS) — Springs and transitions that stay quick and quiet
