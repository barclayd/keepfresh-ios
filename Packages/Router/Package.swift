// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Router",
    platforms: [.iOS(.v18), .macOS(.v15)],
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
