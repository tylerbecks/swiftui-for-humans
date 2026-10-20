# Mac content guide

How to write pages for the Mac edition. Read [content-guide.md](content-guide.md) first: the page anatomy, page types, 80/20 filter, and writing rules all apply. This guide covers only what's different on the Mac. The plan behind the edition is in [mac-prd.md](mac-prd.md).

The Mac app is its own edition, not a port of the iOS one. Every page teaches the Mac: how SwiftUI looks and behaves there, the macOS Human Interface Guidelines, and shipping on the Mac App Store. Leave iPhone and iPad details out, the same way the iOS pages leave the Mac out.

Reference pages, one per page type. Copy their shape:

| Page type | Reference | File |
| --- | --- | --- |
| Simple control (`DemoPage`) | Toggle | `SwiftUIForHumans/macOS/Examples/Controls/MacTogglePage.swift` |
| Container or system (`ArticlePage`) with a demo window | Settings | `SwiftUIForHumans/macOS/Examples/WindowsNavigation/MacSettingsScenePage.swift` |
| Ship page with a checklist | App Sandbox | `SwiftUIForHumans/macOS/Examples/Ship/MacAppSandboxPage.swift` |

## Where pages go

Each group owns one folder under `SwiftUIForHumans/macOS/Examples/` and one list in its `Mac<Group>Pages.swift`. Touch only your own folder. The engine (`Shared/`), the Mac shell (`macOS/App`, `macOS/Catalog`), and `macOS/Edition.swift` are off limits; if you need a change there, say so in your report.

1. Create `Mac<Name>Page.swift` in your folder. The `Mac` prefix keeps file names unique.
2. Define `extension ComponentPage { static let <name> = ComponentPage(…) }`.
3. Add it to your group's list in `Mac<Group>Pages.swift`, in sidebar order.
4. A page that opens a real window adds a `DemoWindow` to the same file's `<group>DemoWindows` list (see Windows and toolbars).

A page's sidebar section comes from its `category`, not its folder:

| Folder (group) | Categories |
| --- | --- |
| Controls | `.controls` |
| Text | `.textInput`, `.textAndImages` |
| LayoutData | `.layout`, `.lists`, `.navigation` (Inspector only) |
| WindowsNavigation | `.windows`, `.navigation` |
| MenusInput | `.menus`, `.presentation`, `.input`, `.files` |
| EssentialsBlocks | `.dataFlow`, `.animation`, `.frameworks`, `.blocks` |
| Design | `.foundations` |
| DesignPatterns | `.accessibility`, `.patterns` |
| Ship | `.startHere`, `.feelsNative`, `.requiredByApple`, `.appStoreConnect`, `.testAndRelease` |

## Page IDs

Use these IDs, so pages can link to each other in `related` and `catalog://` links before every group is merged. Where the iOS edition has the same concept, the ID matches it.

| Group | IDs |
| --- | --- |
| Controls | `button`, `toggle`, `picker`, `menu`, `slider`, `stepper`, `date-picker`, `color-picker`, `gauge-progress`, `link`, `control-group`, `labeled-content` |
| Text | `text-field`, `secure-field`, `text-editor`, `focus-keyboard`, `text-label`, `image-symbols`, `async-image` |
| LayoutData | `stacks-grid`, `form`, `group-box`, `split-views`, `scroll-view`, `list-styles`, `table`, `outline`, `inspector`, `view-that-fits` |
| WindowsNavigation | `window-group`, `window`, `settings-scene`, `menu-bar-extra`, `document-group`, `window-style`, `opening-windows`, `navigation-split-view`, `navigation-stack`, `toolbar`, `search` |
| MenusInput | `commands`, `keyboard-shortcuts`, `context-menu`, `sheet`, `alert`, `popover`, `tooltips`, `hover`, `drag-drop`, `copy-paste`, `trackpad-gestures`, `file-import-export`, `share-link` |
| EssentialsBlocks | `state-binding`, `observable`, `environment`, `animation`, `charts-maps`, `library-window`, `settings-window`, `menu-bar-utility`, `document-editor`, `welcome-window`, `empty-states` |
| Design | `windows-layout`, `typography`, `color`, `materials`, `sf-symbols`, `dark-mode`, `app-icons`, `writing`, `motion` |
| DesignPatterns | `keyboard-access`, `voiceover`, `contrast-transparency`, `reduce-motion`, `menu-bar-conventions`, `settings-pattern`, `undo-redo`, `windows-tabs`, `toolbars-pattern`, `onboarding`, `full-screen` |
| Ship | `native-vs-catalyst`, `great-mac-app`, `mac-native-checklist`, `ipad-app-in-window`, `app-sandbox`, `privacy-permissions`, `mac-app-review`, `hardened-runtime`, `universal-purchase`, `mac-screenshots`, `pricing-category`, `testflight-mac`, `developer-id-notarization`, `updates-outside-store` |

