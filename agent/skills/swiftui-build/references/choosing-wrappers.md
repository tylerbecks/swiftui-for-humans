---
id: choosing-wrappers
title: Which Wrapper?
platforms: [iOS, iPadOS]
availability: iOS 17.0+, macOS 14.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/model-data.md
---

# Which Wrapper?

Answer two questions to pick the right property wrapper for your data.

Also called: property wrapper, state management, useState vs props, which one, data flow, @StateObject vs @ObservedObject, store, context, cheat sheet.

## Pitfalls

- **Start with the smallest tool.** A plain `let` for read-only input, `@State` for a value the view owns. Reach for an `@Observable` class only when several screens share data.
- **`$` turns a property into a `Binding`.** It works on `@State`, `@Binding`, and `@Bindable` properties, and it's what controls like `Toggle` and `TextField` take.

## Guide

Picking the wrong property wrapper is the most common cause of "why isn't my view updating?" bugs. The right one depends on two things: **who owns the data**, and **who needs to change it**.

### Cheat sheet

**Important:** Give each piece of data one owner. If two views each keep their own `@State` for the same thing, they drift apart. Move it up to their nearest common parent and pass it down.

### Older names you'll see

Tutorials from before iOS 17 use `ObservableObject`. It still works, but new code uses the simpler `@Observable` versions:

## Related

[state](state.md), [binding](binding.md), [observable](observable.md), [environment](environment.md)
