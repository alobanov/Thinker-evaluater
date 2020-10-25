// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "thinker",
    platforms: [
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2),
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "thinker",
            targets: ["thinker"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "thinker",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "thinkerTests",
            dependencies: ["thinker"],
            path: "Tests"
        ),
    ]
)
