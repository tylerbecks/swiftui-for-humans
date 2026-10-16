import SwiftUI

extension ComponentPage {
    static let onboarding = ComponentPage(
        id: "onboarding",
        title: "Onboarding",
        summary: "A paged welcome flow with Continue and Skip buttons that ends with Get Started.",
        category: .blocks,
        kind: .block,
        symbol: "hand.wave",
        availability: ["iOS 26.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/pagetabviewstyle",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/onboarding",
        aliases: ["welcome screen", "intro", "walkthrough", "carousel", "intro slides", "swiper", "page control", "UIPageViewController", "first launch", "tutorial"],
        related: ["tab-view", "symbol-effects", "button", "transitions"],
        notes: [
            "**Show onboarding only once.** Save completion with `@AppStorage(\"hasOnboarded\")` and skip the flow when it's `true`. The demo uses `@State` so you can replay it.",
            "**Keep the page dots visible on light backgrounds.** `.indexViewStyle(.page(backgroundDisplayMode: .always))` draws a capsule behind them.",
        ],
        guidelines: [
            Guideline(
                "Keep it short, and always let people skip.",
                "Three or four pages is plenty. People who would rather explore on their own should get into the app in one tap.",
                good: "A Skip button on every page.",
                bad: "No way out but tapping through."
            ) {
                OnboardingPageSample(showsSkip: true)
            } bad: {
                OnboardingPageSample(showsSkip: false)
            },
            Guideline(
                "Teach by doing, not by reading.",
                "People remember a feature they tried better than a slide that described it. Consider tips shown in context, with `TipKit`, instead of more pages."
            ),
            Guideline(
                "Ask for permissions when the reason is clear.",
                "If the app can't work without, say, notifications, ask during onboarding and explain why. Otherwise wait until people first use the feature."
            ),
        ]
    ) {
        BlockThumbnail(hasNavigationBar: false) {
            OnboardingScreen()
        }
    } content: { page in
        BlockShowcase(
            page: page,
            tryIt: "Try it: swipe between pages or tap **Continue**. On the last page, **Get Started** finishes the flow; **Skip** jumps straight there.",
            code: onboardingSource,
            components: ["tab-view", "symbol-effects", "button", "transitions"],
            hasNavigationBar: false
        ) {
            OnboardingScreen()
        } notes: {
            Aside(.note, "The pager is a [TabView](catalog://tab-view) with `.tabViewStyle(.page)`. Each page has a `.tag`, and Continue changes the bound `selection` inside `withAnimation` so it slides like a swipe.")
            Aside(.note, "Each page's symbol bounces in with a [symbol effect](catalog://symbol-effects), and the finished state fades in with a [transition](catalog://transitions). Continue is a [Button](catalog://button) whose title changes on the last page.")
            Aside(.note, "**Why iOS 26?** Only `.buttonStyle(.glassProminent)` needs it. Change it to `.borderedProminent` and the screen runs on iOS 17.")
        }
    }
}

/// Guideline preview: a small onboarding page, with or without Skip.
private struct OnboardingPageSample: View {
    let showsSkip: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Button("Skip") {}
                    .font(.subheadline)
                    .opacity(showsSkip ? 1 : 0)
            }
            Image(systemName: "leaf.fill")
                .font(.title)
                .foregroundStyle(.green)
            Text("Track every plant")
                .font(.headline)
            Button("Continue") {}
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
        }
        .padding(14)
        .frame(width: 220)
        .background(.background, in: .rect(cornerRadius: 16))
    }
}

// <block-source>
private struct OnboardingScreen: View {
    private struct Step: Identifiable {
        let id: Int
        let symbol: String
        let color: Color
        let title: String
        let message: String
    }

    private let steps = [
        Step(id: 0, symbol: "leaf.fill", color: .green, title: "Track every plant",
             message: "Add your plants and see at a glance which ones need water today."),
        Step(id: 1, symbol: "bell.badge.fill", color: .orange, title: "Never miss a watering",
             message: "Gentle reminders arrive at the right time, based on each plant's needs."),
        Step(id: 2, symbol: "chart.line.uptrend.xyaxis", color: .blue, title: "Watch them grow",
             message: "Log photos and notes to see how your garden changes over the seasons."),
    ]

