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

### Start here

- `references/deprecated-apis.md`: Every outdated SwiftUI API models still write, with its replacement and minimum OS.
- `references/liquid-glass.md`: Liquid Glass rules, default code, and the fallback before 26.
- `references/whats-new-26.md`: SwiftUI APIs new in iOS and macOS 26, with availability.
- `references/whats-new-27.md`: SwiftUI APIs new in iOS and macOS 27 and 27.1, and what changed.

### Controls

- `references/button.md`: A control that runs an action when tapped.
- `references/toggle.md`: A control that switches between on and off.
- `references/picker.md`: A control for choosing one value from a list of options.
- `references/menu.md`: A button that reveals a list of actions when tapped.
- `references/slider.md`: A control for picking a number from a range by dragging a thumb along a track.
- `references/stepper.md`: A pair of minus and plus buttons that change a number by a fixed amount.
- `references/date-picker.md`: A control for choosing a date, a time, or both.
- `references/color-picker.md`: A swatch that opens the system color picker so people can choose any color.
- `references/progress-view.md`: Shows that work is happening, as a spinning indicator or a filling bar.
- `references/gauge.md`: Shows where a value sits within a range, like a battery level or a speedometer.
- `references/link.md`: A control that opens a URL, in Safari or in the app that handles it.
- `references/share-link.md`: A button that opens the share sheet to send a link, text, or image.
- `references/gauge-progress.md` (macOS only): Progress bars and spinners for work under way, and gauges for a level in a range.
- `references/control-group.md` (macOS only): Related buttons joined into one control, in a toolbar or in content.
- `references/labeled-content.md` (macOS only): A label and a value in one row that lines up with the rest of a form.

### Text Input

- `references/text-field.md`: A box people type a short piece of text or a number into.
- `references/secure-field.md`: A text field that hides what people type, for passwords and PINs.
- `references/text-editor.md`: A scrolling, multi-line area for long text such as notes or a bio.
- `references/focus-state.md`: Choose which field is active, move between fields on Return, pick the right keyboard, and dismiss it.
- `references/focus-keyboard.md` (macOS only): Decide which view gets typed keys, and let people move around with Tab.

### Text & Images

- `references/text.md`: Shows read-only text, styled with fonts and colors, with built-in Markdown and formatting.
- `references/label.md`: An icon and a title together, which adapts its look to where it's used.
- `references/image.md`: Shows a picture or an SF Symbol, and controls how it fills its frame.
- `references/async-image.md`: Downloads and shows an image from a URL, with a placeholder while it loads.
- `references/text-label.md` (macOS only): Shows read-only text, and pairs a short title with an icon in a label.
- `references/image-symbols.md` (macOS only): Show pictures from your app, and thousands of system symbols that match your text.

### Layout

- `references/layout-basics.md`: A parent offers its child a size, the child picks its own, and the parent places it.
- `references/stacks.md`: Arrange views in a column, a row, or layered on top of each other.
- `references/spacer-divider.md`: Spacer pushes views apart in a stack; Divider draws a thin line between them.
- `references/grid.md`: Lines views up in rows and columns, sizing each column to its widest cell.
- `references/lazy-grids.md`: Scrolling grids of many items, like a photo library, built only as they appear.
- `references/scroll-view.md`: Lets content that's bigger than the screen scroll, vertically or sideways.
- `references/view-that-fits.md`: Give it a few versions of a view, and it shows the first one that fits.
- `references/geometry-reader.md`: Three ways to size a view relative to its container or read its size.
- `references/safe-area.md`: The part of the screen clear of the Dynamic Island, home indicator, bars, and keyboard.
- `references/stacks-grid.md` (macOS only): Line views up in rows, columns, layers, and tables that grow with the window.
- `references/group-box.md` (macOS only): Box related controls together, and tuck advanced ones under a disclosure triangle.
- `references/split-views.md` (macOS only): Panes people resize by dragging the divider between them, side by side or stacked.

### Lists & Navigation

