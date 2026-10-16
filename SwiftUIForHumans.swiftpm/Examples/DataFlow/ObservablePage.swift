import SwiftUI
import Observation

extension ComponentPage {
    static let observable = ComponentPage(
        id: "observable",
        title: "@Observable",
        summary: "Turns a class into a shared model that views watch and redraw from automatically.",
        category: .dataFlow,
        kind: .concept,
        symbol: "eye.circle",
        availability: ["iOS 17.0+", "macOS 14.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app",
        aliases: ["store", "Redux", "Zustand", "@Bindable", "view model", "ObservableObject", "@StateObject", "@ObservedObject", "@Published", "shared state"],
        related: ["state", "environment", "view-updates", "choosing-wrappers"],
        notes: [
            "**Every stored property is tracked.** There's no `@Published` or `objectWillChange`. Mark a property `@ObservationIgnored` to leave it out.",
            "**Pass models down as plain properties.** Add `@Bindable` only when a child needs `$model.property` for a control like `TextField`.",
            "**Inject environment models near the root.** Reading `@Environment(Model.self)` when no ancestor called `.environment(model)` crashes the app.",
        ],
        api: [
            APIItem("`@Observable class Model`", "Makes every stored property observable."),
            APIItem("`@State private var model = Model()`", "Creates and owns the model in one view."),
            APIItem("`@Bindable var model: Model`", "Lets a child write `$model.name` for controls."),
            APIItem("`.environment(model)`", "Shares the model with every view below."),
            APIItem("`@Environment(Model.self)`", "Reads a shared model by its type."),
            APIItem("`@ObservationIgnored`", "Excludes a property from tracking."),
        ]
    ) {
        ObservableThumbnail()
    } content: { page in
        ObservableArticle(page: page)
    }
}

// MARK: - Thumbnail

private struct ObservableThumbnail: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("@Observable class Profile")
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(.purple)
            HStack(spacing: 10) {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 34, height: 34)
                    .overlay {
                        Text("T")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                VStack(alignment: .leading, spacing: 1) {
                    Text("Taylor")
                        .font(.headline)
                    Text("Designer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Label("12", systemImage: "heart.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.pink)
            }
            TextField("Name", text: .constant("Taylor"))
                .textFieldStyle(.roundedBorder)
                .font(.caption)
        }
        .padding(12)
        .frame(width: 210)
        .background(.background, in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.separator)
        }
    }
}

// MARK: - Models

@Observable
private final class ObservableProfile {
    var name = "Taylor"
    var likes = 12
}

@Observable
private final class ObservableStats {
    var steps = 4_200
    var water = 3
}

@Observable
private final class ObservableCart {
    var items: [String] = ["Coffee"]
    var coupon = ""
}

// MARK: - Redraw flash

private final class ObservableRenderCounter {
    var count = 0

    func next() -> Int {
        count += 1
        return count
    }
}

/// Flashes a yellow border and shows how many times `body` ran.
private struct ObservableRedrawFlash: ViewModifier {
    let renders: Int

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.yellow, lineWidth: 3)
                    .keyframeAnimator(initialValue: 0.0, trigger: renders) { view, opacity in
                        view.opacity(opacity)
                    } keyframes: { _ in
                        LinearKeyframe(1.0, duration: 0.05)
                        LinearKeyframe(0.0, duration: 0.9, timingCurve: .easeOut)
                    }
                    .allowsHitTesting(false)
            }
    }
}

private struct ObservableRenderBadge: View {
    let renders: Int

    var body: some View {
        Text("body ×\(renders)")
            .font(.caption2.monospaced())
            .foregroundStyle(.secondary)
            .contentTransition(.numericText())
    }
}

// MARK: - Article

