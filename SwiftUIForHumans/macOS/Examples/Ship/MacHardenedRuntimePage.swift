import SwiftUI

extension ComponentPage {
    static let hardenedRuntime = ComponentPage(
        id: "hardened-runtime",
        title: "Hardened Runtime",
        summary: "Runtime protections Apple requires before it notarizes your Mac app.",
        category: .testAndRelease,
        kind: .reference,
        symbol: "lock.shield",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/security/hardened-runtime",
        aliases: [
            "hardened runtime", "ENABLE_HARDENED_RUNTIME", "--options=runtime", "runtime exceptions",
            "com.apple.security.cs.allow-jit", "allow-unsigned-executable-memory",
            "disable-library-validation", "allow-dyld-environment-variables", "JIT",
            "code injection", "dylib hijacking", "notarization requirement",
        ],
        related: ["developer-id-notarization", "app-sandbox", "privacy-permissions", "updates-outside-store"],
        notes: [
            "**New Mac projects have it already.** Xcode adds the Hardened Runtime capability when you create a macOS app from a template.",
            "**Entitlements go on executables only.** Frameworks, shared libraries, and in-process plug-ins inherit the entitlements of the app that loads them.",
            "**Leave out what's false.** These entitlements default to false, so include one only when its value is true, as Xcode does.",
        ],
        guidelines: [
            Guideline(
                "Add only the exceptions you need.",
                "Each exception turns off one protection. Some, like Disable Executable Memory Protection, remove core security barriers, so pick the narrowest one that works.",
                good: "One exception, for the JIT the app uses.",
                bad: "Every exception checked, just in case."
            ) {
                ExceptionsPanel(checked: [.jit])
            } bad: {
                ExceptionsPanel(checked: Set(RuntimeException.allCases))
            },
        ],
        sources: [
            "https://developer.apple.com/documentation/security/hardened-runtime",
            "https://developer.apple.com/documentation/xcode/configuring-the-hardened-runtime",
            "https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution",
            "https://developer.apple.com/documentation/security/resolving-common-notarization-issues",
            "https://developer.apple.com/documentation/xcode/build-settings-reference",
            "https://developer.apple.com/developer-id/",
        ],
        reviewed: "October 2026"
    ) {
        ShipThumbnail(symbol: "lock.shield", caption: "Hardened Runtime")
    } content: { page in
        MacHardenedRuntimeArticle(page: page)
    }
}

// MARK: - Page

private struct MacHardenedRuntimeArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("The Hardened Runtime is a set of restrictions the system enforces on your app. Together with System Integrity Protection, it blocks whole classes of attacks, like injecting code, hijacking a dynamic library, or tampering with the app's memory. Most apps run the same with it on.")

            SectionTitle("When you need it")
            ConnectFacts(rows: [
                ("Outside the Mac App Store", "**Required.** Apple notarizes only apps with the Hardened Runtime on, and Developer ID software must be notarized. See [Developer ID & Notarization](catalog://developer-id-notarization)."),
                ("On the Mac App Store", "You don't notarize App Store apps, because the submission process includes equivalent checks. Apple ties the Hardened Runtime requirement to notarization."),
            ])
            Aside(.note, "On the store, Guideline 2.4.5(i) requires the App Sandbox. See [App Sandbox](catalog://app-sandbox).")

            SectionTitle("Turn it on")
            ConnectSteps(steps: [
                "Select your app's target in Xcode and open **Signing & Capabilities**.",
                "Click **+ Capability** and choose **Hardened Runtime**. The build setting behind it is `ENABLE_HARDENED_RUNTIME`.",
                "If your app needs one, check a **Runtime Exception** or a **Resource Access** item. Xcode adds the entitlement, set to true.",
                "Archive and notarize. Without it, notarization fails with “The executable does not have the hardened runtime enabled.”",
            ])

            SectionTitle("Build your entitlements")
            Prose("Check what your app needs. The file below shows only the keys you checked, the way Xcode writes them.")
            EntitlementsBuilder()

            SectionTitle("Resource access still asks first")
            Prose("A resource access entitlement, like Camera or Location, only lets your app ask. People still see the system's permission prompt, and your `Info.plist` still needs a purpose string. See [Privacy & Permissions](catalog://privacy-permissions).")

            SectionTitle("Check a signed app")
            CodeBlock(code: """
            # Verify the signature as strictly as notarization does
            codesign -vvv --deep --strict "Trips.app"

            # List the entitlements the app was signed with
            codesign -d --entitlements :- "Trips.app"
            """)
        }
    }
}

// MARK: - Entitlements

private enum RuntimeException: String, CaseIterable, Identifiable {
    case jit, unsignedMemory, dyld, libraryValidation, executableMemory, debugger

    var id: Self { self }

