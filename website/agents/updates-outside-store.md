---
id: updates-outside-store
title: Updates Outside the Store
platforms: [macOS]
docs: https://developer.apple.com/macos/distribution/
reviewed: October 2026
---

# Updates Outside the Store

Apps you distribute yourself deliver their own updates; Mac App Store apps must not.

Also called: updates, auto-update, software update, Check for Updates, updater, update feed, appcast, direct distribution, compilation condition, SWIFT_ACTIVE_COMPILATION_CONDITIONS.

## Contents

- Rules
- Pitfalls
- Guide
- Variants
- Related

## Rules

- **Leave Check for Updates out of the store build.** Guideline 2.4.5(vii) says Mac App Store apps get updates only through the store, so the store build can't have an updater of its own.

## Pitfalls

- **Store updates can install themselves.** People can opt in to always getting the latest version of Mac App Store apps automatically.
- **Every release goes through the same steps.** Sign each update with Developer ID, notarize it, and staple the ticket, just like the first version.

## Guide

On the Mac App Store, Apple hosts your updates and delivers them. Outside it, Apple's own comparison puts software updates in your hands: you host each new version and get it to people.

### The rules on the store

- 2.4.5(vii): Mac App Store apps must use the Mac App Store for updates. Other update mechanisms aren't allowed.
- 2.4.5(iv): They can't download or install apps, code, or resources that add features or change the app from what App Review saw.
- 2.5.2: Apps stay self-contained and don't download code that changes their features.

### One codebase, two builds

If you ship both ways, compile the updater only into the direct build. Add a flag like `DIRECT` to **Active Compilation Conditions** (`SWIFT_ACTIVE_COMPILATION_CONDITIONS`) in a build configuration you use only for Developer ID builds.

### A simple update check

The smallest updater asks your server for the latest version and, if it's newer, sends people to your download page. Whatever people download must be signed with your Developer ID and notarized, like every Developer ID release.

### Before you release an update

- **No updater in the Mac App Store build**: Check the app menu of the archive you submit.
- **Version number raised**: So the update check sees a newer version.
- **Signed with Developer ID and notarized**: And the ticket stapled. ([developer-id-notarization](developer-id-notarization.md))
- **The update feed points at the new download**: Update it after the download is live, not before.
- **Tested from the previous version**: Install the last release and update it the way people will.

## Variants

### A Check for Updates command, direct builds only

`CommandGroup(after: .appInfo)` puts the item under About in the app menu, and `#if DIRECT` keeps it out of the store build.

```swift
@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if DIRECT
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesButton()
            }
        }
        #endif
    }
}
```

### Compare versions, then open the download page

Read your version from `CFBundleShortVersionString`, compare it with the server's using `.numeric`, and open the page with `openURL`.

```swift
struct Release: Decodable {
    let version: String
    let downloadURL: URL
}

struct CheckForUpdatesButton: View {
    @Environment(\.openURL) private var openURL
    @State private var isUpToDate = false

    var body: some View {
        Button("Check for Updates…") {
            Task { await check() }
        }
        .alert("You're up to date.", isPresented: $isUpToDate) {}
    }

    func check() async {
        let feed = URL(string: "https://example.com/trips/latest.json")!
        guard let (data, _) = try? await URLSession.shared.data(from: feed),
              let latest = try? JSONDecoder().decode(Release.self, from: data)
        else { return }
        let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        if current.compare(latest.version, options: .numeric) == .orderedAscending {
            openURL(latest.downloadURL)
        } else {
            isUpToDate = true
        }
    }
}
```

**Note:** The preview compares two versions you type, without a network request.

## Related

[developer-id-notarization](developer-id-notarization.md), [hardened-runtime](hardened-runtime.md), [mac-app-review](mac-app-review.md), [commands](commands.md)
