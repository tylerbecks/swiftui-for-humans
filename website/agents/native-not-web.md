---
id: native-not-web
title: Native, Not Web
platforms: [iOS, iPadOS]
hig: https://developer.apple.com/design/human-interface-guidelines/designing-for-ios.md
reviewed: October 2026
---

# Native, Not Web

What makes an app feel like a website in a frame, and how to fix it.

Also called: web wrapper, webview, WKWebView, website in an app, wrapped website, PWA, hybrid app, hamburger menu, breadcrumbs, app-like.

## Rules

- **Put top-level sections in a tab bar.** People expect to switch sections from the bottom of the screen with one tap. A hamburger menu hides them behind an extra step.
- **Use the system navigation bar.** People expect a Back button at the top and a swipe from the edge to go back. `NavigationStack` gives you both; a web header doesn't.
- **Use system controls, not web form inputs.** A `Toggle` and a `Picker` look and behave the way they do in every other app, so nobody has to learn your version.
- **Format content for iPhone.** Apple names web content that isn't formatted for iOS as a reason apps fail. Use readable rows, not a desktop page squeezed down.

## Pitfalls

- **Use what iPhone already offers.** The HIG points to features like widgets, Siri shortcuts, Face ID sign-in, and swiping back as what makes an app feel at home.
- **Ask what the app adds.** If it offers nothing beyond what your website shows in Safari, expect App Review to ask the same question under 4.2.

## Guide

### What Apple requires

Guideline **4.2, Minimum Functionality**, asks for features, content, and interface that go beyond a repackaged website. Apps that are mostly marketing, web clippings, content aggregators, or a collection of links don't qualify (4.2.2). Guideline **4.0** sets a minimum bar for clean, easy-to-use design.

### Why

People already have Safari. They download an app because it does more, and because it works like the rest of their iPhone: tabs at the bottom, swipe to go back, system controls, Dark Mode, and their chosen text size.

## Key APIs

- `TabView` + `Tab`: Top-level sections in a bottom tab bar.
- `NavigationStack`: Push and pop screens, with back swipe.
- `NavigationLink`: A row or button that pushes a screen.
- `Toggle`: A system on/off switch.
- `Picker`: A choice from a list, instead of a select.
- `.swipeActions`: Row actions people reveal by swiping.
- `.refreshable`: Pull to refresh on a list.

## Variants

### Sections in a tab bar

Use `TabView` with one `Tab` per section, and give each tab its own `NavigationStack`.

```swift
TabView {
    Tab("Shop", systemImage: "bag") {
        NavigationStack {
            List(products) { product in
                NavigationLink(product.name) {
                    ProductView(product: product)
                }
            }
            .navigationTitle("Shop")
        }
    }
    Tab("Orders", systemImage: "shippingbox") {
        NavigationStack {
            OrdersView()
        }
    }
}
```

**Note:** Each tab keeps its own navigation history, so switching tabs and coming back returns people to where they were.

### System controls in a form

Use `Form` with `Toggle` and `Picker` instead of drawing web-style checkboxes and select boxes.

```swift
@State private var emailMe = true
@State private var size = "Medium"

Form {
    Toggle("Email Me Updates", isOn: $emailMe)
    Picker("Size", selection: $size) {
        ForEach(["Small", "Medium", "Large"], id: \.self) {
            Text($0)
        }
    }
}
```

## Related

[tab-view](tab-view.md), [navigation-stack](navigation-stack.md), [form](form.md), [toggle](toggle.md), [picker](picker.md), [appearance-check](appearance-check.md), [rejection-guide](rejection-guide.md)
