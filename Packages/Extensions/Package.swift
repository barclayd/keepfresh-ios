// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Extensions",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "Extensions", targets: ["Extensions"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Extensions"),
    ])