    @State private var selection = 0
    @State private var isFinished = false

    private var isLastStep: Bool {
        selection == steps.count - 1
    }

    var body: some View {
        ZStack {
            if isFinished {
                ContentUnavailableView {
                    Label {
                        Text("You're all set")
                    } icon: {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    }
                } description: {
                    Text("Your garden is ready. Add your first plant to begin.")
                } actions: {
                    Button("Show Onboarding Again") {
                        selection = 0
                        withAnimation { isFinished = false }
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            } else {
                pager
                    .transition(.opacity)
            }
        }
    }

    private var pager: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip") {
                    withAnimation { isFinished = true }
                }
                .opacity(isLastStep ? 0 : 1)
                .disabled(isLastStep)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            TabView(selection: $selection) {
                ForEach(steps) { step in
                    VStack(spacing: 24) {
                        Image(systemName: step.symbol)
                            .font(.system(size: 56, weight: .semibold))
                            .foregroundStyle(step.color.gradient)
                            .symbolEffect(.bounce, value: selection == step.id)
                            .frame(width: 136, height: 136)
                            .background(step.color.opacity(0.15), in: .circle)
                        VStack(spacing: 10) {
                            Text(step.title)
                                .font(.title2.bold())
                            Text(step.message)
                                .foregroundStyle(.secondary)
                        }
                        .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                    .tag(step.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button {
                if isLastStep {
                    withAnimation { isFinished = true }
                } else {
                    withAnimation { selection += 1 }
                }
            } label: {
                Text(isLastStep ? "Get Started" : "Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .padding(24)
        }
    }
}
// </block-source>

// <block-code>
private let onboardingSource = #"""
import SwiftUI

struct OnboardingScreen: View {
    private struct Step: Identifiable {
        let id: Int
        let symbol: String
        let color: Color
        let title: String
        let message: String
    }

    private let steps = [
        Step(id: 0, symbol: "leaf.fill", color: .green, title: "Track every plant",
             message: "Add your plants and see at a glance which ones need water today."),
        Step(id: 1, symbol: "bell.badge.fill", color: .orange, title: "Never miss a watering",
             message: "Gentle reminders arrive at the right time, based on each plant's needs."),
        Step(id: 2, symbol: "chart.line.uptrend.xyaxis", color: .blue, title: "Watch them grow",
             message: "Log photos and notes to see how your garden changes over the seasons."),
    ]

    @State private var selection = 0
    @State private var isFinished = false

    private var isLastStep: Bool {
        selection == steps.count - 1
    }

    var body: some View {
        ZStack {
            if isFinished {
                ContentUnavailableView {
                    Label {
                        Text("You're all set")
                    } icon: {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    }
                } description: {
                    Text("Your garden is ready. Add your first plant to begin.")
                } actions: {
                    Button("Show Onboarding Again") {
                        selection = 0
                        withAnimation { isFinished = false }
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            } else {
                pager
                    .transition(.opacity)
            }
        }
    }

    private var pager: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip") {
                    withAnimation { isFinished = true }
                }
                .opacity(isLastStep ? 0 : 1)
                .disabled(isLastStep)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            TabView(selection: $selection) {
                ForEach(steps) { step in
                    VStack(spacing: 24) {
                        Image(systemName: step.symbol)
                            .font(.system(size: 56, weight: .semibold))
                            .foregroundStyle(step.color.gradient)
                            .symbolEffect(.bounce, value: selection == step.id)
                            .frame(width: 136, height: 136)
                            .background(step.color.opacity(0.15), in: .circle)
                        VStack(spacing: 10) {
                            Text(step.title)
                                .font(.title2.bold())
                            Text(step.message)
                                .foregroundStyle(.secondary)
                        }
                        .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                    .tag(step.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button {
                if isLastStep {
                    withAnimation { isFinished = true }
                } else {
                    withAnimation { selection += 1 }
                }
            } label: {
                Text(isLastStep ? "Get Started" : "Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .padding(24)
        }
    }
}

#Preview {
    OnboardingScreen()
}
"""#

// MARK: - Block page parts
// Each Blocks file carries its own private copy of these, so files stay
// independent and nothing leaks into the shared module namespace.

/// The standard block page: live screen in a phone frame, what it is built
/// with (tappable links to those catalog pages), then the full source.
private struct BlockShowcase<Screen: View, Notes: View, More: View>: View {
    let page: ComponentPage
    let tryIt: String
    let code: String
    let components: [ComponentPage.ID]
    let hasNavigationBar: Bool
    let screen: Screen
    let notes: Notes
    let more: More

    @Environment(\.openPage) private var openPage
    @State private var showsFullScreen = false

    init(
        page: ComponentPage,
        tryIt: String,
        code: String,
        components: [ComponentPage.ID],
        hasNavigationBar: Bool = true,
        @ViewBuilder screen: () -> Screen,
        @ViewBuilder notes: () -> Notes,
        @ViewBuilder more: () -> More
    ) {
        self.page = page
        self.tryIt = tryIt
        self.code = code
        self.components = components
        self.hasNavigationBar = hasNavigationBar
        self.screen = screen()
        self.notes = notes()
        self.more = more()
    }

    var body: some View {
        ArticlePage(page: page) {
            VStack(alignment: .leading, spacing: 12) {
                PreviewCard(title: "Live screen", minHeight: 600) {
                    PhoneScreen(hasNavigationBar: hasNavigationBar) {
                        screen
                    }
                }
                Button {
                    showsFullScreen = true
                } label: {
                    Label("Open Full Screen", systemImage: "arrow.up.left.and.arrow.down.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .accessibilityIdentifier("open-full-screen")
                Label {
                    RichText(tryIt)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "hand.tap")
                        .foregroundStyle(.tint)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .id("live")

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Built with")
                notes
                FlowLayout(spacing: 8) {
                    ForEach(components.compactMap { Catalog.page(id: $0) }) { linked in
                        Button {
                            openPage(linked.id)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: linked.symbol)
                                Text(linked.title)
                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.secondary)
                            }
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.fill.tertiary, in: .capsule)
                            .contentShape(.capsule)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("uses-\(linked.id)")
                    }
                }
            }
            // Links written as [Form](catalog://form) in callouts open that page.
            .environment(\.openURL, OpenURLAction { url in
                guard url.scheme == "catalog", let id = url.host(), Catalog.page(id: id) != nil else {
                    return .systemAction
                }
                openPage(id)
                return .handled
            })

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Code")
                Prose(hasNavigationBar
                      ? "The complete screen, exactly as it runs above. Paste it into a new SwiftUI file and it compiles as is. Show it inside a `NavigationStack`, as the `#Preview` at the bottom does, so its title and toolbar have a bar to live in."
                      : "The complete screen, exactly as it runs above. Paste it into a new SwiftUI file and it compiles as is; then swap the sample data for your own.")
                CodeBlock(code: code)
            }
            .id("code")

            more
        }
        // A sheet starts a fresh navigation context, so pushes, the search
        // field, and the toolbar all behave exactly as in a real app.
        .sheet(isPresented: $showsFullScreen) {
            Group {
                if hasNavigationBar {
                    NavigationStack { screen }
                } else {
                    screen
                }
            }
            .presentationDragIndicator(.visible)
        }
    }
}

private extension BlockShowcase where More == EmptyView {
    init(
        page: ComponentPage,
        tryIt: String,
        code: String,
        components: [ComponentPage.ID],
        hasNavigationBar: Bool = true,
        @ViewBuilder screen: () -> Screen,
        @ViewBuilder notes: () -> Notes
    ) {
        self.init(page: page, tryIt: tryIt, code: code, components: components,
                  hasNavigationBar: hasNavigationBar, screen: screen, notes: notes) {
            EmptyView()
        }
    }
}

/// The block's real screen, scaled down for the overview card.
private struct BlockThumbnail<Screen: View>: View {
    var hasNavigationBar = true
    @ViewBuilder let screen: Screen

    var body: some View {
        PhoneScreen(hasNavigationBar: hasNavigationBar) {
            screen
        }
        .allowsHitTesting(false)
        .scaleEffect(0.44, anchor: .top)
        .frame(width: 314 * 0.44, height: 136, alignment: .top)
        .padding(.top, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
