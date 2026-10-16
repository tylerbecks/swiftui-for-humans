// swift-tools-version: 6.0

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "SwiftUIForHumans",
    platforms: [
        .iOS("26.0")
    ],
    products: [
        .iOSApplication(
            name: "SwiftUI for Humans",
            targets: ["AppModule"],
            bundleIdentifier: "com.gobimaps.SwiftUIForHumans",
            displayVersion: "0.1",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .magicWand),
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)
