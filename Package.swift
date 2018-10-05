// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "FastDiff",
    products: [
        .library(
            name: "FastDiff",
            targets: ["FastDiff"]),
    ],
    dependencies: [ ],
    targets: [
        .target(
            name: "FastDiff",
            dependencies: []),
        .testTarget(
            name: "FastDiffTests",
            dependencies: ["FastDiff"]),
    ]
)
