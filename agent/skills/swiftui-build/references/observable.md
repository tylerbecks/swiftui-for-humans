---
id: observable
title: @Observable
platforms: [iOS, iPadOS, macOS]
availability: iOS 17.0+, macOS 14.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app.md
---

# @Observable

Turns a class into a shared model that views watch and redraw from automatically.

## Contents

- Pitfalls
- Guide
- Key APIs
- Variants
- On macOS
- Related

## Pitfalls

- **Every stored property is tracked.** There's no `@Published` or `objectWillChange`. Mark a property `@ObservationIgnored` to leave it out.
- **Pass models down as plain properties.** Add `@Bindable` only when a child needs `$model.property` for a control like `TextField`.
- **Inject environment models near the root.** Reading `@Environment(Model.self)` when no ancestor called `.environment(model)` crashes the app.

## Guide

`@State` works for a value one view owns. When several views need the same data, put it in a class marked `@Observable`. It's like a store in React: views read from it, and SwiftUI redraws each one when what it read changes.

### Coming from ObservableObject?

Tutorials written before iOS 17 use `ObservableObject`. Here's how each piece maps to the new way:

## Key APIs

`@Observable class Model`, `@State private var model = Model()`, `@Bindable var model: Model`, `.environment(model)`, `@Environment(Model.self)`, `@ObservationIgnored`

## Variants

### A model, its owner, and two views

The screen owns the model in `@State`, the card reads it, and the editor binds to it with `@Bindable`.

```swift
@Observable
class Profile {
    var name = "Taylor"
    var likes = 12
}

struct ProfileScreen: View {
    @State private var profile = Profile()

    var body: some View {
        VStack(spacing: 16) {
            ProfileCard(profile: profile)
            ProfileEditor(profile: profile)
        }
    }
}

struct ProfileCard: View {
    let profile: Profile

    var body: some View {
        HStack {
            Text(profile.name)
                .font(.title3.bold())
            Spacer()
            Button("\(profile.likes)", systemImage: "heart.fill") {
                profile.likes += 1
            }
            .tint(.pink)
        }
    }
}

struct ProfileEditor: View {
    @Bindable var profile: Profile

    var body: some View {
        TextField("Name", text: $profile.name)
            .textFieldStyle(.roundedBorder)
    }
}
```

**Important:** Create the model with `@State private var`, not `let profile = Profile()`. Views are recreated constantly, and a plain property would make a fresh, empty model each time.

## On macOS

One model class that every window, sidebar, and inspector reads and updates.

### Pitfalls

- **Views update only for what their `body` reads.** A view that shows a title redraws when the title changes, not when some other property of the same model does.
- **A missing model is a crash.** Reading `@Environment(Model.self)` when no view above put one there stops the app. Declare the property as `Model?` where it may be missing.
- **Replaces `ObservableObject` for new code.** No `@Published`, `@StateObject`, or `@EnvironmentObject`: use `@State`, `@Bindable`, and `@Environment(Model.self)`.

### Key APIs

`@Bindable var model`

### Variants

#### Create it once, share it with every scene

Own the model with `@State` in your `App`, then pass it to each scene with `.environment(_:)`. Every window and Settings get the same instance.

```swift
@Observable
class ReadingList {
    var articles: [Article] = []
    var showsUnreadCount = true

    var unreadCount: Int {
        articles.filter { !$0.isRead }.count
    }
}

struct Article: Identifiable {
    let id = UUID()
    var title: String
    var isRead = false
}

@main
struct ReaderApp: App {
    @State private var readingList = ReadingList()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(readingList)

        Settings {
            SettingsView()
        }
        .environment(readingList)
    }
}
```

**Note:** Change the setting in the small window and the toolbar of the other one follows. They read the same model.

#### Edit it with @Bindable

Declare the view's model `@Bindable` to get bindings like `$article.title` for controls, such as the fields in an inspector.

```swift
@Observable
class EditableArticle {
    var title = "Designing for the Mac"
    var author = "Sam Lee"
    var isRead = false
}

struct ArticleInspector: View {
    @Bindable var article: EditableArticle

    var body: some View {
        Form {
            TextField("Title", text: $article.title)
            TextField("Author", text: $article.author)
            Toggle("Read", isOn: $article.isRead)
        }
    }
}
```

#### Read it from the environment

Deep in the view tree, read the model with `@Environment(ReadingList.self)`. For bindings, wrap it in a local `@Bindable` inside `body`.

```swift
struct UnreadSettings: View {
    @Environment(ReadingList.self) private var readingList

    var body: some View {
        @Bindable var readingList = readingList
        Form {
            Toggle("Show unread count", isOn: $readingList.showsUnreadCount)
            LabeledContent("Unread", value: readingList.unreadCount, format: .number)
        }
    }
}
```

More variants, left out to keep this file short: Views only watch what they read, Share a model through the environment, Leave a property out with @ObservationIgnored (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app.md

## Related

[state](state.md), [environment](environment.md), [view-updates](view-updates.md), [choosing-wrappers](choosing-wrappers.md), [state-binding](state-binding.md), [window-group](window-group.md), [settings-scene](settings-scene.md), [inspector](inspector.md)
