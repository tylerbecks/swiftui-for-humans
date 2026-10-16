import SwiftUI

extension ComponentPage {
    static let shipAppearanceCheck = ComponentPage(
        id: "appearance-check",
        title: "Dark Mode & Large Text",
        summary: "Before you submit, check every screen in Dark Mode and at the largest text size.",
        category: .feelsNative,
        kind: .reference,
        symbol: "circle.lefthalf.filled",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/swiftui/dynamictypesize",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/dark-mode",
        aliases: [
            "dark mode", "dark theme", "prefers-color-scheme", "light mode",
            "dynamic type", "font scaling", "rem", "text size", "larger text",
            "accessibility sizes", "AX5", "truncation", "contrast", "Guideline 4.0",
        ],
        related: ["dark-mode", "dynamic-type", "system-colors", "typography", "view-that-fits", "states-check"],
        notes: [
            "**Test on a device too.** Turn on Larger Accessibility Sizes in Settings > Accessibility > Display & Text Size > Larger Text, then drag the slider to the end.",
            "**Increase Contrast changes things again.** The HIG suggests checking Dark Mode with Increase Contrast and Reduce Transparency on, separately and together.",
        ],
        api: [
            APIItem("`.dynamicTypeSize(_:)`", "Sets or limits the text size for a view."),
            APIItem("`\\.dynamicTypeSize`", "Reads the person's current text size."),
            APIItem("`.isAccessibilitySize`", "True for the five largest sizes."),
            APIItem("`.preferredColorScheme(_:)`", "Forces light or dark, for previews."),
            APIItem("`\\.colorScheme`", "Reads whether the view is light or dark."),
            APIItem("`ViewThatFits`", "Picks the first layout that fits."),
        ],
        guidelines: [
            Guideline(
                "Follow the system appearance.",
                "People set light or dark for the whole phone. An app-only appearance setting means more work for them, and an app that ignores the setting looks broken."
            ),
            Guideline(
                "Keep contrast high in both modes.",
                "The HIG asks for a contrast ratio of at least 4.5:1, and suggests 7:1 for custom colors, especially in small text. System label colors are a safe start.",
                good: "`.secondary` text stays readable in Dark Mode.",
                bad: "A hard-coded gray almost disappears."
            ) {
                AppearanceContrastSample(isFixed: true)
            } bad: {
                AppearanceContrastSample(isFixed: false)
            },
            Guideline(
                "Don't cut text off at large sizes.",
                "At the largest sizes, show as much text as at the default size. Stack items vertically instead of truncating them.",
                good: "The row stacks, so the address fits.",
                bad: "The row truncates the address."
            ) {
                AppearanceTruncationSample(isFixed: true)
            } bad: {
                AppearanceTruncationSample(isFixed: false)
            },
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/dark-mode",
            "https://developer.apple.com/design/human-interface-guidelines/typography",
            "https://developer.apple.com/design/human-interface-guidelines/designing-for-ios",
            "https://developer.apple.com/documentation/swiftui/dynamictypesize",
            "https://developer.apple.com/documentation/swiftui/viewthatfits",
        ],
        reviewed: "October 2026"
    ) {
        AppearanceThumbnail()
    } content: { page in
        AppearanceArticle(page: page)
    }
}

// MARK: - Thumbnail

private struct AppearanceThumbnail: View {
    var body: some View {
        HStack(spacing: 10) {
            AppearanceOrderCard(isFixed: true)
                .environment(\.colorScheme, .light)
            AppearanceOrderCard(isFixed: true)
                .environment(\.colorScheme, .dark)
        }
        .frame(width: 150)
        .scaleEffect(0.62)
        .frame(height: 120)
    }
}

// MARK: - The screen being tested

/// One small "order summary" screen, written two ways: the broken version
/// hard-codes colors and font sizes, the fixed one uses system styles.
private struct AppearanceOrderCard: View {
    let isFixed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Summary")
                .font(isFixed ? .headline : .system(size: 17, weight: .semibold))
                .foregroundStyle(isFixed ? AnyShapeStyle(.primary) : AnyShapeStyle(Color.black))

