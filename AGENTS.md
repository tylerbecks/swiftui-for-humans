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
