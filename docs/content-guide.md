# Content guide

How to write a page: what goes on it and how to word it. For the code side, see [building-pages.md](building-pages.md). The goal is shadcn/ui's feel: clean, practical, and short, with links out for depth. Each page surfaces the 20% of a component that people use 80% of the time, plus Apple's design guidance for it, and leaves the rest to Apple's docs.

Reference pages: **Button** (`Examples/Controls/ButtonExample.swift`) for a simple control and **NavigationStack** (`Examples/Navigation/NavigationStackPage.swift`) for a container. When in doubt, copy their shape.

## Page anatomy

Sections render in this order. Fill in the data; the shared views handle layout.

| Section | Source | Required? |
|---|---|---|
| Title, summary, docs links | `ComponentPage` `title`, `summary`, `docsURL`, `higURL` | Always |
| Demo with attached code (collapsed) | `DemoPage` `preview`, `controls`, `code` | Components and modifiers |
| About | `ComponentPage.about` | Containers and systems only |
| Usage (code shown in full) | `DemoPage(usage:)`, optional `usageNote:` | Always on a `DemoPage` |
| Composition | `ComponentPage.composition` | Only when parts nest (containers) |
| Examples | `ExampleCard`s, each with an optional `aside:` | 2–6 per page |
| Guidelines | `ComponentPage.guidelines` | When the HIG has a matching page |
| Key APIs | `ComponentPage.api` | Most components; 4–8 rows |
| Good to know | `ComponentPage.notes` | 0–3 page-wide tips |
| Related, Previous / Next, availability | automatic | — |
| Sources, reviewed date | `ComponentPage.sources`, `reviewed` | Ship and Design pages |

## Page types

- **Simple control** (Button, Toggle, Slider): demo, Usage, 3–6 examples, guidelines, key APIs. Usually no About or Composition.
- **Container or system** (NavigationStack, List, TabView, Sheet): everything above, plus About (2–3 sentences: what it owns, when to use it versus its alternatives) and Composition.
- **Concept** (`ArticlePage`: @State, layout, modifier order): short explanation, interactive diagrams, a decision table, and examples. Use `Aside`s for common mistakes.
- **Block** (full screens): leave the structure as is.
- **Design guideline page** (Design tab: a HIG foundation or pattern, such as Color, Accessibility, or Onboarding). An `ArticlePage`:
  1. **What it is:** two or three sentences, in plain language, on what the guideline covers and why it matters on iOS.
  2. **Guidelines:** the 3–6 rules that matter most on iOS, each as a `Guideline` in our own words, with a live Do / Don't pair whenever the difference is visible.
  3. **In SwiftUI:** the APIs that implement it, as short `ExampleCard`s or Key APIs, such as `.dynamicTypeSize` or `.accessibilityLabel`.
  4. **Related:** links to the component pages that apply it, like `[Button](catalog://button)`.
  Set `higURL` to the HIG page, and add `sources` and `reviewed`.
- **Ship page** (Ship tab: something Apple checks before your app goes live, such as account deletion or privacy labels). An `ArticlePage`:
  1. **What Apple requires:** the rule in one or two plain sentences, with the guideline number.
  2. **Why:** one or two sentences on what problem it prevents for people.
  3. **How to do it:** in SwiftUI (an `ExampleCard` with code that compiles) or in App Store Connect (short numbered steps).
  4. **Do / Don't** pairs where the difference is visible, such as a sign-in screen with and without Sign in with Apple.
  5. **Checklist** (optional): the things to check before submitting, with `Checklist`.
  `sources` (the App Review Guidelines section and any Apple docs) and `reviewed` are mandatory. Put the guideline numbers in `aliases` (`"Guideline 5.1.1(v)"`) so search finds them. State rules exactly as Apple does today, never from memory; if you can't find a source, leave the rule out.

## What to include: the 80/20 filter

Include something if any of these is true:

1. A beginner will need it in their first app.
2. It's a common mistake or surprising behavior. Put it in an `Aside(.important, …)` under the example where it bites.
3. It works differently from the web. A short comparison ("like a route table") helps a web developer.

Leave out: rarely used parameters, macOS/watchOS/tvOS/visionOS-only details (unless they change iOS behavior), deprecated APIs (one "is deprecated, use X" note at most), lists of every style (the controls panel shows those), and anything the demo already makes obvious. Apple docs are one tap away.

## Writing rules

- **Summary:** one sentence, about 10–15 words, in plain language.
- **Example captions:** one sentence, about 15 words, starting with or naming the API: "Use `.toggleStyle(.button)` to…". Captions are body text, not fine print.
- **About:** two or three sentences, at most two short paragraphs.
- **Asides:** one or two sentences. Use `.note` for helpful context and `.important` only for real mistakes. Put each aside under the example it explains, not at the bottom of the page.
- **Good to know:** start with a **bold lead sentence**, then one sentence of detail. Only tips that apply to the whole page.
- **Inline code:** wrap every API, type, and value in backticks. It renders as a chip. Keep each chip under about 34 characters: a longer one can't wrap cleanly on iPhone and may widen the page.
- **Links to other pages:** `[List](catalog://list)`.
- **Voice:** plain, direct, and second person. No marketing words.

## Usage

The single most common way to use the component, in about 5–12 lines, shown in full. It should compile when pasted into a view (declare any `@State` it needs). Use `usageNote:` for the one thing people get wrong with it.

## Examples

- Each example is a real use, not a parameter tour. Prefer realistic content: "Delete Account", not "Button 2".
- The attached code must match the preview and compile when pasted.
- Order examples from most to least common.

## Guidelines (from the Human Interface Guidelines)

Read the page's HIG page (`higURL`) and pick the 2–5 best practices that matter on iOS.

- Write each one **in our own words**: a bold lead sentence, then one sentence of why. Don't copy Apple's text or images. Link to the HIG instead; the section adds the link for you.
- Add a live **Do / Don't** pair (`Guideline(_:_:good:bad:good:bad:)`) whenever the difference is visual. Keep the two previews small and identical except for the one thing being taught.
- Skip platform considerations for other platforms.

## Key APIs

4–8 rows of `APIItem("`API`", "What it does, in a few words.")`. The API name is code; the detail is under about 12 words. Don't write long lists of code chips in the detail; they wrap badly on iPhone.

## Composition

A tree drawn with `├──` and `└──`, one item per line, short enough to fit on an iPhone without scrolling sideways (about 35 characters).

## Check before you're done

- [ ] The page builds and every snippet compiles when pasted into a view.
- [ ] It matches the page type above, and every section earns its place.
- [ ] Every caption is one sentence, and every aside sits under its example.
- [ ] Guidelines are in our own words, and Do / Don't previews differ in one thing only.
- [ ] Ship and Design pages list their `sources` and a `reviewed` month, and every URL returns 200.
- [ ] Checked on an iPhone simulator in light and dark.