- `references/list.md`: A scrolling column of rows, like the ones in Settings, Mail, and Contacts.
- `references/form.md`: A container that lays out controls as grouped rows, like the Settings app.
- `references/navigation-stack.md`: Pushes screens on top of each other with a back button, like drilling into a folder.
- `references/navigation-split-view.md`: A sidebar and detail side by side on iPad that collapses into a stack on iPhone.
- `references/tab-view.md`: Switches between top-level sections with a tab bar, or swipes through pages like a carousel.
- `references/toolbar.md`: Puts buttons and menus in the bar at the top or bottom of a screen.
- `references/searchable.md`: Adds a system search field to a screen and hands you the text to filter with.
- `references/swipe-actions.md`: Lets people swipe rows for actions, delete and reorder them, and pull to refresh.

### Presentation

- `references/sheet.md`: Slides a view up over the current screen for a focused task, at full or partial height.
- `references/alert.md`: Interrupts with an important message and asks for a quick decision.
- `references/confirmation-dialog.md`: Asks people to pick from a few actions, or confirm a destructive one.
- `references/popover.md`: Shows extra content in a bubble that points at the button that opened it.
- `references/context-menu.md`: A menu of actions that appears when people touch and hold a view.
- `references/tooltips.md` (macOS only): A short phrase that appears when the pointer rests on a control.

### Modifiers

- `references/modifier-order.md`: Each modifier wraps the view before it, so changing the order changes the result.
- `references/padding.md`: Adds space around a view, on every edge or only the edges you pick.
- `references/frame.md`: Sets a view's size, or lets it stretch to fill the space it's offered.
- `references/background-overlay.md`: Layers a color, shape, or view behind or on top of a view, sized to match it.
- `references/clip-shape.md`: Cuts a view to a shape, like rounded corners or a circle, and hides the rest.
- `references/shadow.md`: Draws a soft shadow behind a view to lift it off the background.
- `references/foreground-style.md`: Colors text, symbols, and shapes, and sets the accent color of controls.
- `references/font.md`: Sets the size, weight, and design of text, and scales it with the user's text size.
- `references/visual-effects.md`: Fade, blur, scale, rotate, move, and desaturate a view without changing its layout.
- `references/custom-modifier.md`: Bundles a set of modifiers under one name, so you can reuse a style everywhere.

### Data Flow

- `references/choosing-wrappers.md`: Answer two questions to pick the right property wrapper for your data.
- `references/state.md`: Stores a value that one view owns, and redraws the view when it changes.
- `references/binding.md`: Lets a child view read and write a value its parent owns, so both stay in sync.
- `references/observable.md`: Turns a class into a shared model that views watch and redraw from automatically.
- `references/environment.md`: Reads values the system or an ancestor passes down, like dark mode or the locale.
- `references/lifecycle.md`: Run code when a view appears, load data with task, and react to changes with onChange.
- `references/view-updates.md`: See which views run their body again when state changes, and why the rest don't.
- `references/state-binding.md` (macOS only): @State keeps a value a view owns, and @Binding lets another view change it.

### Animation & Effects

- `references/animation-curves.md`: Animate any state change, and pick a curve for how it speeds up and slows down.
- `references/spring.md`: A natural, physics-based animation set by how long it takes and how much it bounces.
- `references/transitions.md`: Control how a view animates in when it's added and out when it's removed.
- `references/matched-geometry.md`: Morph one view into another, like a sliding tab highlight or a card growing full screen.
- `references/phase-animator.md`: Steps a view through a list of states, either in a loop or each time a value changes.
- `references/keyframe-animator.md`: Animates several properties on their own timelines, like a jump that squashes, spins, and lands.
- `references/symbol-effects.md`: Built-in SF Symbol animations, like bounce, pulse, and wiggle, with one modifier.
- `references/content-transition.md`: Animate content changing in place, like digits rolling on a counter or one icon becoming another.
- `references/haptics.md`: Play a tap, buzz, or click on the device when something happens.

### Shapes & Gradients

- `references/shapes.md`: Rectangles, circles, capsules, and your own paths, ready to fill, stroke, or clip with.
- `references/gradients.md`: Smooth blends between colors: in a line, outward from a point, around a circle, or across a mesh.

