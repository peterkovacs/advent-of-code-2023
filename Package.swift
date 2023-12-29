// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "AdventOfCode",
  platforms: [
    .macOS(.v14),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-collections", branch: "main"),
    .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.13.0"),
    .package(url: "https://github.com/LuizZak/swift-z3.git", branch: "master")
  ],
  targets: [
    .target(
      name: "Utility",
      dependencies: [
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Numerics", package: "swift-numerics"),
      ]
    ),
    .executableTarget(
      name: "AdventOfCode",
      dependencies: [
        "Utility",
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Numerics", package: "swift-numerics"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Parsing", package: "swift-parsing"),
        .product(name: "SwiftZ3", package: "swift-z3"),
      ]
    ),
    .testTarget(
      name: "UtilityTests",
      dependencies: [
        "Utility",
        .product(name: "Collections", package: "swift-collections"),
      ]
    )
  ]
)
