// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Network",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "Network", type: .static, targets: ["Network"]),
    ],
    dependencies: [
        .package(path: "../Models"),
        .package(path: "../Authentication"),
    ],
    targets: [
        .target(
            name: "Network",
            dependencies: ["Models", "Authentication"]),
    ])
