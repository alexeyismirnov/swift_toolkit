// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift_toolkit",
    platforms: [ .iOS("14.0") ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "swift_toolkit",
            targets: ["swift_toolkit"]),
    ],
    dependencies: [
        .package(name: "SQLite", url: "https://github.com/stephencelis/SQLite.swift", .upToNextMajor(from: "0.14.1")),
        ],
    
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "swift_toolkit",
            dependencies: ["SQLite"],
            resources: [ .process("Resources") ]
        ),
    ]
)
