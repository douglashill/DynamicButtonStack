// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "DynamicButtonStack",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "DynamicButtonStack",
            targets: ["DynamicButtonStack"]
        ),
    ],
    targets: [
        .target(
            name: "DynamicButtonStack",
            path: ".",
            sources: ["DynamicButtonStack.swift"]
        ),
    ]
)
