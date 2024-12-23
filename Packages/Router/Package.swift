// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Router",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "Router", targets: ["Router"]),
    ],
    dependencies: [
        .package(name: "DesignSystem", path: "../DesignSystem"),
        .package(name: "Model", path: "../Model"),
    ],
    targets: [
        .target(
            name: "Router",
            dependencies: ["Router"]
        ),
    ]
)
