import SwiftUI

extension ComponentPage {
    static let windowsLayout = ComponentPage(
        id: "windows-layout",
        title: "Windows & Layout",
        summary: "Lay out windows that people move, resize, and stack beside other apps.",
        category: .foundations,
        kind: .concept,
        symbol: "macwindow",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/swiftui/windows",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/layout",
        aliases: ["window size", "resize", "resizing", "margins", "padding", "layout", "minimum size", "default size", "key window", "main window", "inactive window", "bottom bar", "status bar", "NSWindow", "responsive", "safe area"],
        related: ["window-group", "window-style", "opening-windows", "split-views", "view-that-fits", "toolbar", "full-screen"],
        notes: [
            "**Try the smallest and largest sizes first.** Apple suggests testing the extremes before the sizes in between, since that's where clipping shows up.",
            "**People decide where windows go.** People typically run several apps at once, so don't count on your window filling the screen or staying where it opened.",
        ],
        api: [
            APIItem("`.defaultSize(width:height:)`", "The size a new window opens at."),
            APIItem("`.windowResizability(_:)`", "Lets the content's size limit the window's."),
            APIItem("`.frame(minWidth:minHeight:)`", "The smallest size your layout supports."),
            APIItem("`.scenePadding()`", "The Mac's recommended margin around a window's content."),
            APIItem("`ViewThatFits`", "Picks the first layout that fits the width."),
            APIItem("`\\.appearsActive`", "False while the window isn't key."),
            APIItem("`.backgroundExtensionEffect()`", "Mirrors artwork under the sidebar."),
        ],
        guidelines: [
            Guideline(
                "Keep important controls away from the bottom edge.",
                "People often drag a window partly below the screen, which hides whatever sits at its bottom. Put actions in the toolbar or near the top.",
                good: "Share sits in the toolbar.",
                bad: "Share sits in a bar at the bottom."
            ) {
                MacWindowFrame(title: "Trip Notes", width: 250, height: 120) {
                    MacLayoutLines()
                } toolbar: {
                    Image(systemName: "square.and.arrow.up")
                }
            } bad: {
                MacWindowFrame(title: "Trip Notes", width: 250, height: 120) {
                    VStack(spacing: 0) {
                        MacLayoutLines()
                        Divider()
                        HStack {
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 24)
                        .background(.bar)
                    }
                }
            },
            Guideline(
                "Put what matters most at the top leading corner.",
                "People read a window from the top and from the leading side, so the first thing they should see goes there."
            ),
            Guideline(
                "Use a bottom bar only for a little status.",
                "A bottom bar suits a short summary of the window, like a count of items. If you have more to show, use an inspector instead."
            ),
            Guideline(
                "Let the system draw the window.",
                "People know the standard frame, buttons, and title bar. A custom copy that doesn't match exactly makes the whole app feel broken."
            ),
            Guideline(
                "Open new windows when they help, not by default.",
                "A second window is great for comparing or keeping context, like a draft beside the message it answers. Offer Open in New Window in the File menu or a context menu instead of opening one every time."
            ),
            Guideline(
                "Call it a window.",
                "In anything people read, say window, whatever kind it is. Words like scene describe your code, not what people see."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/layout",
            "https://developer.apple.com/design/human-interface-guidelines/windows",
            "https://developer.apple.com/documentation/swiftui/scene/defaultsize(width:height:)",
            "https://developer.apple.com/documentation/swiftui/scene/windowresizability(_:)",
            "https://developer.apple.com/documentation/swiftui/view/scenepadding(_:)",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/appearsactive",
            "https://developer.apple.com/documentation/swiftui/view/backgroundextensioneffect()",
        ],
        reviewed: "October 2026"
    ) {
        MacWindowFrame(title: "", width: 150, height: 100) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.tint.opacity(0.25))
                    .frame(width: 34)
                VStack(alignment: .leading, spacing: 5) {
                    ForEach([1.0, 0.7, 0.85], id: \.self) { width in
                        Capsule()
                            .fill(.secondary.opacity(0.4))
                            .frame(width: 80 * width, height: 5)
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(8)
        }
    } content: { page in
        MacWindowsLayoutArticle(page: page)
    }
}

extension Catalog {
    /// A window whose layout switches between side by side and stacked.
    static let windowsLayoutDemoWindow = DemoWindow(id: "windows-layout-adaptive", title: "Adaptive Layout", size: CGSize(width: 640, height: 360)) {
        MacAdaptiveTripView()
            .scenePadding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Page

private struct MacWindowsLayoutArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("On the Mac, people keep several apps open at once. They move, resize, minimize, and stack windows to suit their work, so your layout has to hold up at any size you allow, next to windows from other apps.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Parts of a window")
                ConnectFacts(rows: [
                    ("Frame", "The top of the window, with the close, minimize, and zoom buttons and often a toolbar. People drag it to move the window."),
                    ("Body", "Your content. People can usually resize the window by dragging its edges."),
                    ("Bottom bar", "Rare. A thin strip under the content for a little status, like Finder's count of items and free space."),
                ])
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Resize it")
                    .id("demo")
                MacResizeDemo()
                HStack(spacing: 12) {
                    OpenDemoWindowButton(id: "windows-layout-adaptive", label: "Open in a Real Window")
                }
                .controlSize(.large)
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Window states")
                Prose("Only one window takes your typing at a time. The Mac draws the three states differently, so people can tell which window is in front and which one gets their input.")
                ConnectFacts(rows: [
                    ("Key", "The window that receives keyboard input. Its close, minimize, and zoom buttons are in color. Only one window on screen is key."),
                    ("Main", "The app's frontmost window. It's usually also key, unless a panel such as Fonts is taking input."),
                    ("Inactive", "Any window in the background. Its window buttons turn gray and it drops its materials, so it looks farther away."),
                ])
                Aside(.note, "System controls switch appearance on their own. Custom views can read `appearsActive`, as in the last example below.")
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("In SwiftUI")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Choose a starting size and a minimum",
                        caption: "Use `.defaultSize(width:height:)` on the scene for the first launch, and a minimum `.frame` on the content so the layout never breaks.",
                        code: """
                        @main
                        struct TripsApp: App {
                            var body: some Scene {
                                WindowGroup {
                                    ContentView()
                                        .frame(minWidth: 480, minHeight: 320)
                                }
                                .defaultSize(width: 900, height: 600)
                            }
                        }
                        """,
                        minHeight: 200
                    ) {
                        MacWindowFrame(title: "Trips", width: 360, height: 170) {
                            VStack(spacing: 6) {
                                Text("Opens at 900 × 600")
                                    .font(.headline)
                                Text("Can't shrink below 480 × 320")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    ExampleCard(
                        title: "Size the window to its content",
                        caption: "Use `.windowResizability(.contentSize)` for a window that should stay the size of what's inside, like a small utility window.",
                        code: """
                        Window("Converter", id: "converter") {
                            ConverterView()
                                .frame(width: 320, height: 160)
                        }
                        .windowResizability(.contentSize)
                        """,
                        minHeight: 190
                    ) {
                        MacWindowFrame(title: "Converter", width: 320, height: 150) {
                            MacConverterSample()
                        }
                    }

                    ExampleCard(
                        title: "Use the Mac's margins",
                        caption: "Apply `.scenePadding()` to a window's root view for the recommended space around its content, instead of picking a number.",
                        code: """
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Lisbon")
                                .font(.title2)
                            Text("4 nights · 2 travelers")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .scenePadding()
                        """,
                        minHeight: 160
                    ) {
                        MacWindowFrame(title: "Trip", width: 320, height: 120) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Lisbon")
                                    .font(.title2)
                                Text("4 nights · 2 travelers")
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .scenePadding()
                        }
                    }

                    ExampleCard(
                        title: "Rearrange when the window narrows",
                        caption: "`ViewThatFits` tries each layout in order and keeps the first one that fits, so a narrow window stacks what a wide one shows side by side.",
                        code: """
                        ViewThatFits(in: .horizontal) {
                            HStack(alignment: .top, spacing: 20) {
                                TripSummary()
                                TripStops()
                            }
                            VStack(alignment: .leading, spacing: 16) {
                                TripSummary()
                                TripStops()
                            }
                        }
                        """,
                        minHeight: 200,
                        aside: Aside(.note, "Keep the same features at every size. Only how many show at once should change, not what the window can do.")
                    ) {
                        MacWindowFrame(title: "Lisbon", width: 420, height: 190) {
                            MacAdaptiveTripView()
                                .padding(14)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }

                    ExampleCard(
                        title: "Tone down custom accents in inactive windows",
                        caption: "Read `appearsActive` in a custom view, and drop accent colors while the window isn't key, the way system controls do.",
                        code: """
                        struct StatusPill: View {
                            @Environment(\\.appearsActive) private var appearsActive

                            var body: some View {
                                Text("Booked")
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .foregroundStyle(appearsActive ? .white : .secondary)
                                    .background(appearsActive ? AnyShapeStyle(.tint) : AnyShapeStyle(.fill.tertiary), in: .capsule)
                            }
                        }
                        """,
                        minHeight: 140
                    ) {
                        HStack(spacing: 32) {
                            VStack(spacing: 8) {
                                MacStatusPill()
                                    .environment(\.appearsActive, true)
                                Text("Key window").font(.caption).foregroundStyle(.secondary)
                            }
                            VStack(spacing: 8) {
                                MacStatusPill()
                                    .environment(\.appearsActive, false)
                                Text("Inactive window").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Demo

/// A window drawing with a width slider: drag it to watch the layout switch
/// from side by side to stacked.
private struct MacResizeDemo: View {
    @State private var width = 440.0

    var body: some View {
        VStack(spacing: 0) {
            MacWindowFrame(title: "Lisbon", width: width, height: 240) {
                MacAdaptiveTripView()
                    .padding(14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } toolbar: {
                Image(systemName: "square.and.arrow.up")
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 280)
            .background(Surface.preview)
            Divider()
            HStack(spacing: 12) {
                Text("Window width")
                Slider(value: $width, in: 260...480)
                Text("\(Int(width)) pt")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .frame(width: 52, alignment: .trailing)
            }
            .padding(14)
        }
        .cardStyle()
    }
}

/// A trip summary and its stops: side by side when there's room, stacked
/// when there isn't.
private struct MacAdaptiveTripView: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 20) {
                MacTripSummary()
                MacTripStops()
            }
            VStack(alignment: .leading, spacing: 12) {
                MacTripSummary()
                MacTripStops()
            }
        }
    }
}

private struct MacTripSummary: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Lisbon")
                .font(.title2)
            Text("May 12–16 · 2 travelers")
                .foregroundStyle(.secondary)
        }
        .fixedSize()
    }
}

private struct MacTripStops: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Alfama walk", systemImage: "figure.walk")
            Label("Tram 28", systemImage: "tram")
            Label("Belém", systemImage: "building.columns")
        }
        .fixedSize()
    }
}

private struct MacConverterSample: View {
    @State private var miles = 26.2

    var body: some View {
        Form {
            TextField("Miles", value: $miles, format: .number)
            LabeledContent("Kilometers") {
                Text((miles * 1.609344).formatted(.number.precision(.fractionLength(1))))
            }
        }
        .padding(16)
    }
}

private struct MacStatusPill: View {
    @Environment(\.appearsActive) private var appearsActive

    var body: some View {
        Text("Booked")
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .foregroundStyle(appearsActive ? .white : .secondary)
            .background(appearsActive ? AnyShapeStyle(.tint) : AnyShapeStyle(.fill.tertiary), in: .capsule)
    }
}

/// Placeholder lines of text for small window drawings.
private struct MacLayoutLines: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach([0.9, 0.7, 0.8], id: \.self) { fraction in
                Capsule()
                    .fill(.secondary.opacity(0.35))
                    .frame(width: 180 * fraction, height: 6)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
