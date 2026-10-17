# Building pages

How a page is put together in code. For what to write on it, see [content-guide.md](content-guide.md).

## Adding a page

1. Create `Examples/<Group>/<Name>Page.swift`.
2. Define its `ComponentPage` (see below).
3. Add it to the group's registry, `Examples/<Group>/<Group>Pages.swift`, in the order it should appear in the sidebar.

`Catalog/Registry.swift` combines the group lists. Sidebar sections come from each page's `category`, not from its folder, so a page in `Navigation/` can appear under "Presentation".

## Tabs and categories

The app has three content tabs and a search tab. Each category belongs to one tab (`ComponentCategory.tab`), and pages show up in their category's tab. Previous / Next stays within the tab.

| Tab | Categories (`ComponentCategory` cases) |
| --- | --- |
| Components | `.controls`, `.textInput`, `.textAndImages`, `.layout`, `.lists`, `.presentation`, `.modifiers`, `.dataFlow`, `.animation`, `.graphics`, `.frameworks`, `.blocks` |
| Design | `.foundations`, `.accessibility`, `.patterns` |
| Ship | `.startHere`, `.feelsNative`, `.requiredByApple`, `.appStoreConnect`, `.testAndRelease` |

Search lives in its own tab and searches every page's title, summary, and aliases. A category with no pages is hidden, and a tab with no pages shows "Coming Soon".

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
        isNew: false,                      // new in the latest iOS
        sources: [],                       // official URLs the page is based on
        reviewed: nil                      // e.g. "October 2026"
    ) {
        // Thumbnail for the overview grid
    } content: { page in
        ButtonDemo(page: page)
    }
}
```

- **Thumbnail:** a small, real, non-interactive view in a 150pt-tall card. It should use the actual component, not a picture of it, and read well in light and dark.
- **Aliases:** what someone would search for when they don't know the SwiftUI name. Include web terms (`dropdown`, `<select>`, `useState`), UIKit names (`UISwitch`), and common misspellings.
- **Aliases on Ship pages:** add the App Review Guideline numbers the page covers, such as `"Guideline 4.0"` or `"5.1.1(v)"`. Searching "5.1" finds 5.1.1(v), and "2.1" doesn't find 12.1.
- **URLs:** both must point to pages that exist.
- **Sources and reviewed:** `sources` lists the official pages you based the page on (App Review Guidelines, HIG, Apple docs, App Store Connect Help). `reviewed` is the month you last checked them, such as `"October 2026"`. They render above Previous / Next as one quiet line, "iOS 15.0+ · 9 sources · Checked October 2026", that expands into the list. Both are required on Ship pages, because rules and deadlines change. Check every URL with `curl -sI` first, then add its title to `Catalog/SourceTitles.swift`: Apple's own page title, so the list reads `fullScreenCover`, not the URL's `fullscreencover`.

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

## Checklists

Ship pages can end with a `Checklist`: rows with a bold title, a one-line detail (both take inline Markdown), and an optional link to the page that explains the item. Checkmarks are saved on the device per page and item, and the list shows "x of y done" with a Reset button.

```swift
Checklist(pageID: page.id, items: [
    ChecklistItem("privacy-policy", "Link your privacy policy",
                  "In the app and in App Store Connect.",
                  page: "privacy-details"),
    ChecklistItem("account-deletion", "Let people delete their account",
                  "Required if they can create one in the app."),
])
```

Item ids key the saved state, so keep them stable once a page ships. `page:` takes a page id and opens it as a `catalog://` link, switching tabs when needed. Put a checklist inside the page's content, never inside a `List`.

## iPad

The app follows Apple's iPad navigation conventions:

- **Tab bar on top, a sidebar inside each tab.** The tabs use `.tabBarOnly`, not `.sidebarAdaptable`: the adaptable style would add a second sidebar beside each tab's page list. The HIG says to use a split view for a sidebar that never turns into a tab bar.
- **Menu bar and shortcuts.** `App/CatalogCommands.swift` adds a Go menu: ⌘1–⌘3 switch tabs, ⌘F opens Search with the field focused, and ⌘[ / ⌘] go to the previous and next page. The system adds Toggle Sidebar and Toggle Inspector. Hold ⌘ on a hardware keyboard to see them.
- **More than one window.** Long-press a sidebar row, a search result, or an overview card for "Open in New Window". Each window keeps its own tab and page.
- **Pointer.** Overview cards lift and footer links highlight under the pointer.

**Fit the page column, not the device.** Beside the sidebar on an 11-inch iPad in portrait, a page is only about 460pt wide, narrower than many iPhones. Anything wider pushes the whole page under the sidebar. Do / Don't pairs sit side by side only when both fit, so keep fixed widths in their previews to about 200pt, and check new pages on an 11-inch iPad in portrait.

## Photos and backdrops

Previews that need a photo behind them use `SceneryView`: scenes drawn in SwiftUI and rendered to images, so they work offline, never change, and raise no copyright questions. Pick the one that fits what you're showing:

| Scene | Looks like | Use it for |
| --- | --- | --- |
| `.lake` | A sunset over mountains and water | The everyday case |
| `.city` | A city at night, with lit windows | Glass refraction and dark content |
| `.meadow` | A bright summer day | Legibility: scrims, materials, Do / Don't pairs about contrast |
| `.wallpaper` | Soft color fields | A Lock Screen-style background |

In code samples, write `Image("photo")` for an asset-catalog photo.

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
xcodebuild -scheme "SwiftUI for Humans" -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/dd build
xcrun simctl install <udid> "/tmp/dd/Build/Products/Debug-iphonesimulator/SwiftUI for Humans.app"
```

Launch arguments open the app in a known state:

| Argument | Effect |
| --- | --- |
| `-tab <components\|design\|ship\|search>` | Starts on a tab |
| `-open <page id>` | Opens a page in its tab (`overview` for the current tab's overview) |
| `-search <text>` | Opens the Search tab and fills in the field |
| `-showControls` | Opens the Customize panel on a `DemoPage` |
| `-showScrubber` | Keeps the page scrubber on screen |
| `-scrollTo <anchor>` | Scrolls to a section: `preview`, `code`, `examples`, `guidelines`, `api`, `notes`, `sources`, or `outline-<heading>`. On a tab's overview, a category name or `card-<page id>` |

```sh
xcrun simctl launch <udid> com.swiftuiforhumans.app -open button -showControls
xcrun simctl launch <udid> com.swiftuiforhumans.app -tab design -open overview
```

Before you finish a page, check it on iPhone and iPad in light and dark mode.
