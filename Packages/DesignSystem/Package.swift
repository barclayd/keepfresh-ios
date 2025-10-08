// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "DesignSystem", type: .static, targets: ["DesignSystem"]),
    ],
    targets: [
        .target(
            name: "DesignSystem",
            dependencies: [],
            resources: [
                .copy("Shrikhand-Regular.ttf"),
            ]),
    ])
