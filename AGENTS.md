# Agent notes

Project-specific rules for AI coding agents. Read [README.md](README.md) and [docs/building-pages.md](docs/building-pages.md) first. For any page content, follow [docs/content-guide.md](docs/content-guide.md).

## Rules

- **SwiftUI first.** Use UIKit only when SwiftUI has no obvious replacement (see the list in building-pages.md).
- **Keep shared code separate from pages.** `Catalog/` and `App/` affect every page. When working on pages, edit only `Examples/`, and propose any shared change separately.
- **Every code snippet must compile.** That covers Usage, ExampleCard code, generated `code`, and Do / Don't samples. Verify snippets by pasting them into a temporary `_SnippetCheck.swift` and building. Delete that file before finishing; leftover files break the unique-file-name rule.
- **Check new URLs** with `curl -sI` before adding `docsURL` or `higURL`. Both must return 200.
- **Keep `related` ids valid.** Every id in `related` must exist in the registry.
- **Don't copy Apple's text.** Guidelines are paraphrased, and the section links to the HIG.
- **No stock or Apple photos.** For anything behind glass, materials, or text, use `SceneryView(.lake)`, `.city`, `.meadow` (bright, for legibility Do / Don'ts), or `.wallpaper` from `Catalog/Scenery.swift`. Only `AsyncImage` demos load a photo from the web.

## App Store requirements

- **Privacy manifest.** `PrivacyInfo.xcprivacy` at the package root declares `UserDefaults` (reason CA92.1), used by `@AppStorage` and `@SceneStorage`. If you add another required-reason API (file timestamps, disk space, system boot time, active keyboards), declare it there too.
- **The in-app browser only shows Apple's sites** (`AppleSites` in `App/DocsBrowser.swift`); other links open in Safari. Unrestricted web access would raise the App Store age rating.
- **Privacy policy and support URLs** live in `AppInfo` (`App/AboutView.swift`). The pages themselves are `website/privacy.html` and `website/support.html`.
- **Keep the privacy policy true.** If the app starts storing something new or loading from a new service, update `website/privacy.html` (it lists Apple's sites, Lorem Picsum, and Apple Maps) and `PrivacyInfo.xcprivacy` in the same change.
- **The name is a known, accepted trademark risk.** Swift and SwiftUI are Apple trademarks, and [Apple's trademark guidelines](https://www.apple.com/legal/intellectual-property/guidelinesfor3rdparties.html) say not to make up names that contain them, except in a referential phrase such as "Name for SwiftUI". "SwiftUI for Humans" leads with the mark, like the approved "SwiftUI Recipes", so App Review is unlikely to reject it, but Apple could ask for a rename later. The owner chose to keep it (October 2026). If a rename is ever needed, change `iOSApplication(name:)` in Package.swift; the referential fallback is a name like "Some View for SwiftUI". Keep the not-affiliated-with-Apple notice on the About screen.

## Ratings, tips, and the buddy

- **`App/Engagement.swift`** counts page views, active days, and small successes (copying code, ticking a checklist item) on the device, and decides when to ask. Change the thresholds there.
- **Ratings use only Apple's prompt** (`requestReview`), at most once per version, at a natural break. App Review 5.6.1 disallows custom review prompts, so never put a rating ask in the buddy or behind a button.
- **The buddy** (`App/Buddy.swift`) peeks in from the corner to ask "Enjoying the app?". "Love it" offers tips; "Not really" offers to email feedback. It's off until the tip products exist: flip `Engagement.isBuddyEnabled`.
- **Tips are consumable in-app purchases** (`App/TipJar.swift`, IDs `com.gobimaps.SwiftUIForHumans.tip.small/medium/large`). Outside the US, App Review 3.1.1 doesn't allow linking to an outside payment page like Buy Me a Coffee from the app, so the app never shows that link. To try purchases from Xcode, set the scheme's StoreKit Configuration to `StoreKit/Tips.storekit`.
- **Testing:** launch with `-buddy` to show the buddy right away, `-buddy tips` to open the tip card, and `-sampleTips` for stand-in tips without StoreKit.

## Website

`website/` is plain HTML and one stylesheet, with no build step. Vercel serves it with clean URLs (`/privacy`, `/support`), and every push to `main` redeploys it. Preview it with `python3 -m http.server` from that folder. The home page's showcase (`website/images/showcase/`, played by `showcase.js`) uses real recordings and screenshots from the test simulators, in both light and dark (`<name>-light` and `-dark`); the page shows the set that matches the visitor's appearance.

The home page's hero backdrop is a drifting masonry board (`board.js`, tiles in `website/images/hero/`) of real components from the app's debug-only `-heroReel` screen (`App/HeroReel.swift`). To add or change a tile, edit `HeroTile` there (each has a height; the width is 240 points), build, and run `scripts/hero-reel.sh <app> <iPad test sim udid>`. It needs an 11-inch iPad simulator, ffmpeg, ImageMagick, and jq. It replaces everything in `website/images/hero/`, including `tiles.js`, the list the page reads, so nothing else needs updating. The page shows stills and loads a tile's video only while it plays, so adding tiles costs little. `website/images/og.jpg` is the link preview image, a screenshot of the hero; retake it when the hero changes a lot.

## Wallpapers

Each tab has a slowly shifting wallpaper behind its title (`Wallpaper` in `Catalog/PageWallpaper.swift`). Pages don't: there it distracted from the content. The seed (the tab id) picks its colors and shape from the tab's palette, so it's the same on every launch. On iPhone the tab's wallpaper sits behind the tab's list; on iPad, behind the overview. The default look is glowing ribbons (`RibbonCanvas`); launch with `-wallpaper mesh` for the soft mesh-gradient look. The drift follows the clock through a `TimelineView` drawing one `Canvas`, which stays cheap and never gets stuck; a repeating `withAnimation` started in `onAppear` can be swallowed by a navigation push, leaving some pages still. The grain is one image made once, and scrolling only moves or fades the wallpaper. Anything that rebuilds heavy views on every scroll or timeline frame makes the list stutter. A scrim of the background color behind the title (`TextScrim`) keeps the text readable.

The website's hero board tiles (`App/HeroTiles.swift`) are real components rendered by the debug-only reel. If you change a tile, rerun `scripts/hero-reel.sh`.

## Building and checking

- Build with `-jobs 4` and `ARCHS=arm64`, and don't run builds in parallel. The user's machine bogs down under load.
- **Use dedicated test simulators** for screenshots and automation. Don't loop screenshots on the user's own simulator. Install the final build there once, at the end.
- [axe](https://github.com/cameroncooke/AXe) drives the app. Taps need `--tap-style physical`; the default taps don't register. Sidebar and search result rows have the identifier `row-<page id>`, and overview cards `card-<page id>`. Tab bar items are found by their label (`--label Design`).
- `print` output is buffered when the console goes to a file. For debugging, use `NSLog` with `xcrun simctl launch --console`.
- The page-specific launch flags (`-showControls`, `-scrollTo`) apply only to the first page that opens, so pushed pages don't inherit them.

## Gotchas

- A nested `NavigationStack` inside a page takes over the app's navigation bar. Use `PhoneScreen` for any preview with a title, toolbar, or search field.
- `NavigationLink`s inside `PhoneScreen` push onto the app's stack, not the frame's.
- Inline code in prose renders through `RichText`. Keep code chips under about 34 characters; longer ones wrap badly on iPhone.
- On an 11-inch iPad in portrait, the page column is about 460pt wide. Content wider than that shifts the whole page under the sidebar, so avoid fixed widths over about 200pt in Do / Don't previews.
- On iPad, long API names in Key APIs break mid-word. Use shorter names, such as `.spring(duration:)` instead of the full signature.

## Commits

Use conventional commits with an emoji prefix (🚀 feat, 🐛 fix, 📚 docs, 🛠️ refactor, ⚡ perf, 🧪 test, 🧹 chore). Commit only when asked.
