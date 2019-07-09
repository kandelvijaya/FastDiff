// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "FastDiff",
    products: [
        .library(
            name: "FastDiffLib",
            targets: ["FastDiffLib"]),
    ],
    dependencies: [
        .package(url: "git@github.com:kandelvijaya/AlgorithmChecker.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "FastDiffLib",
            dependencies: []),
        .testTarget(
            name: "FastDiffTests",
            dependencies: ["FastDiffLib", "AlgoChecker"]),
    ]
)
