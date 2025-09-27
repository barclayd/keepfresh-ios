// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Environment",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "Environment", targets: ["Environment"]),
    ],
    dependencies: [
        .package(path: "../Models"),
        .package(path: "../Network"),
        .package(path: "../Extensions"),
    ],
    targets: [
        .target(
            name: "Environment",
            dependencies: ["Models", "Network", "Extensions"]
        ),
    ]
)
