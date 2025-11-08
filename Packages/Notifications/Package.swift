// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Notifications",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "Notifications", type: .static, targets: ["Notifications"]),
    ],
    dependencies: [
        .package(path: "../Models"),
        .package(path: "../Network"),
        .package(path: "../Extensions"),
        .package(path: "../Router"),
    ],
    targets: [
        .target(
            name: "Notifications",
            dependencies: ["Models", "Network", "Extensions", "Router"]),
    ])
