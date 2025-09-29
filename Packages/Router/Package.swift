// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Router",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "Router", targets: ["Router"]),
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
        .package(path: "../Models"),
    ],
    targets: [
        .target(
            name: "Router",
            dependencies: ["DesignSystem", "Models"]),
    ])
