// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Environment",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "Environment", type: .static, targets: ["Environment"]),
    ],
    dependencies: [
        .package(path: "../Models"),
        .package(path: "../Network"),
        .package(path: "../Extensions"),
        .package(path: "../DesignSystem"),
        .package(path: "../Notifications"),
    ],
    targets: [
        .target(
            name: "Environment",
            dependencies: ["Models", "Network", "Extensions", "DesignSystem", "Notifications"]),
    ])
