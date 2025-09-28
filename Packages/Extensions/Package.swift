// swift-tools-version: 6.0
import PackageDescription

let package = Package(name: "Extensions",
                      platforms: [.iOS(.v18), .macOS(.v15)],
                      products: [
                          .library(name: "Extensions", targets: ["Extensions"]),
                      ],
                      dependencies: [
                      ],
                      targets: [
                          .target(name: "Extensions"),
                      ])
