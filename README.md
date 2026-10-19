# SwiftUI for Humans

Apple's SwiftUI docs and Human Interface Guidelines, on one page, in plain language.

Each component gets a live preview you can tweak, code you can copy, and Apple's design advice for it, all in one place, in the spirit of [shadcn/ui](https://ui.shadcn.com). It's for people who know how to program but are new to Apple platforms.

## What's inside

117 pages in three tabs:

- **Components (79):** controls, text, layout, navigation, modifiers, data flow, animation, and blocks
- **Design (22):** foundations like color, type, dark mode, motion, and app icons; accessibility; and patterns like loading, feedback, and asking for permission
- **Ship (16):** getting through App Review: what Apple requires, common rejections, App Store Connect forms, TestFlight, and release

Across the app:

- **Live demos** with a Customize panel. The code updates as you change options.
- **Usage, examples, and Key APIs:** the 20% of each component you'll use 80% of the time
- **Guidelines** from the HIG, rewritten in plain language, with live Do / Don't previews
- **Blocks:** whole screens, like a login form, settings, or onboarding, to copy as a starting point
- **Checklists** to tick off before you submit, with links to Apple's sources and the date each page was last checked
- **Search** that understands web terms: try "dropdown", "modal", or "flexbox", or a guideline number like "5.1.1"

## Running it

You need Xcode 26 or later. The app targets iOS 26.

1. Open `SwiftUIForHumans.xcodeproj`.
2. Pick the **SwiftUI for Humans** scheme and an iPhone or iPad simulator.
3. Run.

From the command line, `scripts/build.sh ios` builds the app and `scripts/build.sh test-ios` runs the tests.

The project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`). After changing `project.yml`, run `xcodegen generate`. Adding or removing source files needs no regenerate: the sources are synchronized folders.

## Project layout

```
project.yml                 Targets and build settings (generates SwiftUIForHumans.xcodeproj)
SwiftUIForHumans/
  Shared/                   The engine every platform compiles
    App/                    Engagement, tips, About
    Catalog/                Page model, registry, page layout, code blocks, guidelines
  iOS/                      The iPhone and iPad app
    App/                    App shell: tabs (Components, Design, Ship, Search), sidebars, overview grid, in-app browser
    Catalog/                iOS-only page parts, like the phone frame
    Examples/               One file per page, grouped by category
  Resources/                Asset catalog and privacy manifest
  Config/                   Info.plist additions per platform
Tests/                      Swift Testing: Shared/ for the engine, iOS/ for the iOS pages
website/                    Marketing site, privacy policy, and support page (static HTML, deployed on Vercel)
StoreKit/                   Tips.storekit, for trying the in-app tips in the simulator
scripts/                    build.sh (builds and tests, one at a time), hero-reel.sh (the website's hero tiles)
docs/
  content-guide.md          How every page is written
  building-pages.md         How pages are built in code
  mac-prd.md                The plan for the Mac edition
```

## Contributing

To add or improve a page:

1. Read [docs/content-guide.md](docs/content-guide.md) for what goes on a page.
2. Read [docs/building-pages.md](docs/building-pages.md) for how to build it.
3. Copy one of the reference pages:
   - Button (`SwiftUIForHumans/iOS/Examples/Controls/ButtonExample.swift`) for a simple control
   - NavigationStack (`SwiftUIForHumans/iOS/Examples/Navigation/NavigationStackPage.swift`) for a container

## Support the project

SwiftUI for Humans is free. If it saved you some time, you can [buy me a coffee ☕](https://buymeacoffee.com/tylerbecks).

---

SwiftUI for Humans is an independent project. It isn't affiliated with or endorsed by Apple. Swift, SwiftUI, iOS, and the Human Interface Guidelines are Apple trademarks, used here only to describe what the app covers.
