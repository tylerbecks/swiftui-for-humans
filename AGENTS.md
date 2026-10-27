# Agent notes

Project-specific rules for AI coding agents. Read [README.md](README.md) and [docs/building-pages.md](docs/building-pages.md) first. Source paths below are relative to `SwiftUIForHumans/`. For any page content, follow [docs/content-guide.md](docs/content-guide.md), and for Mac pages also [docs/mac-content-guide.md](docs/mac-content-guide.md).

## Rules

- **SwiftUI first.** Use UIKit only when SwiftUI has no obvious replacement (see the list in building-pages.md).
- **Keep shared code separate from pages.** `Shared/` is the engine that every edition (iOS now, macOS next) compiles, so it affects every page on every platform. It must never name a page or an edition-only type; the other platform's build catches it if it does. Platform differences in the engine go through `Shared/Catalog/Platform.swift`, and pages never use `#if os`. `iOS/` and `macOS/` each hold an app shell, an `Edition.swift` (categories, tab intros, and the page list), and their pages. When working on pages, edit only your edition's `Examples/`, and propose any shared change separately.
- **The Xcode project is generated.** `project.yml` is the source of truth; after changing it, run `xcodegen generate` and commit the regenerated `SwiftUIForHumans.xcodeproj`. Sources are synchronized folders, so adding or removing a file needs no regenerate.
- **Every code snippet must compile.** That covers Usage, ExampleCard code, generated `code`, and Do / Don't samples. Verify snippets by pasting them into a temporary `_SnippetCheck.swift` and building. Delete that file before finishing; leftover files break the unique-file-name rule.
- **Check new URLs** with `curl -sI` before adding `docsURL` or `higURL`. Both must return 200.
- **Keep `related` ids valid.** Every id in `related` must exist in the registry.
- **Don't copy Apple's text.** Guidelines are paraphrased, and the section links to the HIG.
- **No stock or Apple photos.** For anything behind glass, materials, or text, use `SceneryView(.lake)`, `.city`, `.meadow` (bright, for legibility Do / Don'ts), or `.wallpaper` from `Shared/Catalog/Scenery.swift`. Only `AsyncImage` demos load a photo from the web.

## App Store requirements

- **Export compliance.** `Config/iOS/Info.plist` (merged into the generated Info.plist through `INFOPLIST_FILE` in project.yml) sets `ITSAppUsesNonExemptEncryption` to false: the app uses only Apple's exempt encryption (HTTPS), so App Store Connect doesn't ask about it for each build. If the app ever adds its own encryption, revisit this.
- **Build numbers.** `ship beta` picks the next build number for you. When uploading any other way, raise `CURRENT_PROJECT_VERSION` in project.yml first; App Store Connect rejects a reused one. Upload with Distribute App → App Store Connect, not TestFlight Internal Only, or the build can't go to external testers or the App Store.
- **Privacy manifest.** `PrivacyInfo.xcprivacy` at the package root declares `UserDefaults` (reason CA92.1), used by `@AppStorage` and `@SceneStorage`. If you add another required-reason API (file timestamps, disk space, system boot time, active keyboards), declare it there too.
- **The in-app browser only shows Apple's sites** (`AppleSites` in `iOS/App/DocsBrowser.swift`); other links open in Safari. Unrestricted web access would raise the App Store age rating.
- **Privacy policy and support URLs** live in `AppInfo` (`Shared/App/AboutView.swift`). The pages themselves are `website/privacy.html` and `website/support.html`.
- **Keep the privacy policy true.** If the app starts storing something new or loading from a new service, update `website/privacy.html` (it lists Apple's sites, Lorem Picsum, and Apple Maps) and `PrivacyInfo.xcprivacy` in the same change.
- **The name is a known, accepted trademark risk.** Swift and SwiftUI are Apple trademarks, and [Apple's trademark guidelines](https://www.apple.com/legal/intellectual-property/guidelinesfor3rdparties.html) say not to make up names that contain them, except in a referential phrase such as "Name for SwiftUI". "SwiftUI for Humans" leads with the mark, like the approved "SwiftUI Recipes", so App Review is unlikely to reject it, but Apple could ask for a rename later. The owner chose to keep it (October 2026). If a rename is ever needed, change `PRODUCT_NAME` and `INFOPLIST_KEY_CFBundleDisplayName` in project.yml; the referential fallback is a name like "Some View for SwiftUI". Keep the not-affiliated-with-Apple notice on the About screen.

## Ratings, tips, and the buddy

- **`Shared/App/Engagement.swift`** counts page views, active days, and small successes (copying code, ticking a checklist item) on the device, and decides when to ask. Change the thresholds there.
- **Ratings use only Apple's prompt** (`requestReview`), at most once per version, at a natural break. App Review 5.6.1 disallows custom review prompts, so never put a rating ask in the buddy or behind a button.
- **The buddy** (`iOS/App/Buddy.swift`) peeks in from the corner to ask "Enjoying the app?". "Love it" offers tips; "Not really" offers to email feedback. It's off until the tip products exist: flip `Engagement.isBuddyEnabled`.
- **Tips are consumable in-app purchases** (`Shared/App/TipJar.swift`, IDs `com.swiftuiforhumans.app.tip.small/medium/large`). Outside the US, App Review 3.1.1 doesn't allow linking to an outside payment page like Buy Me a Coffee from the app, so the app never shows that link. Running from Xcode uses `StoreKit/Tips.storekit`, set in project.yml as the scheme's StoreKit configuration.
- **Testing:** launch with `-buddy` to show the buddy right away, `-buddy tips` to open the tip card, and `-sampleTips` for stand-in tips without StoreKit.

## Website

`website/` is plain HTML and one stylesheet, with no build step. Vercel serves it with clean URLs (`/privacy`, `/support`), and every push to `main` redeploys it. Other branches don't deploy (`git.deploymentEnabled` in `website/vercel.json` and `mcp/vercel.json`), because every deployment, even a skipped one, counts toward the Vercel account's 100 a day. Preview it with `python3 -m http.server` from that folder. The home page's showcase (`website/images/showcase/`, played by `showcase.js`) uses real recordings and screenshots from the test simulators, in both light and dark (`<name>-light` and `-dark`); the page shows the set that matches the visitor's appearance.

`website/agents/`, `website/llms.txt`, and `website/llms-full.txt` are generated by `scripts/agent-build.py`; edit the install page's template, `agent/src/web/agents.html`, instead. `vercel.json` serves the `.md` and `.txt` files as UTF-8 Markdown and plain text. The remote MCP server in `mcp/` is a separate Vercel project (TypeScript, with its own `package.json`); never add a build step or `package.json` to `website/`. The server logs nothing; if that changes, update `website/privacy.html` in the same change.

The home page's hero backdrop is a drifting masonry board (`board.js`, tiles in `website/images/hero/`) of real components from the app's debug-only `-heroReel` screen (`iOS/App/HeroReel.swift`). To add or change a tile, edit `HeroTile` there (each has a height; the width is 240 points), build, and run `scripts/hero-reel.sh <app> <iPad test sim udid>`. It needs an 11-inch iPad simulator, ffmpeg, ImageMagick, and jq. It replaces everything in `website/images/hero/`, including `tiles.js`, the list the page reads, so nothing else needs updating. The page shows stills and loads a tile's video only while it plays, so adding tiles costs little. `website/images/og.jpg` is the link preview image, a screenshot of the hero; retake it when the hero changes a lot.

## Wallpapers

Each tab has a slowly shifting wallpaper behind its title (`Wallpaper` in `Shared/Catalog/PageWallpaper.swift`). Pages don't: there it distracted from the content. The seed (the tab id) picks its colors and shape from the tab's palette, so it's the same on every launch. On iPhone the tab's wallpaper sits behind the tab's list; on iPad, behind the overview. The default look is glowing ribbons (`RibbonCanvas`); launch with `-wallpaper mesh` for the soft mesh-gradient look. The drift follows the clock through a `TimelineView` drawing one `Canvas`, which stays cheap and never gets stuck; a repeating `withAnimation` started in `onAppear` can be swallowed by a navigation push, leaving some pages still. The grain is one image made once, and scrolling only moves or fades the wallpaper. Anything that rebuilds heavy views on every scroll or timeline frame makes the list stutter. A scrim of the background color behind the title (`TextScrim`) keeps the text readable.

The website's hero board tiles (`iOS/App/HeroTiles.swift`) are real components rendered by the debug-only reel. If you change a tile, rerun `scripts/hero-reel.sh`.

## Apple docs watcher

`.github/workflows/apple-docs-watch.yml` checks every Apple page the app and the agent pack cite: daily from June through September, on Mondays the rest of the year, and by hand with `workflow_dispatch`. `scripts/apple-watch.py` (Python stdlib only) reads `apple-sources.json`, the map from each URL to the files that cite it (Swift pages, plus `agent/src/**/*.yaml` and `*.md`), plus Apple's change logs. It also watches a few index pages as sets of links, to catch pages Apple adds that the app doesn't cite yet: the HIG index and its category pages, the HIG's What's New, the SwiftUI topic index and its topic pages, and the list of change logs (`INDEXES` in the script). The lockfile keeps one hash per link. New ones show up as `new_pages` in `changes.json`, and Claude sorts them into page ideas in its PR. It fetches the pages (the `.md` version for docs and HIG pages), hashes each section, and compares the hashes with `apple-sources.lock.json`. The lockfile holds hashes and HTTP statuses only, never Apple's text. A 404 or 410, a redirect, or Apple's "Page Not Found" page counts as a change. 403, 429, and 5xx responses are throttling or outages: they're retried, then reported as fetch errors, never as changes. If more than 20% of fetches fail, the check exits 3 and writes nothing, so Claude doesn't run. When something changed, Claude runs on the same `xcode-27` image as CI with `.github/prompts/apple-docs-update.md` and opens one PR that fixes the affected pages and refreshes the lockfile. It can't edit `.github/`, `scripts/`, `project.yml`, `CODEOWNERS`, or `apple-sources.json`, and a final step fails the run if the branch touches anything outside `SwiftUIForHumans/`, `agent/`, `website/agents/`, `website/llms*.txt`, `mcp/data/`, and the two `apple-sources` files. When more than 25 pages changed, it opens a tracking issue labeled `apple-docs-flood` instead, with the run's `flood_hash` (from `changes.json`) in it; later runs with the same set of changes are skipped while that issue is open. After you add or remove an Apple link, run `python3 scripts/apple-watch.py --sources`, then `--update-lock` (add `--only <url or file>` to fetch just those pages). Run `--update-lock --from-changes changes.json` to record only the changes a check reported (the update job does this, so pages nobody reviewed stay pending), or `--update-lock` alone to re-baseline everything after reviewing by hand, and `--self-test` to check the fetch handling offline. The check writes `changes.json`, which git ignores.

## Building and checking

- Build and test with `scripts/build.sh` (`ios`, `test-ios`, `mac`, `test-mac`). It passes `-jobs 4` and `ARCHS=arm64` and holds a machine-wide lock, so builds from parallel worktrees wait their turn instead of bogging down the user's machine. Don't call `xcodebuild` directly for routine builds.
- **An agent hook checks your changes before a turn ends** (`scripts/agent-hook.sh`, wired in `.claude/settings.json` and `.codex/hooks.json`; Codex asks you to trust it once in `/hooks`). It blocks on a leftover `_SnippetCheck.swift`, a `project.yml` change without the regenerated project, a new `docsURL` or `higURL` that doesn't return 200, and a build failure in an edition whose sources changed. It skips the build when nothing changed since the last one passed. The same failures twice in a row let the turn end, so read what it reports.
- **Mac screenshots:** `scripts/mac-shot.sh <file.png> [light|dark] [launch flags]`. The debug app draws its own window off screen and quits, so it needs no Screen Recording permission and doesn't take focus. Use a tall `SIZE` (like `1100x4200`) for a whole page; the snapshot can't show a scrolled page, the sidebar, or Liquid Glass. The Mac window is a `WindowNavigator` (`macOS/App/WindowNavigator.swift`): sidebar destinations (Search, Design, Build, Ship), each area's home, category lists, and pages, with Back / Forward (⌘[ ⌘]) and a jump bar on pages. Previous / Next Page are ⌥⌘[ ⌥⌘] on the Mac. Sidebar identifiers are `dest-<area>` and `cat-<category>`.
- **Catalog export:** `scripts/export-catalog.sh` writes every page's text to `agent/build/ios.json` and `macos.json` (gitignored). `ExportCatalogTests` renders each page offscreen with the export switched on (`Shared/Catalog/CatalogExport.swift`) and writes the file when `SFH_EXPORT_DIR` is set. xcodebuild passes `TEST_RUNNER_<NAME>` variables to tests as `<NAME>`, so `TEST_RUNNER_SFH_EXPORT_DIR=<dir> scripts/build.sh test-ios` works by hand. The sandboxed Mac app attaches its file to the test results instead, and the script copies it out. New body views that show page text should report an `ExportBlock` with `.exportBlock { … }`.
- **Agent pack:** `agent/skills/` and `agent/primer/` are generated from that export plus `agent/src/` by `scripts/agent-build.py`, and committed, because people install them straight from `main`. After changing a page or anything in `agent/src/`, run `scripts/export-catalog.sh` (when pages changed), then `scripts/agent-build.py`, and commit the result; `scripts/agent-build.py --check` must pass. It enforces the token budgets and that every `related` id resolves. Never edit generated files by hand: change the page, an overlay in `agent/src/overlays/`, or a topic in `agent/src/topics/`. See [agent/README.md](agent/README.md).
- **Tests** use Swift Testing, in `Tests/Shared` (engine and registry, run by both editions), `Tests/iOS`, and `Tests/macOS`. `test-mac` runs on this Mac, no simulator. The registry tests check unique ids and that every `related` id exists, so run `scripts/build.sh test-ios` after adding pages.
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

Use conventional commits with an emoji prefix (🚀 feat, 🐛 fix, 📚 docs, 🛠️ refactor, ⚡ perf, 🧪 test, 🧹 chore), through the `commit` skill. Commit only when asked. PRs are squash-merged with their own title and description, and neither commits nor PRs carry AI attribution (`Co-authored-by`, "Generated with").

## Papercuts

When the repo itself costs you time (a misleading doc, a command that fails on a clean checkout, a missing script, a hook that misfires, a footgun config, an error message that hid the real cause), file it in one line and keep working:

```bash
scripts/papercuts.swift add "<what you hit, and what would have prevented it>" --tag <area> [--severity major] \
  [--evidence "<the command, the error line, a run or PR id, what got you past it>"]
```

- **Only repo-fixable friction:** a contributor on a fresh checkout would hit it too, and a change to code, config, scripts or docs would prevent it. Not your sandbox or network, your own typo, a flake that passed on retry, a third-party limit with no repo-side workaround, or a product bug (fix or report that as usual).
- **Severity:** `minor` (default) an annoyance, `major` cost real time, `blocker` you couldn't proceed.
- **Evidence** lets someone who wasn't there fix it: give it for anything past an obvious one-liner. Quote the failing lines, not the whole output (4 KB max; `--evidence -` reads stdin).
- **Already filed?** `scripts/papercuts.swift list` first; if it's there, `scripts/papercuts.swift again <id>` instead. Repeat hits are what review fixes first.
- **Tags** name the area: `ios`, `mac`, `engine`, `pages`, `tests`, `website`, `ship`, `hooks`, `docs`, `ci`.
- No secrets, tokens, signing details or env dumps in the text or evidence: the log is committed. Don't fix the cut mid-task unless it blocks you; `.papercuts.jsonl` is committed with your branch.

Fixing them is the `papercuts` skill, run when asked.

## Agent skills

These are for working on this repo, not the agent pack people install (`agent/`). They live in `.agents/` (`.claude/skills` and `.claude/agents` link there).

| Skill | Use |
|---|---|
| `commit` | Conventional commit with emoji, no scope |
| `pr` | Push and open a GitHub PR with a reviewer briefing |
| `babysit` | Watch a PR through Codex review, fix findings, and squash-merge it |
| `clean-code` | Review a change with the `code-reviewer` + `comment-reviewer` agents |
| `papercuts` | Triage the papercut log and fix the most-hit repo friction |

## Code Review Rules

Codex reviews every PR through its GitHub integration and follows this section. Comment `@codex review` to rerun it.

- Hold changes to the Rules above: `Shared/` never names a page or edition-only type, pages never use `#if os`, every snippet compiles, `related` ids exist, no copied Apple text, no stock or Apple photos.
- Hold the App Store requirements: ratings only through `requestReview`, the in-app browser only for Apple's sites, and a new stored value, service or required-reason API updates `website/privacy.html` and `PrivacyInfo.xcprivacy` in the same PR.
- A `project.yml` change needs the regenerated `SwiftUIForHumans.xcodeproj` in the same PR; flag hand edits to the project file.
- On a re-review (new commits on an already-reviewed PR), report only P0/P1 issues in the lines changed since your last review. Don't raise new P2s on code you already reviewed.
- Skip `.papercuts.jsonl`, `website/images/`, and generated files: the `.xcodeproj`, `agent/skills/`, `agent/primer/`, `website/agents/`, `website/llms*.txt`, and `mcp/data/`. Review the page or `agent/src/` change that produced them instead, and flag hand edits to them.
