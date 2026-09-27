// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Network",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "Network", type: .static, targets: ["KeepFreshNetwork"]),
    ],
    dependencies: [
        .package(path: "../Models"),
        .package(path: "../Authentication"),
    ],
    targets: [
        .target(
            name: "KeepFreshNetwork",
            dependencies: ["Models", "Authentication"],
            path: "Sources/Network"),
    ])
