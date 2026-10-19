import SwiftUI

extension ComponentPage {
    static let shipNativeNotWeb = ComponentPage(
        id: "native-not-web",
        title: "Native, Not Web",
        summary: "What makes an app feel like a website in a frame, and how to fix it.",
        category: .feelsNative,
        kind: .reference,
        symbol: "iphone",
        availability: [],
        docsURL: nil,
        higURL: "https://developer.apple.com/design/human-interface-guidelines/designing-for-ios",
        aliases: [
            "web wrapper", "webview", "WKWebView", "website in an app", "wrapped website",
            "PWA", "hybrid app", "hamburger menu", "breadcrumbs", "app-like",
            "repackaged website", "web clipping", "collection of links", "minimum functionality",
            "Guideline 4.0", "Guideline 4.2", "Guideline 4.2.2",
        ],
        related: ["tab-view", "navigation-stack", "form", "toggle", "picker", "appearance-check", "rejection-guide"],
        notes: [
            "**Use what iPhone already offers.** The HIG points to features like widgets, Siri shortcuts, Face ID sign-in, and swiping back as what makes an app feel at home.",
            "**Ask what the app adds.** If it offers nothing beyond what your website shows in Safari, expect App Review to ask the same question under 4.2.",
        ],
        api: [
            APIItem("`TabView` + `Tab`", "Top-level sections in a bottom tab bar."),
            APIItem("`NavigationStack`", "Push and pop screens, with back swipe."),
            APIItem("`NavigationLink`", "A row or button that pushes a screen."),
            APIItem("`Toggle`", "A system on/off switch."),
            APIItem("`Picker`", "A choice from a list, instead of a select."),
            APIItem("`.swipeActions`", "Row actions people reveal by swiping."),
            APIItem("`.refreshable`", "Pull to refresh on a list."),
        ],
        guidelines: [
            Guideline(
                "Put top-level sections in a tab bar.",
                "People expect to switch sections from the bottom of the screen with one tap. A hamburger menu hides them behind an extra step.",
                good: "A tab bar shows every section, always in reach.",
                bad: "A hamburger menu hides the sections."
            ) {
                NativeTabBarDo()
            } bad: {
                NativeHamburgerDont()
            },
            Guideline(
                "Use the system navigation bar.",
                "People expect a Back button at the top and a swipe from the edge to go back. `NavigationStack` gives you both; a web header doesn't.",
                good: "A large title in the system bar.",
                bad: "A web header with breadcrumbs."
            ) {
                NativeNavBarDo()
            } bad: {
                NativeBreadcrumbsDont()
            },
            Guideline(
                "Use system controls, not web form inputs.",
                "A `Toggle` and a `Picker` look and behave the way they do in every other app, so nobody has to learn your version.",
                good: "A system toggle and picker.",
                bad: "Checkboxes and a select box from a web form."
            ) {
                NativeControlsDo()
            } bad: {
                NativeControlsDont()
            },
            Guideline(
                "Format content for iPhone.",
                "Apple names web content that isn't formatted for iOS as a reason apps fail. Use readable rows, not a desktop page squeezed down.",
                good: "Readable rows sized for the screen.",
                bad: "A desktop page with tiny text and a cookie banner."
            ) {
                NativeRowsDo()
            } bad: {
                NativeDesktopDont()
            },
        ],
        sources: [
            "https://developer.apple.com/app-store/review/guidelines/#minimum-functionality",
            "https://developer.apple.com/distribute/app-review/",
            "https://developer.apple.com/design/human-interface-guidelines/designing-for-ios",
            "https://developer.apple.com/design/human-interface-guidelines/tab-bars",
            "https://developer.apple.com/design/human-interface-guidelines/gestures",
        ],
        reviewed: "October 2026"
    ) {
        NativeThumbnail()
    } content: { page in
        NativeArticle(page: page)
    }
}

// MARK: - Thumbnail

private struct NativeThumbnail: View {
    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 6) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("Web")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Image(systemName: "arrow.right")
                .foregroundStyle(.tertiary)
            VStack(spacing: 6) {
                HStack(spacing: 10) {
                    Image(systemName: "house.fill").foregroundStyle(.tint)
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    Image(systemName: "person").foregroundStyle(.secondary)
                }
                .font(.title3)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.fill.tertiary, in: .capsule)
                Text("Native")
                    .font(.caption.weight(.semibold))
            }
        }
    }
}

// MARK: - Page

private struct NativeArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            SectionTitle("What Apple requires")
            Prose("Guideline **4.2, Minimum Functionality**, asks for features, content, and interface that go beyond a repackaged website. Apps that are mostly marketing, web clippings, content aggregators, or a collection of links don't qualify (4.2.2). Guideline **4.0** sets a minimum bar for clean, easy-to-use design.")

            SectionTitle("Why")
            Prose("People already have Safari. They download an app because it does more, and because it works like the rest of their iPhone: tabs at the bottom, swipe to go back, system controls, Dark Mode, and their chosen text size.")

            SectionTitle("How to do it")
            ExampleCard(
                title: "Sections in a tab bar",
                caption: "Use `TabView` with one `Tab` per section, and give each tab its own `NavigationStack`.",
                code: """
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
                """,
                minHeight: 300,
                aside: Aside(.note, "Each tab keeps its own navigation history, so switching tabs and coming back returns people to where they were.")
            ) {
                PhoneScreen(hasNavigationBar: false, width: 260, height: 260) {
                    TabView {
                        Tab("Shop", systemImage: "bag") {
                            NativeShopList(title: "Shop")
                        }
                        Tab("Orders", systemImage: "shippingbox") {
                            NativeShopList(title: "Orders")
                        }
                    }
                }
            }

            ExampleCard(
                title: "System controls in a form",
                caption: "Use `Form` with `Toggle` and `Picker` instead of drawing web-style checkboxes and select boxes.",
                code: """
                @State private var emailMe = true
                @State private var size = "Medium"

                Form {
                    Toggle("Email Me Updates", isOn: $emailMe)
                    Picker("Size", selection: $size) {
                        ForEach(["Small", "Medium", "Large"], id: \\.self) {
                            Text($0)
                        }
                    }
                }
                """,
                minHeight: 200
            ) {
                NativeFormPreview()
            }
        }
    }
}

