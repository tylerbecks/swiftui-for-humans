# SwiftUI for Humans

Apple's SwiftUI docs and Human Interface Guidelines, on one page, in plain language. A live, interactive reference for SwiftUI components, in the spirit of [shadcn/ui](https://ui.shadcn.com): browse a component, see the real thing, tweak it with controls, and copy the code that reproduces it.

It's an iOS app first, so what you see is real iOS rendering. Run it on an iPhone, an iPad, or your Mac as an iPad app.

## Running

Open `SwiftUIForHumans.swiftpm` in Xcode (or Swift Playgrounds), then pick a run destination:

- **My Mac (Designed for iPad)**: real iOS rendering in a Mac window. Needs your team selected under Signing & Capabilities.
- **Any iPhone or iPad simulator**

## Adding a component

**Read [CONTENT_GUIDE.md](CONTENT_GUIDE.md) first.** It is the rulebook for every page: which sections a page has and in what order, how to write each one, and which page types (simple control, container, concept, block) need what. Button (`Examples/Controls/ButtonExample.swift`) and NavigationStack (`Examples/Navigation/NavigationStackPage.swift`) are the reference pages to copy.

### Where things live

```
SwiftUIForHumans.swiftpm/
  App/          ContentView (sidebar, search, launch options), OverviewView (thumbnail grid)
  Catalog/      Shared building blocks: ComponentPage, DemoPage, PageParts, PhoneScreen, CodeBlock, DemoOption
  Examples/
    Controls/   ButtonExample.swift, PickerPage.swift, ...  one file per page
                ControlsPages.swift                          the group's registry
    Layout/ Navigation/ Modifiers/ DataFlow/ Animation/ Design/ TextAndImages/ Blocks/
```

Each page is one file, `Examples/<Group>/<Name>Page.swift`. File names must be unique across the whole package, because Swift Playgrounds packages compile every file into one module.

Each group has a registry file, `<Group>Pages.swift`, that lists its pages in sidebar order (`static let controlsPages: [ComponentPage] = [.button, .toggle, ...]`). `Catalog/Registry.swift` joins the group lists into `Catalog.pages`. To add a page, write the file and add one line to its group's registry. Sidebar sections come from `ComponentCategory`, not from the folders, so a page in `Navigation/` can appear under "Presentation".

### The page's metadata

```swift
extension ComponentPage {
    static let button = ComponentPage(
        id: "button",                      // unique, kebab-case; used by -open and related links
        title: "Button",
        summary: "A control that runs an action when tapped.",   // one sentence
        category: .controls,               // sidebar section
        kind: .component,                  // .component, .modifier, .concept, .reference, .block
        symbol: "button.horizontal.top.press",
        availability: ["iOS 13.0+", "macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/button",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/buttons",
        aliases: ["cta", "submit", "onClick"],
        related: ["toggle", "menu"],       // other page ids, shown as chips at the bottom
        notes: ["A few short points that would trip you up."],
        about: "...",                      // containers and systems only: what it owns, when to use it
        composition: "...",                // containers only: how the parts nest, as a small tree
        api: [APIItem("`.buttonStyle(_:)`", "Picks the look.")],   // "Key APIs", 4–8 rows
        guidelines: [Guideline(...)],      // HIG best practices, optionally with a live Do / Don't pair
        isNew: false                       // true for APIs new in the latest iOS
    ) {
        // thumbnail
    } content: { page in
        ButtonDemo(page: page)
    }
}
```

- **Thumbnail**: the first closure is a small, real, non-interactive view shown in a 150pt-tall card on the overview. Use the actual component, not a picture of it, and keep it readable at that size in light and dark.
- **Aliases**: the words someone searches for when they don't know the SwiftUI name: web terms (`dropdown`, `modal`, `<select>`, `flexbox`, `useState`), UIKit names (`UISwitch`), and common misspellings. Search matches the title, summary, and aliases, and the sidebar shows which alias matched.
- **URLs**: `docsURL` and `higURL` must point at pages that exist. Check them with `curl` before adding.

### DemoPage or ArticlePage

Use **`DemoPage`** for one component with options people can change. It shows a preview, the generated code, and a controls panel (a sheet on iPhone, an inspector on iPad and Mac):

