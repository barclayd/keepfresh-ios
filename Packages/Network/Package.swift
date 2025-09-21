// Packages/Network/Package.swift

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Network",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "Network", targets: ["Network"]),
    ],
    dependencies: [
        .package(path: "../Models")
    ],
    targets: [
        .target(
            name: "Network",
            dependencies: ["Models"]
        ),
    ]
)
