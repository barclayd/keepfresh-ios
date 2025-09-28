// swift-tools-version: 6.0
import PackageDescription

let package = Package(name: "Models",
                      platforms: [.iOS(.v18), .macOS(.v15)],
                      products: [
                          .library(name: "Models", targets: ["Models"]),
                      ],
                      dependencies: [
                          .package(path: "../DesignSystem"),
                      ],
                      targets: [
                          .target(name: "Models",
                                  dependencies: ["DesignSystem"]),
                      ])
