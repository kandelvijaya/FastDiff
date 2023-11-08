// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "FastDiff",
    products: [
        .library(
            name: "FastDiff",
            targets: ["FastDiff"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kandelvijaya/AlgorithmChecker.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "FastDiff",
            dependencies: []),
        .testTarget(
            name: "FastDiffTests",
            dependencies: ["FastDiff", "AlgoChecker"]),
    ]
)
