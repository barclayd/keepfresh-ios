// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Utils",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "Utils", type: .static, targets: ["Utils"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Utils"),
    ])
