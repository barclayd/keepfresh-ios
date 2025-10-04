// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Intelligence",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "Intelligence", targets: ["Intelligence"]),
    ],
    dependencies: [
        .package(path: "../Models"),
        .package(path: "../Network"),
        .package(path: "../Extensions"),
    ],
    targets: [
        .target(
            name: "Intelligence",
            dependencies: ["Models", "Network", "Extensions"]),
    ])