            if isFixed {
                ViewThatFits(in: .horizontal) {
                    HStack {
                        Text("Deliver to")
                        Spacer()
                        Text("12 Harbour St").foregroundStyle(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Deliver to")
                        Text("12 Harbour St").foregroundStyle(.secondary)
                    }
                }
            } else {
                HStack {
                    Text("Deliver to")
                    Spacer()
                    Text("12 Harbour St").foregroundStyle(Color.gray)
                }
                .lineLimit(1)
                .foregroundStyle(Color.black)
            }

            Divider()

            if isFixed {
                ViewThatFits(in: .horizontal) {
                    HStack {
                        Text("Total")
                        Spacer()
                        Text("$24.00")
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total")
                        Text("$24.00")
                    }
                }
                .bold()
            } else {
                HStack {
                    Text("Total").bold()
                    Spacer()
                    Text("$24.00").bold()
                }
                .foregroundStyle(Color.black)
                .lineLimit(1)
            }

            Text("Arrives Thursday")
                .font(isFixed ? .footnote : .system(size: 12))
                .foregroundStyle(isFixed ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color(white: 0.3)))
        }
        .font(isFixed ? .body : .system(size: 16))
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.fill.tertiary, in: .rect(cornerRadius: 14))
    }
}

// MARK: - Page

private enum AppearanceTextSize: String, CaseIterable, Identifiable {
    case standard = "Default"
    case largest = "Largest"
    case accessibility = "AX5"

    var id: Self { self }

    var size: DynamicTypeSize {
        switch self {
        case .standard: .large
        case .largest: .xxxLarge
        case .accessibility: .accessibility5
        }
    }
}

private struct AppearanceArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("People pick Dark Mode and their text size once, for the whole phone, and expect every app to follow. Bugs here are easy to miss, because you probably develop in light mode at the default size. Make these two checks part of every submission.")

            SectionTitle("Try it")
            Prose("Switch the screen below between broken and fixed, then turn on Dark Mode and the largest text.")
            AppearanceLab()
            Aside(.important, "Hard-coded `Color.black` text disappears in Dark Mode, and `.system(size:)` fonts stay the same size when people pick larger text (try AX5 above). Both look fine until someone changes a setting.")

            SectionTitle("In SwiftUI")
            ExampleCard(
                title: "Preview both in Xcode",
                caption: "Add a second `#Preview` with `.preferredColorScheme(.dark)` and a large `.dynamicTypeSize` to see both while you work.",
                code: """
                #Preview("Light") {
                    OrderSummary()
                }

                #Preview("Dark, largest text") {
                    OrderSummary()
                        .preferredColorScheme(.dark)
                        .dynamicTypeSize(.accessibility3)
                }
                """,
                minHeight: 200
            ) {
                VStack(spacing: 12) {
                    AppearanceOrderCard(isFixed: true)
                        .padding(10)
                        .background(Color.white, in: .rect(cornerRadius: 22))
                        .environment(\.colorScheme, .light)
                    AppearanceOrderCard(isFixed: true)
                        .padding(10)
                        .background(Color.black, in: .rect(cornerRadius: 22))
                        .environment(\.colorScheme, .dark)
                        .dynamicTypeSize(.accessibility3)
                }
                .frame(maxWidth: 340)
            }

            ExampleCard(
                title: "Colors that adapt",
                caption: "Use `.primary`, `.secondary`, and `.fill` styles instead of fixed colors. They switch automatically between light and dark.",
                code: """
                VStack(alignment: .leading) {
                    Text("Deliver to")
                    Text("12 Harbour St")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.fill.tertiary,
                            in: .rect(cornerRadius: 12))
                """
            ) {
                HStack(spacing: 12) {
                    ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
                        VStack(alignment: .leading) {
                            Text("Deliver to")
                            Text("12 Harbour St")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.fill.tertiary, in: .rect(cornerRadius: 12))
                        .padding(8)
                        .background(scheme == .dark ? Color.black : Color.white, in: .rect(cornerRadius: 16))
                        .environment(\.colorScheme, scheme)
                    }
                }
            }

            ExampleCard(
                title: "A row that stacks when text is large",
                caption: "Wrap a row in `ViewThatFits`. It uses the side-by-side layout when it fits, and the stacked one when it doesn't.",
                code: """
                ViewThatFits(in: .horizontal) {
                    HStack {
                        Text("Deliver to")
                        Spacer()
                        Text("12 Harbour St")
                    }
                    VStack(alignment: .leading) {
                        Text("Deliver to")
                        Text("12 Harbour St")
                            .foregroundStyle(.secondary)
                    }
                }
                """,
                aside: Aside(.note, "For bigger changes, read `@Environment(\\.dynamicTypeSize)` and check `.isAccessibilitySize` to switch layouts yourself.")
            ) {
                AppearanceStackingDemo()
            }

            SectionTitle("Before you submit")
            Checklist(pageID: page.id, items: [
                ChecklistItem("dark-text", "All text is readable in Dark Mode",
                              "No dark text on a dark background.",
                              page: "dark-mode"),
                ChecklistItem("dark-images", "Images and icons show up on dark backgrounds",
                              "Check logos and illustrations with transparent edges."),
                ChecklistItem("large-text", "Text grows at the largest sizes",
                              "Every label uses a text style, not a fixed point size.",
                              page: "dynamic-type"),
                ChecklistItem("truncation", "Nothing important is cut off",
                              "Rows stack, and buttons stay on screen and tappable."),
                ChecklistItem("no-toggle", "The app follows the system setting",
                              "No separate light/dark switch that overrides it."),
            ])
        }
    }
}