    var title: String {
        switch self {
        case .jit: "Allow Execution of JIT-compiled Code"
        case .unsignedMemory: "Allow Unsigned Executable Memory"
        case .dyld: "Allow DYLD Environment Variables"
        case .libraryValidation: "Disable Library Validation"
        case .executableMemory: "Disable Executable Memory Protection"
        case .debugger: "Debugging Tool"
        }
    }

    var detail: String {
        switch self {
        case .jit: "Writable, executable memory with `MAP_JIT`, like a script engine."
        case .unsignedMemory: "Executable memory without `MAP_JIT`'s limits. For legacy code."
        case .dyld: "Change behavior at runtime with dynamic linker variables."
        case .libraryValidation: "Load frameworks and plug-ins from other developers."
        case .executableMemory: "Turns off code signing's memory protections. Avoid it."
        case .debugger: "Attach to other processes, as a debugger does."
        }
    }

    var key: String {
        switch self {
        case .jit: "com.apple.security.cs.allow-jit"
        case .unsignedMemory: "com.apple.security.cs.allow-unsigned-executable-memory"
        case .dyld: "com.apple.security.cs.allow-dyld-environment-variables"
        case .libraryValidation: "com.apple.security.cs.disable-library-validation"
        case .executableMemory: "com.apple.security.cs.disable-executable-page-protection"
        case .debugger: "com.apple.security.cs.debugger"
        }
    }
}

private enum ResourceAccess: String, CaseIterable, Identifiable {
    case audio, camera, location, contacts, calendars, photos, appleEvents

    var id: Self { self }

    var title: String {
        switch self {
        case .audio: "Audio Input"
        case .camera: "Camera"
        case .location: "Location"
        case .contacts: "Contacts"
        case .calendars: "Calendar"
        case .photos: "Photos Library"
        case .appleEvents: "Apple Events"
        }
    }

    var key: String {
        switch self {
        case .audio: "com.apple.security.device.audio-input"
        case .camera: "com.apple.security.device.camera"
        case .location: "com.apple.security.personal-information.location"
        case .contacts: "com.apple.security.personal-information.addressbook"
        case .calendars: "com.apple.security.personal-information.calendars"
        case .photos: "com.apple.security.personal-information.photos-library"
        case .appleEvents: "com.apple.security.automation.apple-events"
        }
    }
}

/// Check exceptions and resources; the entitlements file updates live.
private struct EntitlementsBuilder: View {
    @State private var exceptions: Set<RuntimeException> = []
    @State private var resources: Set<ResourceAccess> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 24) { columns }
                VStack(alignment: .leading, spacing: 16) { columns }
            }
            .padding(16)
            .cardStyle()
            CodeBlock(code: plist)
        }
    }

    @ViewBuilder private var columns: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Runtime Exceptions")
                .font(.subheadline.weight(.semibold))
            ForEach(RuntimeException.allCases) { exception in
                Toggle(isOn: binding(exception, in: $exceptions)) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(exception.title)
                        RichText(exception.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(maxWidth: 360, alignment: .leading)
        VStack(alignment: .leading, spacing: 8) {
            Text("Resource Access")
                .font(.subheadline.weight(.semibold))
            ForEach(ResourceAccess.allCases) { resource in
                Toggle(resource.title, isOn: binding(resource, in: $resources))
            }
        }
        .frame(maxWidth: 220, alignment: .leading)
    }

    private func binding<Item: Hashable>(_ item: Item, in set: Binding<Set<Item>>) -> Binding<Bool> {
        Binding {
            set.wrappedValue.contains(item)
        } set: { isOn in
            if isOn {
                set.wrappedValue.insert(item)
            } else {
                set.wrappedValue.remove(item)
            }
        }
    }

    private var plist: String {
        let keys = RuntimeException.allCases.filter(exceptions.contains).map(\.key)
            + ResourceAccess.allCases.filter(resources.contains).map(\.key)
        var lines = ["<?xml version=\"1.0\" encoding=\"UTF-8\"?>", "<plist version=\"1.0\">", "<dict>"]
        if keys.isEmpty {
            lines.append("    <!-- No exceptions: every protection stays on. -->")
        }
        for key in keys {
            lines.append("    <key>\(key)</key>")
            lines.append("    <true/>")
        }
        lines += ["</dict>", "</plist>"]
        return lines.joined(separator: "\n")
    }
}

/// A drawing of the capability's exception checkboxes for the guideline.
private struct ExceptionsPanel: View {
    let checked: Set<RuntimeException>

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Runtime Exceptions")
                .font(.caption.weight(.semibold))
            ForEach(RuntimeException.allCases) { exception in
                Toggle(exception.title, isOn: .constant(checked.contains(exception)))
                    .font(.caption)
            }
        }
        .controlSize(.small)
        .frame(width: 270, alignment: .leading)
    }
}
