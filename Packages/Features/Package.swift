// swift-tools-version: 6.0
import PackageDescription

let baseDeps: [PackageDescription.Target.Dependency] = [
    .product(name: "Models", package: "Models"),
    .product(name: "DesignSystem", package: "DesignSystem"),
    .product(name: "Network", package: "Network"),
    .product(name: "Router", package: "Router"),
    .product(name: "Environment", package: "Environment"),
    .product(name: "Extensions", package: "Extensions"),
]

let package = Package(
    name: "Features",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "SearchUI", targets: ["SearchUI"]),
        .library(name: "TodayUI", targets: ["TodayUI"]),
        .library(name: "KitchenUI", targets: ["KitchenUI"]),
        .library(name: "BarcodeUI", targets: ["BarcodeUI"]),
    ],
    dependencies: [
        .package(path: "../Models"),
        .package(path: "../DesignSystem"),
        .package(path: "../Router"),
        .package(path: "../Network"),
        .package(path: "../Environment"),
        .package(path: "../Extensions"),
        .package(url: "https://github.com/twostraws/CodeScanner", from: "2.5.0"),
    ],
    targets: [
        .target(
            name: "SearchUI",
            dependencies: baseDeps),
        .target(
            name: "TodayUI",
            dependencies: baseDeps),
        .target(
            name: "KitchenUI",
            dependencies: baseDeps + ["TodayUI"]),
        .target(
            name: "BarcodeUI",
            dependencies: baseDeps + ["CodeScanner"]),
    ])
