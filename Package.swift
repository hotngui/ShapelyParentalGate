// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ShapelyParentalGate",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "ShapelyParentalGate",
            targets: ["ShapelyParentalGate"]),
    ],
    targets: [
        .target(
            name: "ShapelyParentalGate",
            resources: [
                .process("Resources/DefaultLocalizedStrings.plist")
            ]
        ),
        .testTarget(
            name: "ShapelyParentalGateTests",
            dependencies: ["ShapelyParentalGate"],
            resources: [
                .process("Resources/OverrideLocalizedStrings.plist")
            ]
        )
    ]
)
