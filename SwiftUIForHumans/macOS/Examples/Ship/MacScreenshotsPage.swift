import SwiftUI

extension ComponentPage {
    static let macScreenshots = ComponentPage(
        id: "mac-screenshots",
        title: "Screenshots & Metadata",
        summary: "Mac screenshot sizes, app previews, and the text on your Mac product page.",
        category: .appStoreConnect,
        kind: .reference,
        symbol: "photo.on.rectangle",
        availability: [],
        docsURL: "https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications",
        aliases: [
            "screenshots", "screenshot size", "1280x800", "1440x900", "2560x1600", "2880x1800", "16:10",
            "app preview", "video", "product page", "description", "keywords", "promotional text",
            "metadata", "Guideline 2.3", "Guideline 2.3.3", "Guideline 2.3.7", "Guideline 2.3.8",
            "Guideline 2.3.9", "Guideline 2.3.10",
        ],
        related: ["universal-purchase", "pricing-category", "mac-app-review", "app-icons"],
        notes: [
            "**Mac screenshots don't come from iOS.** When you add the macOS platform, the description, promotional text, and screenshots start empty.",
            "**Promotional text changes without a review.** Use its 170 characters for news; it appears above the description.",
        ],
        guidelines: [
            Guideline(
                "Show the app in use.",
                "Guideline 2.3.3 asks for screenshots of the app doing its job, not just title art, a sign-in window, or a splash screen. Text overlays are fine when they explain, not hide.",
                good: "The app's window, with real content.",
                bad: "Only the icon and name."
            ) {
                ScreenshotFrame {
                    MacWindowFrame(title: "Trips", width: 170, height: 96) {
                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(["Lisbon", "Kyoto", "Oslo"], id: \.self) { city in
                                Label(city, systemImage: "airplane")
                            }
                        }
                        .font(.system(size: 9))
                    }
                }
            } bad: {
                ScreenshotFrame {
                    VStack(spacing: 4) {
                        Image(systemName: "airplane.circle.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(.white)
                        Text("Trips")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
            },
            Guideline(
                "Use fictional data.",
                "Guideline 2.3.9 asks for made-up account details in screenshots, never a real person's data, and you need the rights to everything shown."
            ),
            Guideline(
                "Keep it suitable for everyone, and about this app.",
                "Screenshots must suit a 4+ audience even if the app is rated higher (2.3.8), and can't show the names or imagery of other mobile platforms (2.3.10)."
            ),
        ],
        sources: [
            "https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications",
            "https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications",
            "https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information",
            "https://developer.apple.com/help/app-store-connect/create-an-app-record/add-platforms",
            "https://developer.apple.com/app-store/review/guidelines/#accurate-metadata",
            "https://developer.apple.com/app-store/product-page/",
        ],
        reviewed: "October 2026"
    ) {
        ScreenshotFrame {
            MacWindowFrame(title: "", width: 110, height: 60) {
                Color.clear
            }
        }
        .scaleEffect(0.8)
    } content: { page in
        MacScreenshotsArticle(page: page)
    }
}

// MARK: - Page

private struct MacScreenshotsArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Screenshots are required for a Mac app. Upload at least one, and up to 10, as `.jpeg`, `.jpg`, or `.png`, in one of four sizes. Every size has a 16:10 aspect ratio.")

            SectionTitle("Accepted sizes")
            ConnectFacts(rows: [
                ("Sizes, in pixels", "1280 × 800, 1440 × 900, 2560 × 1600, or 2880 × 1800."),
                ("How many", "At least one, up to 10."),
                ("Scaling", "If your interface is the same at every size, provide the highest resolution; App Store Connect scales it down."),
            ])
            Aside(.important, "Screenshots can't have an alpha channel or transparency. Flatten them before you upload.")

            SectionTitle("Check a size")
            SizeChecker()

            SectionTitle("App previews")
            ConnectFacts(rows: [
                ("Optional", "Up to three per language for each size."),
                ("Orientation", "Landscape only for Mac apps."),
                ("Formats", "`.mov`, `.m4v`, or `.mp4` with H.264, or `.mov` with ProRes 422 (HQ only)."),
                ("Order", "Previews always show before screenshots. One with a different aspect ratio from your screenshots goes in the “A Closer Look” section instead."),
                ("Content", "Only video captured from the app itself (Guideline 2.3.4). Narration and text overlays are fine."),
            ])

            SectionTitle("The text on the page")
            ConnectFacts(rows: [
                ("Name", "Up to 30 characters (Guideline 2.3.7), with no prices or unrelated terms."),
                ("Promotional text", "Up to 170 characters. Change it any time without a new version."),
                ("Description", "Up to 4000 characters of plain text. Required."),
                ("Keywords", "Up to 100 bytes, each word longer than two characters. No other apps' or companies' names. Required."),
                ("Support URL", "Must lead to real contact information. Required."),
                ("Copyright", "The year and the owner, like “2026 Example, Inc.” Required."),
                ("What's New", "Required for every version after the first. Describe significant changes specifically (2.3.12)."),
            ])
        }
    }
}

// MARK: - Samples

/// A 16:10 screenshot canvas on a wallpaper backdrop.
private struct ScreenshotFrame<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            SceneryView(.wallpaper)
            content
        }
        .frame(width: 256, height: 160)
        .clipShape(.rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.separator)
        }
    }
}

private struct SizeChecker: View {
    @State private var width = 2880
    @State private var height = 1800

    private static let accepted: [(Int, Int)] = [(1280, 800), (1440, 900), (2560, 1600), (2880, 1800)]

    private var isAccepted: Bool {
        Self.accepted.contains { $0 == (width, height) }
    }

    private var message: String {
        if isAccepted {
            return "Accepted for Mac screenshots."
        }
        if width * 10 == height * 16 {
            return "16:10, but not one of the four accepted sizes."
        }
        if height > width {
            return "Mac screenshots are landscape: 16:10."
        }
        return "Not a 16:10 size. Pick one of the four accepted sizes."
    }

    var body: some View {
        HStack(spacing: 20) {
            Form {
                TextField("Width", value: $width, format: .number.grouping(.never))
                TextField("Height", value: $height, format: .number.grouping(.never))
            }
            .frame(width: 180)
            Label(message, systemImage: isAccepted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(isAccepted ? .green : .red)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(16)
        .cardStyle()
    }
}
