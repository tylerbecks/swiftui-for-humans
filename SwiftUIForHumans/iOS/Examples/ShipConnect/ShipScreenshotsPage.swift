import SwiftUI

extension ComponentPage {
    static let shipScreenshots = ComponentPage(
        id: "screenshots",
        title: "Screenshots",
        summary: "The screenshot sizes App Store Connect requires, and how to make clean ones.",
        category: .appStoreConnect,
        kind: .reference,
        symbol: "photo.on.rectangle.angled",
        availability: [],
        docsURL: "https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/",
        aliases: [
            "app store screenshots", "screenshot sizes", "screenshot dimensions", "marketing screenshots",
            "store listing", "product page", "app preview", "preview video", "promo video",
            "status bar", "simctl", "Dynamic Island", "13-inch iPad",
            "Guideline 2.3.3", "Guideline 2.3.4", "Guideline 2.3.7", "Guideline 2.3.8", "Guideline 2.3.9",
        ],
        related: ["submission-checklist", "dark-mode", "privacy-details", "store-forms", "rejection-guide"],
        notes: [
            "**The first screenshots do the most work.** When there's no app preview, the first one to three screenshots show in App Store search results, so lead with what your app is for.",
            "**Consider one Dark Mode screenshot.** If your app supports it, showing it helps. That's our suggestion, not an Apple rule.",
            "**Upload them per language if your UI is translated.** Screenshots are localizable, so each language can show your app in that language.",
        ],
        guidelines: [
            Guideline(
                "Show the app in use.",
                "Guideline 2.3.3 says screenshots must show your app working, not just a title card, a login screen, or a splash screen.",
                good: "A real screen, with a short headline.",
                bad: "A splash screen tells people nothing."
            ) {
                StoreShot(headline: "Plan your week in seconds", tint: .blue) {
                    ShotListScreen()
                }
            } bad: {
                StoreShot(headline: nil, tint: .blue) {
                    VStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.largeTitle)
                        Text("Weekly")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.blue.gradient)
                }
            },
            Guideline(
                "Leave out prices and other platforms.",
                "Guideline 2.3.7 keeps prices out of screenshots, and 2.3.10 keeps out the names and icons of other mobile platforms.",
                good: "A headline about what the app does.",
                bad: "A price and another platform's name."
            ) {
                StoreShot(headline: "Plan your week in seconds", tint: .blue) {
                    ShotListScreen()
                }
            } bad: {
                StoreShot(headline: "Only $2.99! Also on Android", tint: .red) {
                    ShotListScreen()
                }
            },
            Guideline(
                "Use a clean status bar.",
                "A low battery or a random time pulls attention from your app. Override the Simulator's status bar before you shoot.",
                good: "A fixed time, full signal and battery.",
                bad: "A low battery and weak signal look careless."
            ) {
                ShotStatusBar(time: "9:41", bars: 1, battery: "battery.100percent", batteryTint: .primary)
            } bad: {
                ShotStatusBar(time: "2:17", bars: 0.25, battery: "battery.25percent", batteryTint: .red)
            },
            Guideline(
                "Use made-up people and data.",
                "Guideline 2.3.9 asks for fictional account details, never a real person's, and you need the rights to every image you show."
            ),
            Guideline(
                "Keep it suitable for everyone.",
                "Guideline 2.3.8 says screenshots and previews must fit a 4+ rating, even when your app is rated higher."
            ),
        ],
        sources: [
            "https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/",
            "https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications/",
            "https://developer.apple.com/app-store/review/guidelines/#accurate-metadata",
            "https://developer.apple.com/app-store/product-page/",
        ],
        reviewed: "October 2026"
    ) {
        ScreenshotsThumbnail()
    } content: { page in
        ScreenshotsArticle(page: page)
    }
}

// MARK: - Thumbnail

private struct ScreenshotsThumbnail: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            RoundedRectangle(cornerRadius: 6)
                .fill(.blue.gradient)
                .frame(width: 30, height: 64)
            RoundedRectangle(cornerRadius: 6)
                .fill(.indigo.gradient)
                .frame(width: 30, height: 64)
            RoundedRectangle(cornerRadius: 8)
                .fill(.teal.gradient)
                .frame(width: 56, height: 74)
        }
    }
}

// MARK: - Page

