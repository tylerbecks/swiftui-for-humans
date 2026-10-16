# SwiftUI for Humans

Apple's SwiftUI docs and Human Interface Guidelines, on one page, in plain language.

Each component gets a live preview you can tweak, code you can copy, and Apple's design advice for it, all in one place, in the spirit of [shadcn/ui](https://ui.shadcn.com). It's for people who know how to program but are new to Apple platforms.

## What's inside

- **84 pages:** controls, layout, navigation, modifiers, data flow, animation, design, and text and images
- **Live demos** with a Customize panel. The code updates as you change options.
- **Usage, examples, and Key APIs:** the 20% of each component you'll use 80% of the time
- **Guidelines** from the HIG, rewritten in plain language, with live Do / Don't previews
- **Blocks:** whole screens, like a login form, settings, or onboarding, to copy as a starting point
- **Search** that understands web terms: try "dropdown", "modal", or "flexbox"

## Running it

You need Xcode 26 or later. The app targets iOS 26.

1. Open `SwiftUIForHumans.swiftpm` in Xcode or Swift Playgrounds.
2. Pick an iPhone or iPad simulator, or **My Mac (Designed for iPad)**. The Mac option needs your team selected under Signing & Capabilities.
3. Run.

## Project layout

```
SwiftUIForHumans.swiftpm/
  App/        App shell: sidebar, search, overview grid, in-app browser
  Catalog/    Shared page building blocks: page layout, code blocks, guidelines
  Examples/   One file per page, grouped by category
docs/
  content-guide.md   How every page is written
  building-pages.md  How pages are built in code
```

## Contributing

To add or improve a page:

1. Read [docs/content-guide.md](docs/content-guide.md) for what goes on a page.
2. Read [docs/building-pages.md](docs/building-pages.md) for how to build it.
3. Copy one of the reference pages:
   - Button (`Examples/Controls/ButtonExample.swift`) for a simple control
   - NavigationStack (`Examples/Navigation/NavigationStackPage.swift`) for a container

---

SwiftUI for Humans is an independent project. It isn't affiliated with or endorsed by Apple. Swift, SwiftUI, iOS, and the Human Interface Guidelines are Apple trademarks, used here only to describe what the app covers.
