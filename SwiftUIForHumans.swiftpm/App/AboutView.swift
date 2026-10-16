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
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "Version \(short) (\(build))"
    }

    // App Store Connect requires a privacy policy URL and a support URL.
    // Set both to the public pages before submitting; until then their rows
    // stay hidden.
    static let privacyPolicyURL: URL? = nil
    static let supportURL: URL? = nil
}

/// The About screen: what the app is, its version, the links App Review
/// expects, and that it isn't made by Apple.
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

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