### Charts & Maps

- `references/charts.md`: Bar, line, area, point, and pie charts built from your data in a few lines.
- `references/map.md`: An interactive Apple Map with markers, custom pins, styles, and a camera you control.
- `references/charts-maps.md` (macOS only): Swift Charts with a selectable plot, and a MapKit map that fills a window.

### Blocks

- `references/login-form.md`: An email and password sign-in screen with AutoFill, focus handling, and Sign in with Apple.
- `references/settings-screen.md`: A grouped settings form with toggles, a picker, a drill-down row, and sign-out confirmation.
- `references/inbox-list.md`: A mail-style list with unread dots, swipe actions, a filter menu, and search.
- `references/empty-state.md`: What to show when a screen has no content, no search results, or an error.
- `references/onboarding.md`: A paged welcome flow with Continue and Skip buttons that ends with Get Started.
- `references/profile.md`: A social profile with an avatar, stats, Follow and Message buttons, and a photo grid.
- `references/detail-screen.md`: A listing page with a full-bleed hero, a glass toolbar, and a floating Reserve bar.
- `references/library-window.md` (macOS only): A sidebar, a sortable table, and an inspector: the classic window for browsing a library.
- `references/settings-window.md` (macOS only): A Settings window with a toolbar of panes, ready to copy into your app.
- `references/menu-bar-utility.md` (macOS only): A small app that lives in the menu bar and opens a panel when clicked.
- `references/document-editor.md` (macOS only): A text editor that opens, saves, and creates files, with a toolbar for formatting.
- `references/welcome-window.md` (macOS only): The window a document app shows at launch, with New, Open, and recent files.
- `references/empty-states.md` (macOS only): What a sidebar, table, or search shows when there's nothing to show yet.

### Lists & Tables

- `references/list-styles.md` (macOS only): Sidebar, inset, and bordered lists, with rows people click to select, one or many.
- `references/table.md` (macOS only): Rows of data in columns that people sort, resize, and select, like Finder's list view.
- `references/outline.md` (macOS only): Folders inside folders: rows with disclosure triangles that open to show their children.

### Navigation

- `references/inspector.md` (macOS only): A trailing column that shows and edits the details of whatever is selected.
- `references/search.md` (macOS only): A search field in the toolbar or sidebar, with suggestions and tokens.

### Windows & Scenes

- `references/window-group.md` (macOS only): The scene for your app's main windows, where people can open as many as they need.
- `references/window.md` (macOS only): A single, unique window, like an activity viewer or a floating palette.
- `references/settings-scene.md` (macOS only): The app's Settings window, opened from the app menu or with ⌘,.
- `references/menu-bar-extra.md` (macOS only): A menu bar icon that opens a menu or a small window, whichever app is in front.
- `references/document-group.md` (macOS only): The scene for document-based apps, with New, Open, and Save built in.
- `references/window-style.md` (macOS only): Scene modifiers for a window's title bar, toolbar style, size, and position.
- `references/opening-windows.md` (macOS only): Open, bring forward, and close windows from your own code.

### Menus & Commands

- `references/commands.md` (macOS only): Add your own menus and menu items to the Mac's menu bar.
- `references/keyboard-shortcuts.md` (macOS only): Run a button or menu item from the keyboard, like ⌘S for Save.

### Pointer & Input

- `references/hover.md` (macOS only): React when the pointer moves over a view, and show the right pointer.
- `references/drag-drop.md` (macOS only): Let people drag content within a window, between windows, and to other apps.
- `references/copy-paste.md` (macOS only): Connect the Edit menu's Cut, Copy, Paste, and Delete to your own views.
- `references/trackpad-gestures.md` (macOS only): Zoom and rotate with trackpad gestures, plus a way to do both with a mouse.

### Files & Sharing

- `references/file-import-export.md` (macOS only): Show the Mac's open and save panels, and read or write the files people pick.

### Animation

- `references/animation.md` (macOS only): Springs and transitions that stay quick and quiet under a pointer and in big windows.
