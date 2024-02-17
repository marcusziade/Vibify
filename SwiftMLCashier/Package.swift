// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftMLCashier",
    products: [
        .library(
            name: "SwiftMLCashier",
            targets: ["SwiftMLCashier"]),
    ],
    targets: [
        .target(
            name: "SwiftMLCashier"),
        .testTarget(
            name: "SwiftMLCashierTests",
            dependencies: ["SwiftMLCashier"]),
    ]
)
