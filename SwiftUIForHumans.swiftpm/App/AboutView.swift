import SwiftUI

/// Facts about the app shown on the About screen.
enum AppInfo {
    /// The name on the Home Screen, from `iOSApplication(name:)` in
    /// Package.swift, so renaming the app there renames it here too.
    static var name: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "This app"
    }

    /// "Version 0.1 (1)": the App Store version and the build number.
    static var version: String {
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "Version \(shortVersion) (\(build))"
    }

    /// The App Store version, like "0.1".
    static var shortVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }

    /// Where "What should I fix?" sends feedback.
    static let feedbackURL = URL(string: "mailto:tylerdbecks@gmail.com?subject=SwiftUI%20for%20Humans%20feedback")!

    // App Store Connect requires a privacy policy URL and a support URL.
    // These are the pages in `website/`; enter the same URLs there.
    // Set either to nil to hide its row.
    static let privacyPolicyURL: URL? = URL(string: "https://swiftui-for-humans.vercel.app/privacy")
    static let supportURL: URL? = URL(string: "https://swiftui-for-humans.vercel.app/support")
}

/// The About screen: what the app is, its version, the links App Review
/// expects, and that it isn't made by Apple.
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var thanked = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(AppInfo.name)
                            .font(.title2.bold())
                        Text(AppInfo.version)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    Text("Apple's SwiftUI documentation and Human Interface Guidelines in one place, in plain language, with live examples you can change and code you can copy.")
                }
                if AppInfo.privacyPolicyURL != nil || AppInfo.supportURL != nil {
                    Section {
                        if let url = AppInfo.supportURL {
                            Link(destination: url) {
                                Label("Support", systemImage: "questionmark.circle")
                            }
                        }
                        if let url = AppInfo.privacyPolicyURL {
                            Link(destination: url) {
                                Label("Privacy Policy", systemImage: "hand.raised")
                            }
                        }
                    }
                }
                if !TipJar.shared.tips.isEmpty {
                    Section {
                        TipButtons { thanked = true }
                    } header: {
                        Text("Leave a Tip")
                    } footer: {
                        Text(thanked ? "Thank you! It really helps." : "\(AppInfo.name) is free. A tip helps keep the pages up to date with each new iOS release.")
                    }
                }
                Section {
                    Text("\(AppInfo.name) doesn't collect any data. Your checklists and settings stay on this device.")
                } header: {
                    Text("Privacy")
                }
                Section {
                    Text("\(AppInfo.name) is an independent project. It isn't affiliated with or endorsed by Apple. Swift, SwiftUI, iOS, and the Human Interface Guidelines are trademarks of Apple Inc., used here only to describe what the app covers.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .task { await TipJar.shared.load() }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .close) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AboutView()
}
