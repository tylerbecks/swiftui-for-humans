# SwiftUI for Humans

Apple's SwiftUI docs and Human Interface Guidelines, on one page, in plain language.

Each component gets a live preview you can tweak, code you can copy, and Apple's design advice for it, all in one place, in the spirit of [shadcn/ui](https://ui.shadcn.com). It's for people who know how to program but are new to Apple platforms.

## What's inside

117 pages in three tabs:

- **Design (22):** foundations like color, type, dark mode, motion, and app icons; accessibility; and patterns like loading, feedback, and asking for permission
- **Build (79):** every component: controls, text, layout, navigation, modifiers, data flow, animation, and blocks
- **Ship (16):** getting through App Review: what Apple requires, common rejections, App Store Connect forms, TestFlight, and release

Across the app:

- **Live demos** with a Customize panel. The code updates as you change options.
- **Usage, examples, and Key APIs:** the 20% of each component you'll use 80% of the time
- **Guidelines** from the HIG, rewritten in plain language, with live Do / Don't previews
- **Blocks:** whole screens, like a login form, settings, or onboarding, to copy as a starting point
- **Checklists** to tick off before you submit, with links to Apple's sources and the date each page was last checked
- **Search** that understands web terms: try "dropdown", "modal", or "flexbox", or a guideline number like "5.1.1"

## For AI agents

