// swift-tools-version: 6.2
import PackageDescription

let baseDeps: [PackageDescription.Target.Dependency] = [
    .product(name: "Models", package: "Models"),
    .product(name: "DesignSystem", package: "DesignSystem"),
    .product(name: "Network", package: "Network"),
    .product(name: "Router", package: "Router"),
    .product(name: "Environment", package: "Environment"),
    .product(name: "Extensions", package: "Extensions"),
    .product(name: "Intelligence", package: "Intelligence"),
]

let package = Package(
    name: "Features",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "SearchUI", targets: ["SearchUI"]),
        .library(name: "TodayUI", targets: ["TodayUI"]),
        .library(name: "KitchenUI", targets: ["KitchenUI"]),
        .library(name: "BarcodeUI", targets: ["BarcodeUI"]),
        .library(name: "SharedUI", targets: ["SharedUI"]),
    ],
    dependencies: [
        .package(path: "../Models"),
        .package(path: "../DesignSystem"),
        .package(path: "../Router"),
        .package(path: "../Network"),
        .package(path: "../Environment"),
        .package(path: "../Extensions"),
        .package(path: "../Intelligence"),
        .package(url: "https://github.com/twostraws/CodeScanner", from: "2.5.0"),
    ],
    targets: [
        .target(
            name: "SearchUI",
            dependencies: baseDeps + ["SharedUI"]),
        .target(
            name: "TodayUI",
            dependencies: baseDeps + ["SharedUI"]),
        .target(
            name: "KitchenUI",
            dependencies: baseDeps + ["TodayUI", "SharedUI"]),
        .target(
            name: "BarcodeUI",
            dependencies: baseDeps + ["CodeScanner"]),
        .target(
            name: "SharedUI",
            dependencies: baseDeps)
    ])