// MARK: - Shared preview parts

private struct NativeShopList: View {
    let title: String

    var body: some View {
        List {
            Section {
                ForEach(["Linen Shirt", "Canvas Tote", "Desk Lamp"], id: \.self) { name in
                    HStack {
                        Text(name)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
            } header: {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.primary)
                    .textCase(nil)
                    .padding(.leading, -16)
            }
        }
        .scrollDisabled(true)
    }
}

private struct NativeFormPreview: View {
    @State private var emailMe = true
    @State private var size = "Medium"

    var body: some View {
        Form {
            Toggle("Email Me Updates", isOn: $emailMe)
            Picker("Size", selection: $size) {
                ForEach(["Small", "Medium", "Large"], id: \.self) {
                    Text($0)
                }
            }
        }
        .scrollDisabled(true)
        .frame(maxWidth: 360, minHeight: 150, maxHeight: 150)
    }
}

/// A small phone-like frame so each Do / Don't pair has the same size.
private struct NativeMiniScreen<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        DeviceFrame(width: 220, height: 200) {
            content
        }
        .scaleEffect(0.9)
        .frame(height: 200)
    }
}

// MARK: - Do / Don't: tab bar vs hamburger

private struct NativeTabBarDo: View {
    var body: some View {
        PhoneScreen(hasNavigationBar: false, width: 220, height: 200) {
            TabView {
                Tab("Home", systemImage: "house") {
                    NativeShopList(title: "MyShop")
                }
                Tab("Search", systemImage: "magnifyingglass") {
                    NativeShopList(title: "Search")
                }
                Tab("Profile", systemImage: "person") {
                    NativeShopList(title: "Profile")
                }
            }
        }
        .scaleEffect(0.9)
        .frame(height: 200)
    }
}

private struct NativeHamburgerDont: View {
    var body: some View {
        NativeMiniScreen {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "line.3.horizontal")
                    Spacer()
                    Text("MyShop").font(.headline)
                    Spacer()
                    Image(systemName: "cart")
                }
                .padding(.horizontal, 14)
                .padding(.top, 26)
                .padding(.bottom, 10)
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(["Linen Shirt", "Canvas Tote", "Desk Lamp"], id: \.self) { name in
                        Text(name)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }
}

// MARK: - Do / Don't: navigation bar vs breadcrumbs

private struct NativeNavBarDo: View {
    var body: some View {
        PhoneScreen(width: 220, height: 200) {
            List(["Order #1042", "Order #1037"], id: \.self) { order in
                Text(order)
            }
            .navigationTitle("Orders")
        }
        .scaleEffect(0.9)
        .frame(height: 200)
    }
}

private struct NativeBreadcrumbsDont: View {
    var body: some View {
        NativeMiniScreen {
            VStack(alignment: .leading, spacing: 10) {
                Text("← Back to site")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .underline()
                    .padding(.top, 26)
                Text("Home › Account › Orders")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("Orders")
                    .font(.headline)
                Text("Order #1042")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .underline()
                Text("Order #1037")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .underline()
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

// MARK: - Do / Don't: controls

private struct NativeControlsDo: View {
    @State private var emailMe = true
    @State private var size = "Medium"

    var body: some View {
        VStack(spacing: 14) {
            Toggle("Email Me Updates", isOn: $emailMe)
            HStack {
                Text("Size")
                Spacer()
                Picker("Size", selection: $size) {
                    ForEach(["Small", "Medium", "Large"], id: \.self) {
                        Text($0)
                    }
                }
                .labelsHidden()
            }
        }
        .frame(maxWidth: 260)
    }
}

private struct NativeControlsDont: View {
    @State private var emailMe = true

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                emailMe.toggle()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: emailMe ? "checkmark.square" : "square")
                    Text("Email me updates")
                }
                .font(.caption)
                .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
            HStack(spacing: 6) {
                Text("Size:")
                Text("Medium")
                    .padding(.horizontal, 4)
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 7))
                    .padding(.horizontal, 3)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.25))
            }
            .font(.caption)
            .padding(2)
            .overlay(Rectangle().stroke(Color.gray))
        }
        .frame(maxWidth: 260, alignment: .leading)
    }
}

// MARK: - Do / Don't: content formatting

private struct NativeRowsDo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(["Opening hours", "Directions", "Menu"], id: \.self) { title in
                HStack {
                    Text(title)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                if title != "Menu" {
                    Divider()
                }
            }
        }
        .frame(maxWidth: 260)
    }
}

private struct NativeDesktopDont: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack(alignment: .top, spacing: 6) {
                ForEach(["About us", "Locations", "Contact"], id: \.self) { column in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(column).font(.system(size: 7, weight: .bold))
                        Text("Visit our store for the latest news, offers, and opening times.")
                            .font(.system(size: 6))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            HStack(spacing: 4) {
                Text("We use cookies to improve your experience.")
                    .font(.system(size: 7))
                Spacer(minLength: 0)
                Text("Accept")
                    .font(.system(size: 7, weight: .semibold))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.3))
            }
            .padding(5)
            .background(Color.gray.opacity(0.15))
        }
        .frame(maxWidth: 260)
    }
}