The same knowledge, packaged for coding agents: current SwiftUI for iOS and macOS 26–27, the HIG as decision rules, App Review rules with their guideline numbers, and a linter for deprecated APIs and HIG smells. It comes as four [Agent Skills](https://agentskills.io), which load only when a task needs them:

- **swiftui-build:** components, layout, navigation, data flow, animation, and Mac windows and menus, each with default code, variants, and pitfalls
- **apple-design:** color, type, Liquid Glass, accessibility, and patterns like modality and feedback, as rules with reasons
- **app-store-ship:** App Review, App Store Connect forms, TestFlight, sign-in, purchases, and rating prompts
- **swiftui-review:** a review checklist plus `check_swift.py`, a linter that needs only Python 3

**Any agent** (Claude Code, Codex, Cursor, Copilot, Gemini CLI, and others), with the [skills CLI](https://github.com/vercel-labs/skills):

```sh
npx skills add tylerbecks/swiftui-for-humans
```

**Claude Code** plugin, which adds a `/swiftui-review` command and a `hig-reviewer` subagent:

```
/plugin marketplace add tylerbecks/swiftui-for-humans
/plugin install swiftui-for-humans@swiftui-for-humans
```

To have Claude lint every `.swift` file it edits, also install the opt-in hook: `/plugin install swiftui-lint-hook@swiftui-for-humans`. It reports warnings and errors back to Claude after each edit. Set `SWIFTUI_LINT_TARGET` (like `"iOS 17"`) to match your deployment target. Uninstall or disable it in `/plugin` to turn it off.

**Codex:** `codex plugin marketplace add tylerbecks/swiftui-for-humans`, then install **swiftui-for-humans** from `/plugins`. Or copy the skill folders into `.agents/skills/` in your project.

**Cursor, Copilot, Gemini CLI, and other agents:** `npx skills add` above knows where each agent looks. To copy by hand, put the folders in [`agent/skills/`](agent/skills) into your project's `.agents/skills/` (Codex, Copilot) or `.github/skills/` (Copilot), or the folder your agent's docs name for skills.

**Xcode 27's coding assistant:** copy the four folders into `~/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/skills/` for Claude or `~/Library/Developer/Xcode/CodingAssistant/codex/skills/` for Codex (create the `skills` folder if it's missing), then restart Xcode.

**The primer (recommended).** Skills don't always trigger on their own. Paste [`agent/primer/AGENTS.snippet.md`](agent/primer/AGENTS.snippet.md) into your project's `AGENTS.md` or `CLAUDE.md`. It's under 8 KB: the target SDKs, the top corrections, and an index of the topic files, with an instruction to read them instead of relying on training data.

**On the web:** every topic is also a Markdown file at `swiftuiforhumans.com/agents/<id>.md`, indexed by [`/llms.txt`](https://www.swiftuiforhumans.com/llms.txt), with all of them in `/llms-full.txt` and install steps at [`/agents`](https://www.swiftuiforhumans.com/agents). A remote MCP server for chat apps (`sfh_search`, `sfh_get_topic`, `sfh_review_checklist`) lives in [`mcp/`](mcp/README.md) and isn't deployed yet.

How the pack is generated from the app's pages: [agent/README.md](agent/README.md).

## Running it

You need Xcode 26 or later. The app targets iOS 26.

1. Open `SwiftUIForHumans.xcodeproj`.
2. Pick the **SwiftUI for Humans** scheme and an iPhone or iPad simulator, or **SwiftUI for Humans (Mac)** for the Mac app.
3. Run.

From the command line, `scripts/build.sh ios` or `mac` builds an app, and `test-ios` or `test-mac` runs the tests.

The project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`). After changing `project.yml`, run `xcodegen generate`. Adding or removing source files needs no regenerate: the sources are synchronized folders.

## Project layout

```
project.yml                 Targets and build settings (generates SwiftUIForHumans.xcodeproj)
SwiftUIForHumans/
  Shared/                   The engine every platform compiles
    App/                    Engagement, tips, About
    Catalog/                Page model, registry, page layout, code blocks, guidelines
  iOS/                      The iPhone and iPad app
    App/                    App shell: tabs (Design, Build, Ship, Search), sidebars, in-app browser
    Catalog/                iOS-only page parts, like the phone frame
    Examples/               One file per page, grouped by category
    Edition.swift           The iOS categories, tab intros, and page list
  macOS/                    The Mac app, a separate edition with Mac content
    App/                    App shell: split view, Settings, menus, demo windows
    Catalog/                Mac-only page parts, like the drawn window frame
    Examples/               One folder per group of Mac pages
    Edition.swift           The Mac categories, tab intros, and page list
  Resources/                Asset catalog and privacy manifest
  Config/                   Info.plist additions per platform
Tests/                      Swift Testing: Shared/ for the engine and registry, plus iOS/ and macOS/
website/                    Marketing site, privacy policy, and support page (static HTML, deployed on Vercel)
  agents/                   The agent install page and one Markdown file per topic (generated, like llms.txt)
mcp/                        Remote MCP server for the agent topics (TypeScript, its own Vercel project)
StoreKit/                   Tips.storekit, for trying the in-app tips in the simulator
scripts/                    build.sh (builds and tests, one at a time), mac-shot.sh (Mac screenshots), hero-reel.sh (the website's hero tiles),
                            export-catalog.sh and agent-build.py (the agent pack)
agent/                      Skills, primer, linter, and plugins for AI coding agents (see agent/README.md)
  src/                      The hand-written agent sources; skills/ and primer/ are generated from them and the pages
.claude-plugin/             Claude Code marketplace (.agents/plugins/ is the Codex one)
docs/
  content-guide.md          How every page is written
  building-pages.md         How pages are built in code
  mac-prd.md                The plan for the Mac edition
  mac-content-guide.md      How Mac pages differ
```

## Contributing

Changes go through pull requests, and CI must pass; see [CONTRIBUTING.md](CONTRIBUTING.md). To report a security problem, see [SECURITY.md](SECURITY.md).

To add or improve a page:

1. Read [docs/content-guide.md](docs/content-guide.md) for what goes on a page.
2. Read [docs/building-pages.md](docs/building-pages.md) for how to build it.
3. Copy one of the reference pages:
   - Button (`SwiftUIForHumans/iOS/Examples/Controls/ButtonExample.swift`) for a simple control
   - NavigationStack (`SwiftUIForHumans/iOS/Examples/Navigation/NavigationStackPage.swift`) for a container

## License

The code is under the [MIT License](LICENSE). The written content (the agent pack, the website's agent pages, and the prose on the app's pages) is under [CC BY 4.0](LICENSE-CONTENT.md), and its code samples are MIT too.

## Support the project

SwiftUI for Humans is free. If it saved you some time, you can [buy me a coffee ☕](https://buymeacoffee.com/tylerbecks).

---

SwiftUI for Humans is an independent project. It isn't affiliated with or endorsed by Apple. Swift, SwiftUI, iOS, and the Human Interface Guidelines are Apple trademarks, used here only to describe what the app covers.