private struct AppearanceLab: View {
    @State private var isFixed = false
    @State private var isDark = false
    @State private var textSize = AppearanceTextSize.standard

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                (isDark ? Color.black : Color.white)
                AppearanceOrderCard(isFixed: isFixed)
                    .frame(maxWidth: 340)
                    .padding(20)
                    .environment(\.colorScheme, isDark ? .dark : .light)
                    .dynamicTypeSize(textSize.size)
                    .animation(.default, value: isFixed)
            }
            .frame(minHeight: 260)

            Divider()

            VStack(spacing: 12) {
                Picker("Version", selection: $isFixed) {
                    Text("Broken").tag(false)
                    Text("Fixed").tag(true)
                }
                .pickerStyle(.segmented)
                Toggle("Dark Mode", isOn: $isDark)
                Picker("Text Size", selection: $textSize) {
                    ForEach(AppearanceTextSize.allCases) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(16)
            .background(Surface.code)
        }
        .cardStyle()
    }
}

private struct AppearanceStackingDemo: View {
    @State private var isLarge = true

    var body: some View {
        VStack(spacing: 16) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    Text("Deliver to")
                    Spacer()
                    Text("12 Harbour St")
                }
                VStack(alignment: .leading) {
                    Text("Deliver to")
                    Text("12 Harbour St")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: 280, alignment: .leading)
            .dynamicTypeSize(isLarge ? .accessibility3 : .large)
            .animation(.default, value: isLarge)

            Toggle("Large text", isOn: $isLarge)
                .frame(maxWidth: 280)
                .font(.subheadline)
        }
    }
}

// MARK: - Do / Don't samples

private struct AppearanceContrastSample: View {
    let isFixed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Arrives Thursday")
                .font(.headline)
            Text("Leave at the front door")
                .foregroundStyle(isFixed ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color(white: 0.25)))
        }
        .padding(14)
        .frame(maxWidth: 240, alignment: .leading)
        .background(Color.black, in: .rect(cornerRadius: 12))
        .environment(\.colorScheme, .dark)
    }
}

private struct AppearanceTruncationSample: View {
    let isFixed: Bool

    var body: some View {
        Group {
            if isFixed {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Deliver to")
                    Text("12 Harbour St").foregroundStyle(.secondary)
                }
            } else {
                HStack {
                    Text("Deliver to")
                    Spacer()
                    Text("12 Harbour St").foregroundStyle(.secondary)
                }
                .lineLimit(1)
            }
        }
        .dynamicTypeSize(.accessibility2)
        .frame(width: 230, alignment: .leading)
    }
}
