// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Krypton",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v4)
    ],
    products: [
        .library(name: "Krypton", targets: ["Krypton"])
    ],
    dependencies: [],
    targets: [
        .target(name: "Krypton", dependencies: []),
        .testTarget(name: "KryptonTests",
                    dependencies: ["Krypton"])
    ])