private struct ObservableArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("`@State` works for a value one view owns. When several views need the same data, put it in a class marked `@Observable`. It's like a store in React: views read from it, and SwiftUI redraws each one when what it read changes.")

            ExampleCard(
                title: "A model, its owner, and two views",
                caption: "The screen owns the model in `@State`, the card reads it, and the editor binds to it with `@Bindable`.",
                code: """
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
                            Button("\\(profile.likes)", systemImage: "heart.fill") {
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
                """,
                aside: Aside(.important, "Create the model with `@State private var`, not `let profile = Profile()`. Views are recreated constantly, and a plain property would make a fresh, empty model each time.")
            ) {
                ObservableProfileScreen()
            }

            SectionTitle("Which wrapper goes where")
            ObservableRolesTable()

            ExampleCard(
                title: "Views only watch what they read",
                caption: "Each box flashes yellow when its `body` runs; only the view that reads the changed property redraws.",
                code: """
                @Observable
                class Stats {
                    var steps = 4_200
                    var water = 3
                }

                struct Dashboard: View {
                    @State private var stats = Stats()

                    var body: some View {
                        VStack(spacing: 12) {
                            StepsView(stats: stats)  // Reads only stats.steps
                            WaterView(stats: stats)  // Reads only stats.water
                            HStack {
                                Button("Walk") { stats.steps += 500 }
                                Button("Drink") { stats.water += 1 }
                            }
                        }
                    }
                }

                struct StepsView: View {
                    let stats: Stats

                    var body: some View {
                        Label("\\(stats.steps) steps", systemImage: "figure.walk")
                    }
                }

                struct WaterView: View {
                    let stats: Stats

                    var body: some View {
                        Label("\\(stats.water) glasses", systemImage: "drop.fill")
                    }
                }
                """,
                minHeight: 240,
                aside: Aside(.note, "`Dashboard` holds the model but never reads `steps` or `water` in `body`, so it doesn't redraw at all.")
            ) {
                ObservableTrackingDemo()
            }
            .id("tracking")

            ExampleCard(
                title: "Share a model through the environment",
                caption: "Inject the model once with `.environment(cart)`, and read it anywhere below with `@Environment(Cart.self)`.",
                code: """
                @Observable
                class Cart {
                    var items: [String] = ["Coffee"]
                    var coupon = ""
                }

                struct ShopView: View {
                    @State private var cart = Cart()

                    var body: some View {
                        VStack(spacing: 14) {
                            CartBadge()
                            AddButtons()
                            CouponField()
                        }
                        .environment(cart)
                    }
                }

                struct CartBadge: View {
                    @Environment(Cart.self) private var cart

                    var body: some View {
                        VStack(spacing: 4) {
                            Label("\\(cart.items.count) items", systemImage: "cart.fill")
                                .font(.headline)
                            Text(cart.items.joined(separator: ", "))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            if !cart.coupon.isEmpty {
                                Text("Coupon: \\(cart.coupon)")
                                    .font(.footnote.bold())
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }

                struct AddButtons: View {
                    @Environment(Cart.self) private var cart

                    var body: some View {
                        HStack {
                            Button("Add tea") { cart.items.append("Tea") }
                            Button("Add cake") { cart.items.append("Cake") }
                        }
                        .buttonStyle(.bordered)
                    }
                }

                struct CouponField: View {
                    @Environment(Cart.self) private var cart

                    var body: some View {
                        @Bindable var cart = cart
                        TextField("Coupon code", text: $cart.coupon)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                """,
                aside: Aside(.note, "An `@Environment` property can't give you `$cart.coupon`. Write `@Bindable var cart = cart` at the top of `body` to get bindings.")
            ) {
                ObservableShopView()
            }
            .id("cart")

            SectionTitle("Coming from ObservableObject?")
            Prose("Tutorials written before iOS 17 use `ObservableObject`. Here's how each piece maps to the new way:")
            ObservableMigrationTable()
        }
    }
}

// MARK: - Example 1

private struct ObservableProfileScreen: View {
    @State private var profile = ObservableProfile()

    var body: some View {
        VStack(spacing: 16) {
            ObservableProfileCard(profile: profile)
            ObservableProfileEditor(profile: profile)
        }
        .frame(maxWidth: 300)
    }
}

private struct ObservableProfileCard: View {
    let profile: ObservableProfile

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

private struct ObservableProfileEditor: View {
    @Bindable var profile: ObservableProfile

