// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let baseDeps: [PackageDescription.Target.Dependency] = [
    .product(name: "Models", package: "Model"),
    .product(name: "Router", package: "Model"),
    .product(name: "DesignSystem", package: "DesignSystem"),
]

let package = Package(
    name: "Features",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "SearchUI", targets: ["SearchUI"]),
        .library(name: "TodayUI", targets: ["TodayUI"]),
        .library(name: "KitchenUI", targets: ["KitchenUI"]),
        .library(name: "BarcodeUI", targets: ["BarcodeUI"]),
    ],
    dependencies: [
        .package(name: "Model", path: "../Model"),
        .package(name: "DesignSystem", path: "../DesignSystem"),
        .package(url: "https://github.com/twostraws/CodeScanner", from: "2.5.0"),
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
            name: "KitchenUI",
            dependencies: baseDeps + ["TodayUI"]
        ),
        .target(
            name: "BarcodeUI",
            dependencies: baseDeps + ["CodeScanner"]
        ),
    ]
)
