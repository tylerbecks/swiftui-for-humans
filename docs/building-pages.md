# Building pages

How a page is put together in code. For what to write on it, see [content-guide.md](content-guide.md).

## Adding a page

1. Create `Examples/<Group>/<Name>Page.swift`.
2. Define its `ComponentPage` (see below).
3. Add it to the group's registry, `Examples/<Group>/<Group>Pages.swift`, in the order it should appear in the sidebar.

`Catalog/Registry.swift` combines the group lists. Sidebar sections come from each page's `category`, not from its folder, so a page in `Navigation/` can appear under "Presentation".

**File names must be unique across the package.** Swift Playgrounds packages compile every file into one module.

## Page metadata

```swift
extension ComponentPage {
    static let button = ComponentPage(
        id: "button",                      // unique, kebab-case
        title: "Button",
        summary: "A control that runs an action when tapped.",
        category: .controls,               // sidebar section
        kind: .component,                  // .component, .modifier, .concept, .reference, .block
        symbol: "button.horizontal.top.press",
        availability: ["iOS 13.0+", "macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/button",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/buttons",
        aliases: ["cta", "submit", "onClick"],
        related: ["toggle", "menu"],       // other page ids
        notes: [...],                      // "Good to know"
        about: nil,                        // containers only
        composition: nil,                  // containers only
        api: [APIItem("`.buttonStyle(_:)`", "Picks the look.")],
        guidelines: [Guideline(...)],
        isNew: false                       // new in the latest iOS
    ) {
        // Thumbnail for the overview grid
    } content: { page in
        ButtonDemo(page: page)
    }
}
```

- **Thumbnail:** a small, real, non-interactive view in a 150pt-tall card. It should use the actual component, not a picture of it, and read well in light and dark.
- **Aliases:** what someone would search for when they don't know the SwiftUI name. Include web terms (`dropdown`, `<select>`, `useState`), UIKit names (`UISwitch`), and common misspellings.
- **URLs:** both must point to pages that exist.

## DemoPage or ArticlePage

**`DemoPage`** is for one component with options to change. It shows a live preview with its code, a Customize panel (a sheet on iPhone, an inspector on iPad), and Usage:

```swift
DemoPage(
    page: page,
    initial: ButtonConfig(),
    usage: """
    Button("Sign In") { signIn() }
    """,
    usageNote: Aside(.important, "...")    // optional
) { $config in
    Button(config.title) {}                // preview, driven by config
} controls: { $config in
    OptionPicker("Style", selection: $config.style)
} code: { config in
    "Button(\(swiftString(config.title))) { }"
} examples: {
    ExampleCard(title: "Full-width button", code: "...", aside: Aside(.note, "...")) { ... }
}
```

The `code` closure returns Swift for the current options. Leave out modifiers that match the defaults, and format values with `swiftString` and `swiftNumber`, so the output compiles when pasted into a view.

**`ArticlePage`** is for concepts, references, and blocks. Fill it with `Prose`, `SectionTitle`, `ExampleCard`, `PreviewCard`, and `Aside`.

Both kinds share the header, Guidelines, Key APIs, Good to know, Related, and Previous / Next.

## Whole-screen previews

- **`PhoneScreen { ... }`** shows a screen in an iPhone frame with its own navigation bar, so `.navigationTitle`, `.toolbar`, and `.searchable` draw inside the frame. Pass the root view *without* a `NavigationStack`. Use `hasNavigationBar: false` for screens without a bar.
- **`DeviceFrame { ... }`** is just the frame, for content that manages itself, like a `TabView`.

A `NavigationLink` inside the frame pushes onto the app's own stack, not the frame's. To demonstrate pushing, add a "Try It Full Screen" button that presents the screen in its own `NavigationStack`.

## SwiftUI first

Write everything in SwiftUI, including the app's own chrome. Use UIKit only where SwiftUI has no real replacement:

- `UIPasteboard` for copying code
- `UIKeyboardType` and `UITextContentType`, which SwiftUI's modifiers take
- the semantic colors that the System Colors page teaches
- `PhoneScreen`, which needs its own `UINavigationController`

Prefer SwiftUI styles like `.background`, `.secondary`, and `.fill.tertiary` over `Color(.systemBackground)`.

## Testing

Build from the command line:

```sh
cd SwiftUIForHumans.swiftpm
xcodebuild -scheme SwiftUIForHumans -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/dd build
xcrun simctl install <udid> "/tmp/dd/Build/Products/Debug-iphonesimulator/SwiftUI for Humans.app"
```

Launch arguments open the app in a known state:

| Argument | Effect |
| --- | --- |
| `-open <page id>` | Opens a page (`overview` for the overview) |
| `-search <text>` | Fills in the search field |
| `-showControls` | Opens the Customize panel on a `DemoPage` |
| `-showScrubber` | Keeps the page scrubber on screen |
| `-scrollTo <anchor>` | Scrolls to a section: `preview`, `code`, `examples`, `guidelines`, `api`, `notes`, or `outline-<heading>`. On the overview, a category name or `card-<page id>` |

```sh
xcrun simctl launch <udid> com.gobimaps.SwiftUIForHumans -open button -showControls
```

Before you finish a page, check it on iPhone and iPad in light and dark mode.