    var body: some View {
        TextField("Name", text: $profile.name)
            .textFieldStyle(.roundedBorder)
    }
}

// MARK: - Roles table

private struct ObservableRolesTable: View {
    private let rows: [(String, String, String)] = [
        ("Creates the model", "@State private var model = Model()", "purple"),
        ("Only reads it", "let model: Model", "blue"),
        ("Edits it with $", "@Bindable var model: Model", "green"),
        ("Reads it from far below", "@Environment(Model.self) var model", "orange"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 { Divider() }
                VStack(alignment: .leading, spacing: 4) {
                    Text(row.0)
                        .font(.subheadline.weight(.semibold))
                    Text(row.1)
                        .font(.footnote.monospaced())
                        .foregroundStyle(color(row.2))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .cardStyle()
    }

    private func color(_ name: String) -> Color {
        switch name {
        case "purple": .purple
        case "blue": .blue
        case "green": .green
        default: .orange
        }
    }
}

// MARK: - Example 2 (tracking)

private struct ObservableTrackingDemo: View {
    @State private var stats = ObservableStats()
    @State private var counter = ObservableRenderCounter()

    var body: some View {
        let renders = counter.next()
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Dashboard")
                    .font(.subheadline.bold())
                Spacer()
                ObservableRenderBadge(renders: renders)
            }
            ObservableStepsView(stats: stats)
            ObservableWaterView(stats: stats)
            HStack {
                Button("Walk", systemImage: "figure.walk") { stats.steps += 500 }
                Button("Drink", systemImage: "drop.fill") { stats.water += 1 }
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(.fill.quaternary, in: .rect(cornerRadius: 12))
        .modifier(ObservableRedrawFlash(renders: renders))
        .frame(maxWidth: 320)
    }
}

private struct ObservableStepsView: View {
    let stats: ObservableStats
    @State private var counter = ObservableRenderCounter()

    var body: some View {
        let renders = counter.next()
        HStack {
            Label("\(stats.steps) steps", systemImage: "figure.walk")
                .monospacedDigit()
            Spacer()
            ObservableRenderBadge(renders: renders)
        }
        .padding(10)
        .background(.background, in: .rect(cornerRadius: 12))
        .modifier(ObservableRedrawFlash(renders: renders))
    }
}

private struct ObservableWaterView: View {
    let stats: ObservableStats
    @State private var counter = ObservableRenderCounter()

    var body: some View {
        let renders = counter.next()
        HStack {
            Label("\(stats.water) glasses", systemImage: "drop.fill")
                .monospacedDigit()
            Spacer()
            ObservableRenderBadge(renders: renders)
        }
        .padding(10)
        .background(.background, in: .rect(cornerRadius: 12))
        .modifier(ObservableRedrawFlash(renders: renders))
    }
}

// MARK: - Example 3 (environment)

private struct ObservableShopView: View {
    @State private var cart = ObservableCart()

    var body: some View {
        VStack(spacing: 14) {
            ObservableCartBadge()
            ObservableAddButtons()
            ObservableCouponField()
        }
        .frame(maxWidth: 280)
        .environment(cart)
    }
}

private struct ObservableCartBadge: View {
    @Environment(ObservableCart.self) private var cart

    var body: some View {
        VStack(spacing: 4) {
            Label("\(cart.items.count) items", systemImage: "cart.fill")
                .font(.headline)
            Text(cart.items.joined(separator: ", "))
                .font(.footnote)
                .foregroundStyle(.secondary)
            if !cart.coupon.isEmpty {
                Text("Coupon: \(cart.coupon)")
                    .font(.footnote.bold())
                    .foregroundStyle(.green)
            }
        }
    }
}

private struct ObservableAddButtons: View {
    @Environment(ObservableCart.self) private var cart

    var body: some View {
        HStack {
            Button("Add tea") { cart.items.append("Tea") }
            Button("Add cake") { cart.items.append("Cake") }
        }
        .buttonStyle(.bordered)
    }
}

private struct ObservableCouponField: View {
    @Environment(ObservableCart.self) private var cart

    var body: some View {
        @Bindable var cart = cart
        TextField("Coupon code", text: $cart.coupon)
            .textFieldStyle(.roundedBorder)
    }
}

// MARK: - Migration table

private struct ObservableMigrationTable: View {
    private let rows: [(String, String)] = [
        ("class Model: ObservableObject", "@Observable class Model"),
        ("@Published var name", "var name"),
        ("@StateObject var model", "@State var model"),
        ("@ObservedObject var model", "let model / @Bindable var model"),
        ("@EnvironmentObject var model", "@Environment(Model.self) var model"),
        (".environmentObject(model)", ".environment(model)"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 { Divider() }
                VStack(alignment: .leading, spacing: 3) {
                    Text(row.0)
                        .strikethrough(color: .secondary)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Image(systemName: "arrow.turn.down.right")
                            .foregroundStyle(.green)
                            .accessibilityHidden(true)
                        Text(row.1)
                    }
                }
                .font(.footnote.monospaced())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        .cardStyle()
    }
}
