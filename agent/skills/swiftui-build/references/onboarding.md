---
id: onboarding
title: Onboarding
platforms: [iOS, iPadOS, macOS]
availability: iOS 26.0+, macOS 15.0+
docs: https://developer.apple.com/documentation/swiftui/pagetabviewstyle.md
hig: https://developer.apple.com/design/human-interface-guidelines/onboarding.md
reviewed: October 2026
---

# Onboarding

A paged welcome flow with Continue and Skip buttons that ends with Get Started.

## Contents

- Rules
- Pitfalls
- On macOS
- Related

## Rules

- **Keep it short, and always let people skip.** Three or four pages is plenty. People who would rather explore on their own should get into the app in one tap.
- **Teach by doing, not by reading.** People remember a feature they tried better than a slide that described it. Consider tips shown in context, with `TipKit`, instead of more pages.
- **Ask for permissions when the reason is clear.** If the app can't work without, say, notifications, ask during onboarding and explain why. Otherwise wait until people first use the feature.

## Pitfalls

- **Show onboarding only once.** Save completion with `@AppStorage("hasOnboarded")` and skip the flow when it's `true`. The demo uses `@State` so you can replay it.
- **Keep the page dots visible on light backgrounds.** `.indexViewStyle(.page(backgroundDisplayMode: .always))` draws a capsule behind them.

**Note:** The pager is a [TabView](tab-view.md) with `.tabViewStyle(.page)`. Each page has a `.tag`, and Continue changes the bound `selection` inside `withAnimation` so it slides like a swipe.

**Note:** Each page's symbol bounces in with a [symbol effect](symbol-effects.md), and the finished state fades in with a [transition](transitions.md). Continue is a [Button](button.md) whose title changes on the last page.

**Note:** **Why iOS 26?** Only `.buttonStyle(.glassProminent)` needs it. Change it to `.borderedProminent` and the screen runs on iOS 17.

## On macOS

Open straight into the app, and teach in context instead of up front.

### Rules

- **Open straight into the app.** People want to start right away. Skip the splash screen, or keep it brief enough to take in at a glance.
- **Teach by doing.** People remember what they try more than what they read. Let them safely perform the task you're teaching.
- **Prefer tips in context to one long tour.** A tip next to the feature, when it's relevant, is easier to absorb than a list of everything up front.
- **Make a tutorial optional, and easy to find later.** If people skip it, don't show it on every launch. Put it somewhere like the Help menu.
- **Put off setup.** Start with sensible defaults. Ask for permission when someone first uses the feature that needs it, and for ratings after they've used the app a while.
- **Leave legal text to the App Store.** The store shows agreements and disclaimers before people download. Don't open the app with them.

### Pitfalls

- **The Mac doesn't use launch screens.** iPhone and iPad apps show one while they start. A Mac app just opens its windows, so make that fast.
- **Tips are for features people haven't found.** Apple's TipKit docs say to use them sparingly, not to walk people through the app or to advertise.

### Key APIs

`.defaultLaunchBehavior(.presented)`, `.restorationBehavior(.disabled)`, `ContentUnavailableView`, `TipView`, `Tips.configure()`

### Variants

#### A welcome window when nothing is restored

A `Window` with `.defaultLaunchBehavior(.presented)` opens at launch when there are no document windows to bring back.

```swift
@main
struct ScribbleApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: NoteDocument()) { file in
            NoteEditor(document: file.$document)
        }

        Window("Welcome to Scribble", id: "welcome") {
            WelcomeView()
        }
        .defaultLaunchBehavior(.presented)
        .restorationBehavior(.disabled)
    }
}
```

**Note:** `.restorationBehavior(.disabled)` keeps the welcome window from reopening on its own along with people's documents.

#### An empty state that shows the way

Use `ContentUnavailableView` for the first, empty window: say what goes here and offer the first step.

```swift
ContentUnavailableView {
    Label("No Notes Yet", systemImage: "note.text")
} description: {
    Text("Notes you write appear here.")
} actions: {
    Button("New Note") { }
        .buttonStyle(.borderedProminent)
}
```

#### A tip beside the feature

Define a `Tip`, configure TipKit once at launch, and place a `TipView` next to what it explains.

```swift
import TipKit

struct PinTip: Tip {
    var title: Text { Text("Pin important notes") }
    var message: Text? { Text("Pinned notes stay at the top of the list.") }
    var image: Image? { Image(systemName: "pin") }
}

@main
struct NotesApp: App {
    init() {
        try? Tips.configure()
    }

    var body: some Scene {
        WindowGroup { NotesView() }
    }
}

struct NotesView: View {
    var body: some View {
        VStack {
            TipView(PinTip(), arrowEdge: .bottom)
            Button("Pin", systemImage: "pin") { }
        }
    }
}
```

**Note:** The preview draws the tip. This catalog doesn't set up TipKit, so a real `TipView` wouldn't appear here.

More variants, left out to keep this file short: Code. Apple's docs: https://developer.apple.com/documentation/swiftui/pagetabviewstyle.md

## Related

[tab-view](tab-view.md), [symbol-effects](symbol-effects.md), [button](button.md), [transitions](transitions.md), [welcome-window](welcome-window.md), [empty-states](empty-states.md), `windows-tabs` (apple-design skill), `settings-pattern` (apple-design skill), `privacy-permissions` (app-store-ship skill)
