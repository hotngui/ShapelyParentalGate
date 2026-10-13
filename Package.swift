// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "ShapelyParentalGate",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "ShapelyParentalGate",
            targets: ["ShapelyParentalGate"])
    ],
    targets: [
        .target(
            name: "ShapelyParentalGate",
            resources: [
                .process("Resources")
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
