// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let baseDeps: [PackageDescription.Target.Dependency] = [
    .product(name: "DesignSystem", package: "../DesignSystem"),
]

let package = Package(
    name: "Model",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "Models", targets: ["Models"]),
        .library(name: "Router", targets: ["Router"]),
    ],
    dependencies: [
        .package(name: "DesignSystem", path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: baseDeps
        ),
        .target(
            name: "Router",
            dependencies: baseDeps
        ),
    ]
)
