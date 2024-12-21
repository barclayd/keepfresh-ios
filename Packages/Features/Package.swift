// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let baseDeps: [PackageDescription.Target.Dependency] = [
    .product(name: "Models", package: "Model"),
    .product(name: "Router", package: "Model"),
    "DesignSystem",
]

let package = Package(
    name: "Features",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "SearchUI", targets: ["SearchUI"]),
        .library(name: "TodayUI", targets: ["TodayUI"]),
        .library(name: "InventoryUI", targets: ["InventoryUI"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
    ],
    dependencies: [
        .package(name: "Model", path: "../Model"),
    ],
    targets: [
        .target(
            name: "SearchUI",
            dependencies: baseDeps
        ),
        .target(
            name: "TodayUI",
            dependencies: baseDeps
        ),
        .target(
            name: "InventoryUI",
            dependencies: baseDeps
        ),
        .target(
            name: "DesignSystem",
            dependencies: [
                .product(name: "Router", package: "Model"),
            ],
            resources: [
                .process("Base/Shrikhand-Regular.ttf"),
            ]
        ),
    ]
)
