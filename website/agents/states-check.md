---
id: states-check
title: Empty, Loading & Error
platforms: [iOS, iPadOS]
docs: https://developer.apple.com/documentation/swiftui/contentunavailableview.md
hig: https://developer.apple.com/design/human-interface-guidelines/loading.md
reviewed: October 2026
---

# Empty, Loading & Error

Give every screen an empty, loading, and error state, and ship no placeholders.

Also called: empty state, loading state, error state, skeleton, skeleton screen, spinner, placeholder, lorem ipsum, zero state, offline.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Never ship placeholder content.** Apple rejects apps with placeholder text or images under guideline 2.1. Search your project for “lorem” and “TODO” before you submit.
- **Show something right away.** The HIG warns that a blank screen looks like a broken app. Show a skeleton or a spinner while content loads.
- **Say what went wrong and what to do next.** An error should explain the problem in plain words and offer a way out, like Try Again.

## Pitfalls

- **Test with no network.** Turn on Airplane Mode and open every screen. Reviewers use real networks, and yours won't always be fast.
- **Test as a brand-new user.** A fresh account has no data, so every list starts empty. That's the first thing a reviewer with a demo account may see.

## Guide

### What Apple requires

Guideline **2.1, App Completeness**, says to submit a final version: no placeholder text, empty websites, or other temporary content, and nothing that crashes or shows obvious technical problems. As of 2026, Apple says this guideline is behind over 40% of unresolved review issues.

### Why

Real data is messy. Lists are empty on day one, networks drop, and servers fail. A screen that only handles the happy path shows a blank page or a spinner forever, and people assume the app is broken.

One screen, four states. Tap through them, or let it cycle.

### Before you submit

- **No placeholder text or images**: Search for “lorem”, “TODO”, and test images.
- **Every list has an empty state**: Explain what goes there and how to add the first item. ([empty-state](empty-state.md))
- **Every load shows progress**: A skeleton or spinner, never a blank screen. ([progress-view](progress-view.md))
- **Every error explains itself**: Plain words and a way to try again.
- **The app works offline, or says why it can't**: Open every screen in Airplane Mode.
- **Every link and button goes somewhere**: No dead links or “coming soon” screens.

## Key APIs

- `ContentUnavailableView`: Empty, no-results, and error screens.
- `.search(text:)`: A ready-made “No Results” view.
- `ProgressView`: A spinner or progress bar.
- `.redacted(reason:)`: Turns content into a skeleton.
- `.task { }`: Starts loading when the view appears.
- `.refreshable { }`: Pull to refresh to try again.

## Variants

### Model the states

Keep the screen's state in one `enum` and `switch` over it, so the compiler makes you handle every case.

```swift
enum LoadState {
    case loading
    case loaded([String])
    case failed
}

@State private var state = LoadState.loading

var body: some View {
    switch state {
    case .loading:
        ProgressView()
    case .loaded(let names) where names.isEmpty:
        ContentUnavailableView("No Friends Yet",
            systemImage: "person.2",
            description: Text("Invite someone to get started."))
    case .loaded(let names):
        List(names, id: \.self) { Text($0) }
    case .failed:
        ContentUnavailableView("Couldn't Load Friends",
            systemImage: "wifi.slash")
    }
}
```

**Note:** Start loading in `.task { }` on the view. It starts before the view appears, and SwiftUI cancels it if the view goes away first.

### A skeleton while loading

Add `.redacted(reason: .placeholder)` to sample rows so people see the layout before the data arrives.

```swift
List(sampleNames, id: \.self) { name in
    Label(name, systemImage: "person.crop.circle")
}
.redacted(reason: isLoading ? .placeholder : [])
```

**Important:** Redacted sample rows are fine while loading. Make sure they never stay on screen as the final content.

## Related

[empty-state](empty-state.md), [progress-view](progress-view.md), [async-image](async-image.md), [submission-checklist](submission-checklist.md), [rejection-guide](rejection-guide.md)