Link only to IDs in this table. Until every group is merged, the registry test reports links to other groups' pages as missing; that's expected. Links to IDs in your own group must work.

## Words

- **Click**, not tap. **Press** a key or shortcut. **Choose** a menu item: "Choose File > New Window."
- **The Mac** in prose; **macOS** only with a version, like "macOS 26".
- **Settings**, not Preferences (renamed in macOS 13).
- Keyboard shortcuts with symbols, in this order: ⌃ Control, ⌥ Option, ⇧ Shift, ⌘ Command, as in ⌥⌘N.
- **Window**, **menu bar**, **app menu**, **toolbar**, **sidebar**, **inspector**, **pointer**.
- Web comparisons still help ("like a `<select>`"), and so do comparisons to iOS for people moving over ("the iPhone's switch").

## What's different on the Mac

- **Defaults change.** A `Toggle` is a checkbox, but a switch in a grouped `Form`. `Picker` is a pop-up button, `Form` uses columns unless you set `.formStyle(.grouped)`. Say what the default is, and show it in the demo.
- **Control sizes.** `.controlSize(.mini/.small/.regular/.large)` matters on the Mac. Offer it in a `DemoPage`'s controls when the control supports it.
- **A `DemoPage`'s controls sit inside the demo card**, beside the preview, not in an inspector. Keep them to what fits in a 280-point column: a few short sections, no long explanations.
- **Keyboard and menus** are part of most components: shortcuts, focus, Tab order, menu items. Mention them where they apply.
- **No haptics, no sheet detents, no size classes.** Don't write about them.

## Windows and toolbars

A real `NavigationSplitView`, `NavigationStack` with a title, `.toolbar`, `.searchable`, or `.inspector` inside a page lands in this app's own window. So:

- **Inline:** draw the window with `MacWindowFrame(title:width:height:) { content } toolbar: { items }`. The content is live SwiftUI; only the frame is a drawing.
- **The real thing:** declare a `DemoWindow(id:title:size:) { … }` in your group's `<group>DemoWindows` list and put `OpenDemoWindowButton(id:)` on the page. It opens a real window where toolbars, split views, and search behave for real. The Settings page shows both.
- **Scenes can't be added from a page.** `Settings`, `MenuBarExtra`, `DocumentGroup`, and `Window` are scenes in the app, so explain them with code, a `MacWindowFrame` drawing, and, where it fits, this app's own scenes (`SettingsLink` opens this app's Settings window).
- **Known issue:** a `MenuBarExtra(isInserted:)` scene keeps the main thread busy on macOS 27, even while hidden, so the app has no demo menu bar extra. Draw it instead.

## Previews and Do / Don't

- The page column is up to 760 points wide; previews have room. Keep a `MacWindowFrame` in an `ExampleCard` at 480 points wide or less.
- Do / Don't previews sit side by side, about 360 points each. Keep them under 300 points wide, and identical except for the one thing being taught.
- Previews draw on the real window background color, so controls look as they do in a window.
- Imagery: `SceneryView(.lake)`, `.city`, `.meadow`, or `.wallpaper` only, as on iOS.

## Design and Ship pages

- **Design pages** follow the **macOS** sections of the HIG. Read the page as JSON for the full text: `https://developer.apple.com/tutorials/data/design/human-interface-guidelines/<page>.json`. Write the rules in your own words.
- **Ship pages** cite App Review Guidelines by number, like Guideline 2.4.5(i) for the sandbox, plus Apple's docs. State rules only as Apple states them today. If you can't find a source, leave the rule out.
- `sources` and `reviewed: "October 2026"` are required on both. Check every URL with `curl -sI` (it must return 200). Don't edit `Shared/Catalog/SourceTitles.swift`; titles for new sources are filled in when the groups are merged.

## Check your work

1. **Build:** `scripts/build.sh mac`. Builds take turns across worktrees, so a wait is normal.
2. **Snippets:** paste every snippet (Usage, `ExampleCard` code, Do / Don't samples, and generated `code` for a typical config) into `SwiftUIForHumans/macOS/_SnippetCheck<Group>.swift`, inside `enum SnippetCheck<Group> { … }` so names don't collide, and build. Drop `@main` from app snippets. Delete the file before you finish.
3. **Screenshots:** `SIZE=1100x4200 scripts/mac-shot.sh <file>.png light -open <id>`, and again with `dark`. That captures the whole page in one image. Look at both. Snapshots can't draw Liquid Glass or the sidebar, so materials and glass pages need a check in the running app too: say so in your report.
4. **Tests:** `scripts/build.sh test-mac`. Every failure must be fixed, except a missing `related` ID that belongs to another group.