private struct ScreenshotsArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Every version you submit needs screenshots in App Store Connect. Guideline 2.3.3 says they must show your app in use. They're the first thing people judge your app by, so it pays to make them clean and clear.")

            SectionTitle("What you must upload")
            ConnectFacts(rows: [
                ("iPhone (required)", "At least one screenshot for iPhone with Dynamic Island, medium display: **1206\u{00A0}×\u{00A0}2622** or **1179\u{00A0}×\u{00A0}2556** px in portrait."),
                ("iPad (if your app runs on iPad)", "At least one for the 13-inch iPad display: **2064\u{00A0}×\u{00A0}2752** or **2048\u{00A0}×\u{00A0}2732** px in portrait."),
                ("How many", "1 to 10 per display size."),
                ("Format", "PNG or JPEG, with no transparency."),
            ])
            Aside(.note, "As of October 2026. If your UI is the same across sizes, upload only these and App Store Connect scales them down for smaller iPhones and iPads.")
            Aside(.note, "Apple's spec page also says screenshots for iPhone Duo become required in April 2027 for apps built with the iOS 27.1 SDK or later.")

            SectionTitle("Which simulator to use")
                .id("sizer")
            Prose("Take screenshots on a simulator in the required display class. Its screenshots come out at the right pixel size, so you don't need to resize them.")
            ScreenshotSizer()

            SectionTitle("Clean screenshots from the Simulator")
            Prose("`simctl` comes with Xcode. Boot your simulator, run your app with sample data, then run these in Terminal:")
            CodeBlock(code: """
            # A clean status bar: fixed time, full signal and battery
            xcrun simctl status_bar booted override --time 9:41 \\
              --batteryState charged --batteryLevel 100 \\
              --cellularBars 4 --wifiBars 3

            # Save a full-size PNG
            xcrun simctl io booted screenshot home.png

            # Put the status bar back
            xcrun simctl status_bar booted clear
            """)
            Aside(.note, "`booted` means the simulator that's running. With several running, pass a device ID from `xcrun simctl list` instead.")

            SectionTitle("App previews")
                .id("previews")
            Prose("App previews are optional videos that play before your screenshots. You can add up to three per display size and language. Each one runs 15 to 30 seconds and is up to 500 MB.")
            Prose("Guideline 2.3.4 says a preview may only use screen recordings of your app. You can add narration and text overlays to explain what's happening.")
            CodeBlock(code: """
            # Record as H.264. Press Control-C to stop.
            xcrun simctl io booted recordVideo \\
              --codec=h264 preview.mov
            """)
            Aside(.important, "`recordVideo` saves HEVC by default, and App Store Connect expects H.264 or ProRes 422 (HQ). Pass `--codec=h264`, and trim the video to 15 to 30 seconds before you upload.")
        }
    }
}

// MARK: - Sizer

private struct ScreenshotSizer: View {
    enum Device: String, CaseIterable, Identifiable {
        case iPhone, iPad
        var id: Self { self }
    }

    @State private var device = Device.iPhone

    private var size: CGSize {
        device == .iPhone ? CGSize(width: 1206, height: 2622) : CGSize(width: 2064, height: 2752)
    }

    private var simulators: String {
        device == .iPhone
            ? "iPhone 17, iPhone 17 Pro, or iPhone 18 Pro"
            : "a 13-inch iPad Pro or iPad Air"
    }

    private var frameHeight: CGFloat {
        device == .iPhone ? 200 : 180
    }

    var body: some View {
        VStack(spacing: 18) {
            Picker("Device", selection: $device.animation(.smooth)) {
                ForEach(Device.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 260)

            HStack(spacing: 20) {
                RoundedRectangle(cornerRadius: device == .iPhone ? 20 : 12)
                    .fill(.fill.tertiary)
                    .overlay {
                        RoundedRectangle(cornerRadius: device == .iPhone ? 20 : 12)
                            .strokeBorder(.separator)
                    }
                    .frame(width: frameHeight * size.width / size.height, height: frameHeight)
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: "\(Int(size.width)) × \(Int(size.height))")
                        .font(.headline.monospacedDigit())
                    Text("pixels, portrait")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Shoot on \(simulators).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

// MARK: - Do / Don't samples

/// A store screenshot: an optional headline over a slice of the app.
private struct StoreShot<Screen: View>: View {
    let headline: String?
    let tint: Color
    @ViewBuilder let screen: Screen

    var body: some View {
        VStack(spacing: 8) {
            if let headline {
                Text(headline)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            screen
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.background)
                .clipShape(.rect(cornerRadius: 10))
        }
        .padding(10)
        .frame(width: 140, height: 220)
        .background(tint.gradient, in: .rect(cornerRadius: 14))
    }
}

private struct ShotListScreen: View {
    private let items = [("Gym", "Mon"), ("Groceries", "Tue"), ("Call Mom", "Wed"), ("Dentist", "Thu")]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("This Week")
                .font(.caption.weight(.bold))
            ForEach(items, id: \.0) { item in
                HStack {
                    Image(systemName: "circle")
                        .foregroundStyle(.tint)
                    Text(item.0)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text(item.1)
                        .foregroundStyle(.secondary)
                }
                .font(.caption2)
            }
            Spacer(minLength: 0)
        }
        .padding(8)
    }
}

private struct ShotStatusBar: View {
    let time: String
    let bars: Double
    let battery: String
    let batteryTint: Color

    var body: some View {
        HStack {
            Text(time)
                .font(.subheadline.weight(.semibold).monospacedDigit())
            Spacer()
            HStack(spacing: 5) {
                Image(systemName: "cellularbars", variableValue: bars)
                Image(systemName: "wifi", variableValue: bars)
                Image(systemName: battery)
                    .foregroundStyle(batteryTint)
            }
            .font(.subheadline)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .frame(width: 240)
        .background(.background, in: .capsule)
    }
}
