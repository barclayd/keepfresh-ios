// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Authentication",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "Authentication", type: .static, targets: ["Authentication"]),
    ],
    dependencies: [
        .package(path: "../Models"),
        .package(url: "https://github.com/supabase/supabase-swift", exact: "2.34.0"),
    ],
    targets: [
        .target(
            name: "Authentication",
            dependencies: [
                "Models",
                .product(name: "Auth", package: "supabase-swift"),
                .product(name: "Supabase", package: "supabase-swift"),
            ]),
    ])
