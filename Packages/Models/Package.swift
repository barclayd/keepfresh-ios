// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Models",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "Models", targets: ["Models"]),
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: ["DesignSystem"]),
    ])