```swift
DemoPage(
    page: page,
    initial: ButtonConfig(),
    usage: """
    Button("Sign In") { signIn() }
    """,                                  // Usage: the smallest real snippet, shown in full
    usageNote: Aside(.important, "...")   // optional: the one gotcha people hit
) { $config in
    Button(config.title) {}           // preview: the real component, driven by config
} controls: { $config in
    TextField("Title", text: $config.title)       // Form rows: OptionPicker, ValueSlider, Toggle, TextField
    OptionPicker("Style", selection: $config.style)
} code: { config in
    "Button(\(swiftString(config.title))) { }"   // Swift for the current config; omit defaults
} examples: {
    ExampleCard(title: "Full-width button", code: "...", aside: Aside(.note, "...")) { ... }
}
```

The generated code must compile when pasted into a `body`. Use `swiftNumber` and `swiftString` to format values, and only include modifiers that differ from the defaults.

Use **`ArticlePage`** for concepts, references, and blocks with no single set of options. Fill it with `Prose`, `SectionTitle`, `ExampleCard` (a preview with its code), `PreviewCard`, `Aside(.note / .important, ...)` placed under the thing it explains, and your own views. Both page types share the header, "Good to know" notes, and related links.

### Whole screens: PhoneScreen and DeviceFrame

For previews that need a whole iPhone screen, wrap them in a frame:

- **`PhoneScreen { ... }`** hosts the screen in its own navigation bar, so `.navigationTitle`, `.toolbar` (including `.bottomBar` items), and `.searchable` draw inside the frame. Pass the root view **without** a `NavigationStack`. Use `hasNavigationBar: false` for screens without a bar, such as onboarding. It always behaves like a compact-width iPhone, even on iPad.
- **`DeviceFrame { ... }`** is just the phone shape, for screens that manage their own content (for example a `TabView`).

A `NavigationLink` inside the frame pushes onto the catalog's own stack, not the frame's. Pages that show pushing offer an "Open Full Screen" button that presents the real screen, inside its own `NavigationStack`, in a sheet or full-screen cover.

### SwiftUI first

Write everything in SwiftUI, including the catalog's own chrome. Use UIKit only when SwiftUI has no obvious replacement. Today that means `UIPasteboard` (Copy buttons), `UIApplication.openSettingsURLString`, `UIFont` point sizes on the Typography page, `UIKeyboardType` / `UITextContentType` (the types SwiftUI's `.keyboardType` and `.textContentType` take), the `Color(.label)`-style semantic colors that the System Colors page teaches, and `Catalog/PhoneScreen.swift`. Prefer SwiftUI styles such as `.background`, `.secondary`, and `.fill.tertiary` over `Color(.systemBackground)`.

### Copy

Keep the copy short, like shadcn: one sentence for the summary, asides next to the examples they explain, and two or three "good to know" notes for page-wide tips. Write for someone who knows programming but is new to iOS. CONTENT_GUIDE.md has the full writing rules.

### Testing a page

Build for the simulator from the command line:

```sh
cd SwiftUIForHumans.swiftpm
xcodebuild -scheme SwiftUIForHumans -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/dd build
xcrun simctl install <udid> /tmp/dd/Build/Products/"Debug-iphonesimulator/SwiftUI for Humans.app"
```

Launch arguments open the app in a known state, which is handy for screenshots:

| Argument | Effect |
| --- | --- |
| `-open <page id>` | Opens that page (`-open overview` for the overview). |
| `-search <text>` | Fills the sidebar search field. |
| `-showControls` | Opens the controls sheet or inspector on a `DemoPage`. |
| `-showScrubber` | Keeps the page scrubber visible on long pages. |
| `-scrollTo <anchor>` | Scrolls to a view with that `.id`. On pages: `preview`, `code`, `examples`, `guidelines`, `api`, `notes`, or any `.id` you add. On the overview: a category name (`Blocks`) or `card-<page id>`. |

```sh
xcrun simctl launch <udid> com.gobimaps.SwiftUIForHumans -open button -showControls
xcrun simctl io <udid> screenshot button.png
```

To drive the app, use [axe](https://github.com/cameroncooke/AXe). Sidebar rows have the accessibility identifier `row-<page id>` and overview cards `card-<page id>`. Pass `--tap-style physical` to taps; axe's default simulator-style taps don't register in this app:

```sh
axe tap --id row-picker --tap-style physical --udid <udid>
axe tap --label Customize --tap-style physical --udid <udid>
```

Before you finish, check the page on iPhone and iPad in light and dark mode, make sure the generated code compiles for a few non-default configurations, and confirm that every `related` id exists.

---

SwiftUI for Humans is an independent project. It is not affiliated with or endorsed by Apple. Swift, SwiftUI, iOS, and the Human Interface Guidelines are Apple trademarks and names, used here to describe what the app covers.
