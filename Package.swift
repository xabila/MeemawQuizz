// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MeemawQuizzCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "MeemawQuizzCore", targets: ["MeemawQuizzCore"]),
    ],
    targets: [
        .target(name: "MeemawQuizzCore"),
        .testTarget(
            name: "MeemawQuizzCoreTests",
            dependencies: ["MeemawQuizzCore"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
