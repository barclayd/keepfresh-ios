// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Models",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "Models", type: .static, targets: ["Models"]),
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
        .package(path: "../Extensions"),
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: ["DesignSystem", "Extensions"]),
    ])
